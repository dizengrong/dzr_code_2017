%% @doc 原宝石系统第二版，后改成符文系统
-module(fun_gem).
-include("common.hrl").
-export([
	add_lev_gem/3,update_gem_lev/6,up_gem_prop/1,req_all_gem_data/3,
	send_gem_to_sid/3,send_gem_to_sid/4,get_gem_max_lv/1,get_total_gem_lv/1
]).


%% =============================================================================
get_data(Uid) -> 
	case mod_role_tab:lookup(t_gem, Uid) of
		[] -> #t_gem{uid = Uid};
		[Rec] -> Rec
	end.

set_data(Rec) -> 
	mod_role_tab:insert(Rec#t_gem.uid, Rec).
%% =============================================================================

%%自动添加宝石（等级达到）
add_lev_gem(Uid,Sid,UsrLev) -> 
	on_usr_lv_open_gems(Uid, Sid,UsrLev).

on_usr_lv_open_gems(Uid,Sid,UsrLev)->
	{LvIndex, OpenGems} = data_gem:lv_open_gems(UsrLev),
	case get(gem_open_lv_index) of
		LvIndex -> skip; %% 已经计算过了，就不重复计算了
		_ ->
			put(gem_open_lv_index, LvIndex),
			Rec = get_data(Uid),
			Fun = fun(GemId, Acc)->
				case check_can_open(Rec,GemId,UsrLev) of
					true -> [GemId | Acc];
					_ -> Acc
				end
			end,
			NewOpenGems = lists:foldl(Fun, [], OpenGems),
			case NewOpenGems of
				[] -> skip;
				_  ->
					NewList = [{GemId, 1, 0} || GemId <- NewOpenGems],
					Rec2 = Rec#t_gem{gem_list = NewList ++ Rec#t_gem.gem_list},
					set_data(Rec2),
					send_gem_to_sid(Sid, Uid, NewList, 0)
			end
	end.


check_can_open(Rec,GemId,UsrLev) ->
	#st_gem_config{lev=Open_Lev} = data_gem:get_data(GemId),
	if 
		UsrLev >= Open_Lev->
			case lists:keymember(GemId, 1, Rec#t_gem.gem_list) of
				false ->
					true;
				_ -> false
			end;
		true -> false
	end.


%%获取玩家所有宝石数据
req_all_gem_data(Uid,Seq,Sid)-> 
	Rec = get_data(Uid),
	GemInfo = [{GemId, Lv, Exp} || {GemId, Lv, Exp} <- Rec#t_gem.gem_list],
	send_gem_to_sid(Sid, Uid, GemInfo, Seq).


%%获取这个物品可以加多少经验
get_item_type_add_exp(_ItemId) -> 0.
	% #st_item_type{att1=10086,val1= Val1} = data_item:get_data(ItemId),
	% Val1.


check_up_gem(Uid, GemId, ItemType, UpType) ->
	Rec = get_data(Uid),
	MaxLv = data_diamon_exp:max_lv(),
	case lists:keyfind(GemId, 1, Rec#t_gem.gem_list) of
		false -> {error, "check_data_error"};
		{_, Lv, Exp} when Lv < MaxLv -> 
			#st_gem_config{upgradeQuantity = UpgradeQuantity} = data_gem:get_data(GemId),
			case lists:member(ItemType, UpgradeQuantity) of
				true ->
					Num = fun_item:get_item_num_by_type(Uid, ItemType),
					case Num == 0 of
						true -> {error, "not_enough_item", [ItemType]};
						_ -> 
							Num2 = ?_IF(UpType == 0, 1, Num),
							{ok, Rec, Lv, Exp, Num2}
					end;
				_ -> 
					{error, "check_data_error"}
			end;
		_ -> {error, "error_common_lv_full"}
	end.


%%升级宝石
update_gem_lev(Uid,Sid,Seq,GemId,ItemType,UpType)->
	case check_up_gem(Uid, GemId, ItemType, UpType) of
		{error, Reason} -> 
			?error_report(Sid, Reason);
		{error, Reason, ReasonData} ->
			?error_report(Sid, Reason, 0, ReasonData);
		{ok, Rec, Lv, Exp, ItemNum} ->
			ExpVal = get_item_type_add_exp(ItemType),
			MaxLv = data_diamon_exp:max_lv(),
			{CostNum,NewLev,NewExp} = onekey_count(Lv, MaxLv, ItemNum, Exp, ExpVal, 0),
			Costs = [{?ITEM_WAY_GEM, ItemType, CostNum}],
			SuccFun = fun() -> 
				Gems = lists:keystore(GemId, 1, Rec#t_gem.gem_list, {GemId, NewLev, NewExp}),
				Rec2 = Rec#t_gem{gem_list = Gems},
				set_data(Rec2),
				send_gem_to_sid(Sid,Uid,[{GemId,NewLev,NewExp}],Seq)
			end,
			fun_item_api:check_and_add_items(Uid, Sid, Costs, [], SuccFun)
	end.


onekey_count(Lev, MaxLv, _ItemNum, Exp, _ExpVal, SpendNum) when Lev >= MaxLv -> 
	{SpendNum,Lev,Exp};
onekey_count(Lev, MaxLv, ItemNum, Exp, ExpVal,SpendNum) ->
	#st_diamon_exp{needExp = NeedExp} = data_diamon_exp:get_data(Lev),
	if
		Exp >= NeedExp -> onekey_count(Lev + 1, MaxLv, ItemNum, Exp - NeedExp, ExpVal, SpendNum);
		ItemNum =< 0 -> {SpendNum,Lev,Exp};
		true ->
			CountExp = NeedExp - Exp,
			Num1 = util:ceil(CountExp / ExpVal),
			Num = if
					  ItemNum >= Num1 -> Num1;
					  true -> ItemNum
				  end,
					  
			AddExp = Num * ExpVal,
			onekey_count(Lev, MaxLv, ItemNum - Num , Exp + AddExp, ExpVal,SpendNum + Num)
	end.

send_gem_to_sid(Sid,Uid,GemList) -> send_gem_to_sid(Sid,Uid,GemList,0).
send_gem_to_sid(Sid,_Uid,GemList,Seq)->
	Fun = fun({GemId,GemLev,GemExp}) ->	
		#pt_public_gem_list{gem_id=GemId,gem_exp=GemExp,gem_lev=GemLev}
	end,
	Pt = #pt_return_gem_update{gem_list=lists:map(Fun, GemList)},
	?send(Sid,proto:pack(Pt, Seq)).


%%更新宝石所加的属性
up_gem_prop(Uid)->
	Rec = get_data(Uid),
	FunProp = fun({GemId,GemLev,_},Acc)->
		  #st_gem_config{property_type= AttrId,property_value= AttrVal} = data_gem:get_data(GemId),
		  #st_diamon_exp{propGrow=PropGrow} = data_diamon_exp:get_data(GemLev),
		  Val = util:ceil(AttrVal*PropGrow),
		  util_list:add_and_merge_list(Acc, [{AttrId,Val}], 1, 2)
	end,
	lists:foldl(FunProp, [], Rec#t_gem.gem_list).


get_gem_max_lv(Uid) ->
	Rec = get_data(Uid),
	lists:max([GemLev || {_, GemLev, _} <- Rec#t_gem.gem_list]).

%% 获取所有的总等级
get_total_gem_lv(Uid) ->
	Rec = get_data(Uid),
	get_total_gem_lv(Uid, Rec#t_gem.gem_list, 0).

get_total_gem_lv(Uid, [{_, Lv, _} | Rest], AccLv) -> 
	get_total_gem_lv(Uid, Rest, AccLv + Lv);
get_total_gem_lv(_Uid, [], AccLv) -> AccLv.