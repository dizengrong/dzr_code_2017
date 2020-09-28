%% @doc 神器模块
%% 2019-06-19:神器功能在P18完全重写
-module (fun_shenqi).
-include("common.hrl").
-export([
	req_up_shenqi/4, req_up_star/5, load_shenqi/2,
	req_shenqi_illustration/3, get_shenqi_attrs/1, 
	update_shenqi_illustration/3, get_shenqi_skills/2,
	get_used_shenqi/1, get_shenqi_data/2
]).

-define (SHENQI_CHANGE_TYPE_STAR, 1).  	%% 升星变化
-define (SHENQI_CHANGE_TYPE_LV, 2).  	%% 等级变化

%% =============== 数据操作 ===============
get_data(Uid) ->
	case db_api:dirty_read(t_shenqi, Uid) of
		[] ->
			#t_shenqi{uid = Uid};
		[Rec] -> Rec
	end.
set_data(Rec) ->
	db_api:dirty_write(Rec).

%% =============== 数据操作 ===============

%% 获取神器加成属性
get_shenqi_attrs(Uid) ->
	Rec = get_data(Uid),
	case Rec#t_shenqi.stage_used_id of
		0 -> [];
		ShenqiId -> 
			[#item{lev = Lv, type = ItemType}] = fun_item_api:get_item_by_id2(Uid, ShenqiId),
			#st_shenqi{
				attr1 = {AttrId1, Val1}, 
				attr2 = {AttrId2, Val2}, 
				attr3 = {AttrId3, Val3}, 
				attr4 = {AttrId4, Val4}
			} = data_shenqi:get_base(ItemType),
			{_, Add1, Add2, Add3, Add4} = data_shenqi:get_lv_attr_rate(Lv),
			[
				{AttrId1, util:floor(Val1*(Add1/10000))},
				{AttrId2, util:floor(Val2*(Add2/10000))},
				{AttrId3, util:floor(Val3*(Add3/10000))},
				{AttrId4, util:floor(Val4*(Add4/10000))}
			]
	end.

get_shenqi_skills(ShenqiType, Star) ->
	[{S, 1} || S <- data_shenqi:get_star_skill(ShenqiType, Star)].

%% 获取主关卡中使用的神器:{神器Type, 神器星级}
get_used_shenqi(Uid) ->
	Rec = get_data(Uid),
	case Rec#t_shenqi.stage_used_id of
		0 -> {0, 0};
		ShenqiId ->
			case fun_item_api:get_item_by_id2(Uid, ShenqiId) of
				[] -> {0, 0};
				[#item{type = Type, star = Star}] -> 
					{Type, Star}
			end
	end.

%% 获取神器数据:{神器Type, 神器星级, 神器等级}
get_shenqi_data(Uid, ShenqiId) ->
	case fun_item_api:get_item_by_id2(Uid, ShenqiId) of
		[] -> {0, 0, 0};
		[#item{type = Type, star = Star, lev = Lv}] -> 
			{Type, Star, Lv}
	end.

% send_info_to_client(Uid, Sid, Seq) ->
% 	Rec = get_data(Uid),
% 	Pt = #pt_shenqi_info{
% 		stage_used_id   = Rec#t_shenqi.stage_used_id
% 	},
% 	?send(Sid, proto:pack(Pt, Seq)).


req_up_shenqi(Uid, Sid, Seq, ShenqiId) ->
	case check_up_shenqi(Uid, ShenqiId) of
		{error, Reason} -> ?error_report(Sid, Reason);
		{ok, ItemRec} ->
			SuccCallBack = fun() -> 
				NewItemRec = ItemRec#item{lev = ItemRec#item.lev + 1},
				fun_item_api:update_item(Uid, NewItemRec),
				fun_item:send_items_to_sid(Uid, Sid, [NewItemRec], Seq),
				Rec = get_data(Uid),
				case Rec#t_shenqi.stage_used_id of
					ShenqiId -> 
						fun_entourage:update_all_on_battle_hero_property(Uid);
					_ -> false
				end,
				send_update_notify(Sid, Seq, ShenqiId, ?SHENQI_CHANGE_TYPE_LV)
			end,
			Args = #api_item_args{
				way = ?ITEM_WAY_ACTIVE_SHENQI,
				spend = data_shenqi:get_lv_up_cost(ItemRec#item.lev),
				succ_fun = SuccCallBack
			},
			fun_item_api:add_items(Uid, Sid, Seq, Args)
	end.	

check_up_shenqi(Uid, ShenqiId) ->
	case fun_item_api:get_item_by_id2(Uid, ShenqiId) of
		[] -> {error, "check_data_error"};
		[Rec = #item{lev = CurrLv, star = Star}] ->
			MaxLv = data_shenqi:get_max_lv(Star),
			case CurrLv >= MaxLv of
				true -> {error, "error_common_reach_max_lv"};
				_ -> {ok, Rec}
			end
	end.


load_shenqi(Uid, ShenqiId) ->
	Rec = get_data(Uid),
	case fun_item_api:get_item_by_id2(Uid, ShenqiId) of
		[#item{type = Type}] -> 
			case data_item:get_data(Type) of
				#st_item_type{sort = ?ITEM_TYPE_ARTIFACT} ->
					%% 主关卡里使用的神器和竞技场使用的神器可以一样，不互斥
					Rec2 = Rec#t_shenqi{stage_used_id = ShenqiId},
					set_data(Rec2),
					fun_agent:send_to_scene({update_user_skill, fun_agent:get_usr_skills(Uid)}),
					fun_entourage:update_all_on_battle_hero_property(Uid);
				_ -> skip
			end;
		_ ->
			ok
	end.


req_up_star(Uid, Sid, Seq, ShenqiId, CostItemIdList) ->
	case check_up_star(Uid, ShenqiId, CostItemIdList) of
		{error, Reason} -> ?error_report(Sid, Reason, Seq);
		{ok, Cost, ItemRec} ->
			SuccFun = fun() ->
				ItemRec2 = ItemRec#item{star = ItemRec#item.star + 1},
				fun_item_api:update_item(Uid, ItemRec2),
				update_shenqi_illustration(Uid, ItemRec2#item.type, ItemRec2#item.star),
				fun_item:send_items_to_sid(Uid, Sid, [ItemRec2], Seq),
				send_update_notify(Sid, Seq, ShenqiId, ?SHENQI_CHANGE_TYPE_STAR)
			end,
			Args = #api_item_args{
				way      = ?ITEM_WAY_SHENQI_UP_STAR,
				spend    = Cost,
				succ_fun = SuccFun
			},
			fun_item_api:add_items(Uid, Sid, Seq, Args)
	end. 

get_can_cost_list(Uid, CostItemIdList) -> 
	ExcludeList = [Id || {Type, _, Id} <- mod_entourage_data:get_all_data(Uid), not lists:member(Type, ?USED_LIST)],
	[fun_item_api:get_item_by_id(Uid, Id) || Id <- CostItemIdList, 
											 not lists:member(Id, ExcludeList)].

check_up_star(Uid, ShenqiId, CostItemIdList) ->
	case fun_item_api:get_item_by_id2(Uid, ShenqiId) of
		[ItemRec = #item{lev = Lv, star = Star, type = ItemType}] ->
			#st_shenqi{
				type = ShenqiType, 
				max_star = MaxStar
			} = data_shenqi:get_base(ItemType),
			{LvLimit, NormalCost, SpecialCost} = data_shenqi:get_up_star_cnf(ItemType, Star),
			if
				Star >= MaxStar -> 
					{error, "common_star_full"};
				Lv < LvLimit ->
				 	{error, "common_lv_not_reached"};
				true -> 
					ProvideItemRecList = get_can_cost_list(Uid, CostItemIdList),
					case check_up_star_cost(ItemType, ShenqiType, ProvideItemRecList, NormalCost, SpecialCost) of
						false -> {error, "error_common_not_enough_material"};
						{ok, Cost} -> {ok, Cost, ItemRec}
					end
			end;
		_ -> 
			{error, "check_data_error"}
	end.

check_up_star_cost(ShenqiItemType, ShenqiType, ProvideItemRecList, NormalCost, SpecialCost) ->
	Fun1 = fun(ItemRec, NeedTuple) ->
		{CostType, NeedStar, NeedNum} = NeedTuple,
		#item{type = Type, star = EStar, num = Num} = ItemRec,
		Match = case CostType of
			0 -> %% 只要星级满足
				EStar == NeedStar;
			1 -> %% 本体
				Type == ShenqiItemType andalso EStar == NeedStar;
			2 -> %% 同类
				#st_shenqi{type = ShenqiType2} = data_shenqi:get_base(Type),
				ShenqiType == ShenqiType2 andalso EStar == NeedStar
		end,
		case Match of
			true -> 
				case Num >= NeedNum of
					true  -> 
						{used, Num - NeedNum};
					false -> 
						{used_out, {CostType, NeedStar, NeedNum - Num}}
				end;
			_ -> 
				no_match
		end
	end,
	case util_item:check_item_cost_by_fun(ProvideItemRecList, SpecialCost, Fun1) of
		false -> false;
		{Cost, _LeftProvideItemRecList} ->
			{ok, NormalCost ++ Cost}
	end.

req_shenqi_illustration(Uid, Sid, Seq) ->
	send_illustration_to_client(Uid, Sid, Seq).

update_shenqi_illustration(Uid, Type, Star) ->
	case data_shenqi_illustration:get_data(Type, Star) of
		0 -> skip;
		_ ->
			Rec = #t_shenqi{illustration = List} = get_data(Uid),
			Fun = fun({Type1, _}) ->
				if
					Type == Type1 -> true;
					true -> false
				end
			end,
			List1 = lists:filter(Fun, List),
			case lists:keyfind(Star, 2, List1) of
				false ->
					NewList = [{Type, Star} | List],
					NewRec = Rec#t_shenqi{illustration = NewList},
					set_data(NewRec);
				_ -> skip
			end
	end.

send_illustration_to_client(Uid, Sid, Seq) ->
	#t_shenqi{illustration = List} = get_data(Uid),
	Fun = fun({Etype,Star}) ->
		#pt_public_illustration_info{
			type = Etype,
			star = Star
		}
	end,
	Pt = #pt_shenqi_illustration{
		shenqi_illustration_list = lists:map(Fun, List)
	},
	?send(Sid, proto:pack(Pt, Seq)).

send_update_notify(Sid, Seq, ShenqiId, ChangeType) ->
	Pt = #pt_shenqi_update{chnage_type = ChangeType, id = ShenqiId},
	?send(Sid, proto:pack(Pt, Seq)).
