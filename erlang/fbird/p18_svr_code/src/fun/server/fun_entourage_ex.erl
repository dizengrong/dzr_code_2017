%% @doc 英雄相关的升级、突破、升星等逻辑处理模块
-module (fun_entourage_ex).
-include("common.hrl").

-export([
	req_up_lv/4, req_up_grade/4, req_up_star/5
]).

-define (EDATA_TYPE_LV   , 1).
-define (EDATA_TYPE_GRADE, 2).
-define (EDATA_TYPE_STAR , 3).


send_update_notify(Sid, Seq, EntourageId, EDataType) ->
	Pt = #pt_entourage_update{chnage_type = EDataType, eid = EntourageId},
	?send(Sid, proto:pack(Pt, Seq)).

%% =================================== 升级 ==================================== 
req_up_lv(Uid, Sid, Seq, EntourageId) ->
	case check_up_lv(Uid, EntourageId) of
		{error, Reason} -> ?error_report(Sid, Reason, Seq);
		{ok, EntourageRec = #item{lev = Lv}} ->
			SuccFun = fun() -> 
				EntourageRec2 = EntourageRec#item{lev = Lv + 1},
				fun_item_api:update_item(Uid, EntourageRec2),
				fun_item:send_items_to_sid(Uid, Sid, [EntourageRec2], Seq),
				fun_agent_property:add_prop(Uid, EntourageId, prop_class_lev),
				send_update_notify(Sid, Seq, EntourageId, ?EDATA_TYPE_LV)
			end,
			Args = #api_item_args{
				way      = ?ITEM_WAY_HERO_LV_UP,
				spend    = data_entourage_ex:get_lv_up_cost(Lv),
				succ_fun = SuccFun
			},
			fun_item_api:add_items(Uid, Sid, Seq, Args)
	end. 


check_up_lv(Uid, EntourageId) ->
	case fun_entourage:get_entourage(Uid, EntourageId) of
		EntourageRec = #item{lev = Lv} ->
			MaxLv = util_entourage:get_max_lv(EntourageRec),
			case Lv >= MaxLv of
				true -> {error, "hero_current_lv_full"};
				_ ->  
					{ok, EntourageRec}
			end;
		_ -> 
			{error, "check_data_error"}
	end.

%% =================================== 升品 ==================================== 
req_up_grade(Uid, Sid, Seq, EntourageId) ->
	case check_up_grade(Uid, EntourageId) of
		{error, Reason} -> ?error_report(Sid, Reason, Seq);
		{ok, EntourageRec = #item{type = Etype, break = Grade, star = Star}} ->
			SuccFun = fun() -> 
				EntourageRec2 = EntourageRec#item{break = Grade + 1},
				fun_item_api:update_item(Uid, EntourageRec2),
				fun_item:send_items_to_sid(Uid, Sid, [EntourageRec2], Seq),
				fun_agent_property:add_prop(Uid, EntourageId, prop_class_grade),
				check_and_trigger_skill_add_prop(Uid, EntourageId, Etype, Grade, Star, EntourageRec2#item.break, Star),
				send_update_notify(Sid, Seq, EntourageId, ?EDATA_TYPE_GRADE),
				SkillList = fun_entourage:get_entourage_skill(Uid, EntourageId, Etype),
				PassiveSkill = fun_entourage:get_entourage_passive_skill(Uid, EntourageId, Etype),
				fun_agent:send_to_scene({update_hero_skill, EntourageId + ?ETRG_OFF, SkillList, PassiveSkill})
			end,
			Args = #api_item_args{
				way      = ?ITEM_WAY_HERO_GRADE_UP,
				spend    = data_entourage_ex:get_lv_grade_cost(Grade),
				succ_fun = SuccFun
			},
			fun_item_api:add_items(Uid, Sid, Seq, Args)
	end. 

check_up_grade(Uid, EntourageId) ->
	case fun_entourage:get_entourage(Uid, EntourageId) of
		EntourageRec = #item{break = Grade, lev = Lv, type = EType, star = Star} ->
			#st_entourage_config{max_grade = MaxGrade} = data_entourage:get_data(EType),
			LvLimit = data_entourage_ex:get_grade_lv_limit(Grade),
			CurrMaxGrade = data_entourage_ex:get_star_max_grade(Star),
			if 
				Grade >= MaxGrade -> 
					{error, "hero_grade_full"};
				LvLimit > Lv -> 
					{error, "hero_lv_not_reached"};
				Grade >= CurrMaxGrade -> 
					{error, "hero_grade_full"};
				true -> 
					{ok, EntourageRec}
			end;
		_ -> 
			{error, "check_data_error"}
	end.

%% =================================== 升星 ==================================== 
req_up_star(Uid, Sid, Seq, EntourageId, CostItemIdList) ->
	case check_up_star(Uid, EntourageId, CostItemIdList) of
		{error, Reason} -> ?error_report(Sid, Reason, Seq);
		{ok, Cost, ReturnBack, ReturnEquips, EntourageRec = #item{type = Etype, break = Grade, star = Star}} ->
			SuccFun = fun() -> 
				Fun = fun(EquipId) -> 
					ItemRec = fun_item_api:get_item_by_id(Uid, EquipId),
					ItemRec2 = ItemRec#item{owner = ItemRec#item.owner - 1},
					fun_item_api:update_item(Uid, ItemRec2),
					ItemRec2
				end,
				ChangeItemList = [Fun(EquipId) || EquipId <- ReturnEquips],
				NewStar = Star + 1,
				EntourageRec2 = EntourageRec#item{star = NewStar},
				fun_item_api:update_item(Uid, EntourageRec2),
				fun_item:send_items_to_sid(Uid, Sid, [EntourageRec2 | ChangeItemList], Seq),
				fun_agent_property:add_prop(Uid, EntourageId, prop_class_star),
				check_and_trigger_skill_add_prop(Uid, EntourageId, Etype, Grade, Star, Grade, EntourageRec2#item.star),
				fun_entourage:update_hero_illustration(Uid, Etype, EntourageRec2#item.star),
				send_update_notify(Sid, Seq, EntourageId, ?EDATA_TYPE_STAR),
				fun_count:on_count_event(Uid, Sid, ?TASK_HERO_STAR_UP, NewStar, 1),
				fun_agent:handle_to_scene(mod_scene_entourage, {scene_hero_prop_change, Uid, ?HERO_STAR_CHANGE, EntourageId, NewStar})
			end,
			Args = #api_item_args{
				way      = ?ITEM_WAY_HERO_STAR_UP,
				spend    = Cost,
				add      = ReturnBack,
				succ_fun = SuccFun
			},
			fun_item_api:add_items(Uid, Sid, Seq, Args)
	end. 

check_up_star(Uid, EntourageId, CostItemIdList) ->
	case fun_entourage:get_entourage(Uid, EntourageId) of
		EntourageRec = #item{break = _Grade, lev = Lv, star = Star, type = EType} ->
			#st_entourage_config{
				% max_grade = MaxGrade, 
				max_star = MaxStar
			} = data_entourage:get_data(EType),
			LvLimit = data_entourage_ex:get_star_up_min_lv(Star),
			if
				LvLimit == undefined -> 
					{error, "check_data_error"};
				% Grade < MaxGrade ->
				% 	{error, "hero_up_star_grade_not_full"};
				Star >= MaxStar -> 
					{error, "hero_star_full"};
				Lv < LvLimit ->
				 	{error, "hero_lv_not_reached"};
				true -> 
					OnBattleHeros = fun_entourage:get_battle_entourage(Uid) ++ fun_arena:get_all_on_battled_heros(Uid),
					ProvideItemRecList = [fun_entourage:get_entourage(Uid, ItemId) || ItemId <- CostItemIdList, 
										  not lists:keymember(ItemId, 1, OnBattleHeros)],
					case check_up_star_cost(EType, Star, ProvideItemRecList) of
						false -> {error, "error_common_not_enough_material"};
						{ok, Cost, ReturnBack, AccReturnEquip} ->
							{ok, Cost, ReturnBack, AccReturnEquip, EntourageRec}
					end
			end;
		_ -> 
			{error, "check_data_error"}
	end.

%% 检查固定消耗和可变消耗
check_up_star_cost(EType, Star, ProvideItemRecList) ->
	{NeedRegularEntourage, NeedVarEntourage, OtherCost} = data_entourage_ex:get_star_up_cost(EType, Star + 1),
	Fun1 = fun(ItemRec, NeedTuple) ->
		{NeedType, NeedStar, NeedNum} = NeedTuple,
		#item{type = Type, star = EStar, num = Num} = ItemRec,
		case Type == NeedType andalso EStar == NeedStar of
			true -> 
				case Num >= NeedNum of
					true  -> 
						{used, Num - NeedNum};
					false -> 
						{used_out, {NeedType, NeedStar, NeedNum - Num}}
				end;
			_ -> 
				no_match
		end
	end,

	Fun2 = fun(ItemRec, NeedTuple) ->
		{NeedRace, NeedStar, NeedNum} = NeedTuple,
		#item{type = Type, star = EStar, num = Num} = ItemRec,
		#st_entourage_config{race = Race} = data_entourage:get_data(Type),
		case NeedRace == Race andalso EStar == NeedStar of
			true -> 
				case Num >= NeedNum of
					true  -> 
						{used, Num - NeedNum};
					false -> 
						{used_out, {NeedRace, NeedStar, NeedNum - Num}}
				end;
			_ -> 
				no_match
		end
	end,
	case util_item:check_item_cost_by_fun(ProvideItemRecList, NeedRegularEntourage, Fun1) of
		false -> false;
		{Cost1, LeftProvideItemRecList} ->
			case util_item:check_item_cost_by_fun(LeftProvideItemRecList, NeedVarEntourage, Fun2) of
				false -> false;
				{Cost2, _} ->
					Cost = Cost1 ++ Cost2,
					{ReturnBack, AccReturnEquip} = get_return_back(ProvideItemRecList, Cost, [], []),
					{ok, OtherCost ++ Cost, ReturnBack, AccReturnEquip}
			end
	end.

get_return_back(ProvideItemRecList, [{{item_id, ItemId}, Num} | Rest], AccReturn, AccReturnEquip) -> 
	#item{lev = Lv, break = Grade, equip_list = EquipList} = lists:keyfind(ItemId, #item.id, ProvideItemRecList),
	Fun1 = fun(Count, Acc) ->
		Costs = [{T, N * Num} || {T, N} <- data_entourage_ex:get_lv_up_cost(Count)],
		util_list:add_and_merge_list(Acc, Costs, 1, 2)
	end,
	LvReturn = lists:foldl(Fun1, AccReturn, lists:seq(1, Lv)),

	Fun2 = fun(Count, Acc) ->
		Costs = [{T, N * Num} || {T, N} <- data_entourage_ex:get_lv_grade_cost(Count)],
		util_list:add_and_merge_list(Acc, Costs, 1, 2)
	end,
	GradeReturn = lists:foldl(Fun2, LvReturn, lists:seq(0, Grade)),
	AccReturnEquip2 = EquipList ++ AccReturnEquip,
	get_return_back(ProvideItemRecList, Rest, LvReturn ++ GradeReturn, AccReturnEquip2);

get_return_back(_ProvideItemRecList, [], Acc, AccReturnEquip) -> 
	Rate = util:get_data_para_num(8),
	{[{T, util:floor(N*Rate/100)} || {T, N} <- Acc], AccReturnEquip}.


check_and_trigger_skill_add_prop(Uid, EntourageId, Etype, Grade, Star, NewGrade, NewStar) ->
	#st_entourage_skill{id = OldId} = data_entourage_skill:get_data(Etype, Grade, Star),
	#st_entourage_skill{id = NewId} = data_entourage_skill:get_data(Etype, NewGrade, NewStar),
	case OldId == NewId of
		true ->
			skip;
		_ -> 
			fun_agent_property:add_prop(Uid, EntourageId, prop_class_skill)
	end.

