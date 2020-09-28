%% @doc gm活动：大转盘
-module (gm_act_turntable).
-include("common.hrl").
-compile([export_all]).

-define(THIS_TYPE, ?GM_ACTIVITY_TURNTANLE).

-define(ITEM_WAY,    0).
-define(DIAMOND_WAY, 1).
-define(ALL_WAY,     2).

%% 解析后台传来的数据
parse_config_datas_field(KvList) ->
	ItemNum 	= fun_gm_activity_ex:string_to_term( util:to_list(fun_gm_activity_ex:get_json_value(KvList, "num"))),
	ItemType 	= util:to_integer(fun_gm_activity_ex:get_json_value(KvList, "admissionTicket")),
	DiamondNum 	= util:to_integer(fun_gm_activity_ex:get_json_value(KvList, "diamonds")),
	Discount 	= util:to_integer(fun_gm_activity_ex:get_json_value(KvList, "discount")),
	Icon 		= util:to_list(fun_gm_activity_ex:get_json_value(KvList, "icon")),
	RefreshNum 	= util:to_integer(fun_gm_activity_ex:get_json_value(KvList, "refresh")),
	Exchange 	= fun_gm_activity_ex:string_to_term( util:to_list(fun_gm_activity_ex:get_json_value(KvList, "exchange"))),
	Reward1 	= fun_gm_activity_ex:string_to_term( util:to_list(fun_gm_activity_ex:get_json_value(KvList, "reward1"))),
	Reward2 	= fun_gm_activity_ex:string_to_term( util:to_list(fun_gm_activity_ex:get_json_value(KvList, "reward2"))),
	Reward3 	= fun_gm_activity_ex:string_to_term( util:to_list(fun_gm_activity_ex:get_json_value(KvList, "reward3"))),
	Reward4 	= fun_gm_activity_ex:string_to_term( util:to_list(fun_gm_activity_ex:get_json_value(KvList, "reward4"))),
	Reward5 	= fun_gm_activity_ex:string_to_term( util:to_list(fun_gm_activity_ex:get_json_value(KvList, "reward5"))),
	Reward6 	= fun_gm_activity_ex:string_to_term( util:to_list(fun_gm_activity_ex:get_json_value(KvList, "reward6"))),
	Reward7 	= fun_gm_activity_ex:string_to_term( util:to_list(fun_gm_activity_ex:get_json_value(KvList, "reward7"))),
	Reward8 	= fun_gm_activity_ex:string_to_term( util:to_list(fun_gm_activity_ex:get_json_value(KvList, "reward8"))),
	Reward9 	= fun_gm_activity_ex:string_to_term( util:to_list(fun_gm_activity_ex:get_json_value(KvList, "reward9"))),
	Reward10 	= fun_gm_activity_ex:string_to_term( util:to_list(fun_gm_activity_ex:get_json_value(KvList, "reward10"))),
	Reward11 	= fun_gm_activity_ex:string_to_term( util:to_list(fun_gm_activity_ex:get_json_value(KvList, "reward11"))),
	Reward12 	= fun_gm_activity_ex:string_to_term( util:to_list(fun_gm_activity_ex:get_json_value(KvList, "reward12"))),
	[
	 {item_num, ItemNum},
	 {item_type, ItemType},
	 {diamond_num, DiamondNum},
	 {discount, Discount},
	 {icon, Icon},
	 {refresh_num, RefreshNum},
	 {exchange, Exchange},
	 {reward, [Reward1,Reward2,Reward3,Reward4,Reward5,Reward6,Reward7,Reward8,Reward9,Reward10,Reward11,Reward12]}
	].

%% 充值的处理，返回true将会发送info协议
on_recharge_help(_ActivityRec, _Uid, _UsrActivityRec, _RechargeDiamond, _RechargeConfigID) ->
	skip.

%% 消费金币的处理，返回true将会发送info协议
on_cost_coin(_Uid, _Cost, _UsrActivityRec) ->
	skip.

refresh_global_data(_ActivityRec) -> skip.

req_draw(Uid, Sid, Type, ActivityRec) ->
	case Type == ?ITEM_WAY orelse Type == ?DIAMOND_WAY orelse Type == ?ALL_WAY of
		true ->
			UsrActivityRec = fun_gm_activity_ex:get_usr_activity_data(Uid, ?THIS_TYPE),
			ItemType 	= fun_gm_activity_ex:get_list_data_by_key(item_type, ActivityRec#gm_activity.reward_datas, 0),
			ItemNum 	= fun_gm_activity_ex:get_list_data_by_key(item_num, ActivityRec#gm_activity.reward_datas, []),
			DiamondNum 	= fun_gm_activity_ex:get_list_data_by_key(diamond_num, ActivityRec#gm_activity.reward_datas, 0),
			Discount 	= fun_gm_activity_ex:get_list_data_by_key(discount, ActivityRec#gm_activity.reward_datas, 0),
			Reward 		= fun_gm_activity_ex:get_list_data_by_key(reward, ActivityRec#gm_activity.reward_datas, []),
			UsrRewardList = fun_gm_activity_ex:get_list_data_by_key(usr_reward, UsrActivityRec#gm_activity_usr.act_data, []),
			{Times, Num} = get_item_num(UsrRewardList, ItemNum),
			AllNum = get_all_item_num(Times, ItemNum, 0),
			{Point, SpendItems} = case Type of
				?ITEM_WAY -> {Num, [{?ITEM_WAY_GM_ACT_TURNTABLE, ItemType, Num}]};
				?DIAMOND_WAY -> {Num, [{?ITEM_WAY_GM_ACT_TURNTABLE, ?RESOUCE_COIN_NUM, Num * DiamondNum}]};
				?ALL_WAY -> {AllNum, [{?ITEM_WAY_GM_ACT_TURNTABLE, ?RESOUCE_COIN_NUM, util:floor(DiamondNum * AllNum * Discount / 10)}]}
			end,
			Prob = fun_gm_activity_ex:get_list_data_by_key(usr_prob, UsrActivityRec#gm_activity_usr.act_data, []),
			Rand = util:rand(1, Prob),
			case Type of
				?ALL_WAY ->
					TItemList = get_all_item(UsrRewardList, []),
					AddItems = [{?ITEM_WAY_GM_ACT_TURNTABLE, T, N, [{strengthen_lev, L}]} || {T, N, L} <- TItemList],
					Succ = fun() ->
						Pt = #pt_gm_act_turntable_draw_result{
							item_list = fun_item_api:make_item_pt_list(TItemList)
						},
						refresh_data_reward_help(Reward, UsrActivityRec),
						set_point(Uid, Point),
						?send(Sid, proto:pack(Pt))
					end;
				_ ->
					{TItemList, Id, TProb} = make_draw_item(UsrRewardList, Rand, 0),
					AddItems = [{?ITEM_WAY_GM_ACT_TURNTABLE, T, N, [{strengthen_lev, L}]} || {T, N, L} <- TItemList],
					Succ = fun() ->
						case lists:keyfind(Id, 1, UsrRewardList) of
							{Id, ItemList, TProb, Effect, _} ->
								NewUsrRewardList = lists:keystore(Id, 1, UsrRewardList, {Id, ItemList, TProb, Effect, 1}),
								Fun = fun({_, _, _, _, Status}) ->
									Status == 0
								end,
								case lists:filter(Fun, NewUsrRewardList) of
									[] -> refresh_data_reward_help(Reward, UsrActivityRec);
									_ ->
										ActData = lists:keystore(usr_reward, 1, UsrActivityRec#gm_activity_usr.act_data, {usr_reward, NewUsrRewardList}),
										ActData2 = lists:keystore(usr_prob, 1, ActData, {usr_prob, Prob - TProb}),
										UsrActivityRec2 = UsrActivityRec#gm_activity_usr{act_data = ActData2},
										fun_gm_activity_ex:set_usr_activity_data(UsrActivityRec2)
								end,
								Pt = #pt_gm_act_turntable_draw_result{
									id 		  = Id,
									item_list = fun_item_api:make_item_pt_list(TItemList)
								},
								?send(Sid, proto:pack(Pt)),
								set_point(Uid, Point);
							_ -> skip
						end
					end
			end,
			fun_item_api:check_and_add_items(Uid, Sid, SpendItems, AddItems, Succ, undefined);
		_ -> skip
	end.

req_refresh(Uid, Sid, ActivityRec) ->
	RefreshNum = fun_gm_activity_ex:get_list_data_by_key(refresh_num, ActivityRec#gm_activity.reward_datas, 0),
	SpendItems = [{?ITEM_WAY_GM_ACT_TURNTABLE, ?RESOUCE_COIN_NUM, RefreshNum}],
	Succ = fun() ->
		UsrActivityRec = fun_gm_activity_ex:get_usr_activity_data(Uid, ?THIS_TYPE),
		Reward = fun_gm_activity_ex:get_list_data_by_key(reward, ActivityRec#gm_activity.reward_datas, []),
		refresh_data_reward_help(Reward, UsrActivityRec),
		UsrActivityRec2 = fun_gm_activity_ex:get_usr_activity_data(Uid, ?THIS_TYPE),
		send_info_to_client(Uid, Sid, ActivityRec, UsrActivityRec2)
	end,
	fun_item_api:check_and_add_items(Uid, Sid, SpendItems, [], Succ, undefined).

%% 发送info数据给前端
send_info_to_client(Uid, Sid, ActivityRec, UsrActivityRec) ->
	Pt = #pt_gm_act_turntable{
		startTime 		= ActivityRec#gm_activity.start_time + util_time:get_time_zone(ActivityRec#gm_activity.start_time),
		endTime   		= ActivityRec#gm_activity.end_time + util_time:get_time_zone(ActivityRec#gm_activity.end_time),
		desc 			= util:to_list(ActivityRec#gm_activity.act_des),
		datas     		= get_reward_state_list(Uid, ActivityRec, UsrActivityRec)
	},
	?send(Sid, proto:pack(Pt)).

%% 领取奖励的item_way日志
get_reward_way() -> ?ITEM_WAY_GM_ACT_TURNTABLE.

%% 领取奖励的展示类型
get_fetched_reward_show_type() -> ?SHOW_REWARD_COMMON.

%% 领取奖励的判断
check_fetch_reward(_Uid, UsrActivityRec, ActivityRec, RewardId) ->
	Exchange = fun_gm_activity_ex:get_list_data_by_key(exchange, ActivityRec#gm_activity.reward_datas, []),
	FetchData = UsrActivityRec#gm_activity_usr.fetch_data,
	Point = fun_gm_activity_ex:get_list_data_by_key(point, UsrActivityRec#gm_activity_usr.act_data, 0),
	case lists:keyfind(RewardId, 1, Exchange) of
		{RewardId, NeedPoint, ItemList, _Desc} -> 
			case lists:member(RewardId, FetchData) of
				true -> {error, "error_fetch_reward_already_fetched"};
				_ ->
					if
						Point >= NeedPoint ->
							FetchData2 = [RewardId | FetchData],
							UsrActivityRec2 = UsrActivityRec#gm_activity_usr{fetch_data = FetchData2},
							RewardItem = lists:map(fun fun_item_api:make_item_get_pt/1, ItemList),
							{ok, UsrActivityRec2, RewardItem};
						true -> {error, "error_fetch_reward_not_reached"}
					end
			end;
		_ -> {error, "error_fetch_reward_not_reached"}
	end.

on_start_activity(_ActType) -> skip.

on_refresh_part_data(_Uid, ActivityRec, UsrActivityRec) ->
	Now = util_time:unixtime(),
	case util_time:is_same_day(Now, ActivityRec#gm_activity.start_time) of
		true -> skip;
		_ ->
			Reward = fun_gm_activity_ex:get_list_data_by_key(reward, ActivityRec#gm_activity.reward_datas, []),
			refresh_data_reward_help(Reward, UsrActivityRec)
	end.

%% 活动结束的处理
do_activity_end_help(_ActivityRec, UsrActivityRec) ->
	Uid = UsrActivityRec#gm_activity_usr.uid,
	case db:dirty_get(ply, Uid) of
		[#ply{sid=Sid} | _] ->
			Pt = #pt_gm_act_turntable{},
			?send(Sid, proto:pack(Pt));
		_ -> skip
	end.

%% ================================================================
%% =========================== 内部方法 ===========================
get_reward_state_list(_Uid, ActivityRec, UsrActivityRec) ->
	ItemType 	= fun_gm_activity_ex:get_list_data_by_key(item_type, ActivityRec#gm_activity.reward_datas, 0),
	ItemNum 	= fun_gm_activity_ex:get_list_data_by_key(item_num, ActivityRec#gm_activity.reward_datas, []),
	DiamondNum 	= fun_gm_activity_ex:get_list_data_by_key(diamond_num, ActivityRec#gm_activity.reward_datas, 0),
	Discount 	= fun_gm_activity_ex:get_list_data_by_key(discount, ActivityRec#gm_activity.reward_datas, 0),
	Icon 		= fun_gm_activity_ex:get_list_data_by_key(icon, ActivityRec#gm_activity.reward_datas, []),
	RefreshNum 	= fun_gm_activity_ex:get_list_data_by_key(refresh_num, ActivityRec#gm_activity.reward_datas, 0),
	Exchange 	= fun_gm_activity_ex:get_list_data_by_key(exchange, ActivityRec#gm_activity.reward_datas, []),
	Reward 		= fun_gm_activity_ex:get_list_data_by_key(reward, ActivityRec#gm_activity.reward_datas, []),
	FetchData = UsrActivityRec#gm_activity_usr.fetch_data,
	Point = fun_gm_activity_ex:get_list_data_by_key(point, UsrActivityRec#gm_activity_usr.act_data, 0),
	UsrRewardList1 = fun_gm_activity_ex:get_list_data_by_key(usr_reward, UsrActivityRec#gm_activity_usr.act_data, []),
	UsrRewardList = case UsrRewardList1 of
		[] -> refresh_data_reward_help(Reward, UsrActivityRec);
		_ -> UsrRewardList1
	end,
	{Times, Num} = get_item_num(UsrRewardList, ItemNum),
	AllNum = get_all_item_num(Times, ItemNum, 0),
	% ?debug("ItemList = ~p",[make_reward_list_help(UsrRewardList)]),
	Pt = #pt_public_act_turntable_des{
		reward 		   = make_reward_list_help(UsrRewardList),
		item_cost	   = lists:map(fun fun_item_api:make_item_get_pt/1, [{ItemType, Num}]),
		diamond_cost   = lists:map(fun fun_item_api:make_item_get_pt/1, [{?RESOUCE_COIN_NUM, DiamondNum * Num}]),
		all_cost	   = lists:map(fun fun_item_api:make_item_get_pt/1, [{?RESOUCE_COIN_NUM, util:floor(DiamondNum * AllNum * Discount / 10)}]),
		all_cost_pre   = DiamondNum * AllNum,
		discount 	   = Icon,
		refresh_cost   = RefreshNum,
		point 		   = Point,
		point_exchange = DiamondNum,
		point_reward   = make_point_list_help(FetchData, Point, Exchange)
	},
	[Pt].

handle(Msg) -> ?log_error("~p unhandled message:~p", [?MODULE, Msg]).

make_usr_reward_help(Reward) ->
	Fun = fun({Id, RewardList, Prob, Effect}) ->
		Rand = util:rand(1, 10000),
		ItemList = make_draw_list(RewardList, Rand, 0),
		{Id, ItemList, Prob, Effect, 0}
	end,
	lists:map(Fun, Reward).

make_draw_item([], _Rand, _Acc) -> {[], 0, 0};
make_draw_item([{_Id, _ItemList, _Prob, _Effect, 1} | Rest], Rand, Acc) ->
	make_draw_item(Rest, Rand, Acc);
make_draw_item([{Id, ItemList, Prob, _Effect, _} | Rest], Rand, Acc) ->
	if
		Rand > Acc andalso Rand =< (Acc + Prob) -> {ItemList, Id, Prob};
		true -> make_draw_item(Rest, Rand, Acc + Prob)
	end.

make_draw_list([], _Rand, _Acc) -> [];
make_draw_list([{Type, Num, Lev, Prob} | Rest], Rand, Acc) ->
	if
		Rand > Acc andalso Rand =< (Acc + Prob) -> [{Type, Num, Lev}];
		true -> make_draw_list(Rest, Rand, Acc + Prob)
	end.

make_prop_help([], Acc) -> Acc;
make_prop_help([{_Id, _RewardList, Prob, _Effect} | Rest], Acc) ->
	make_prop_help(Rest, Acc + Prob).

make_reward_list_help(UsrRewardList) ->
	Fun = fun({Id, RewardList, _Prob, Effect, Status}) ->
		#pt_public_act_turntable_reward_list{
			id 		= Id,
			item 	= fun_item_api:make_item_pt_list(RewardList),
			effect 	= Effect,
			status 	= Status
		}
	end,
	lists:map(Fun, UsrRewardList).

make_point_list_help(FetchData, Point, Exchange) ->
	Fun = fun({Id, NeedPoint, ItemList, Desc}) ->
		Status = case lists:member(Id, FetchData) of
			true -> ?REWARD_STATE_FETCHED;
			_ ->
				if
					Point >= NeedPoint -> ?REWARD_STATE_CAN_FETCH;
					true -> ?REWARD_STATE_NOT_REACHED
				end
		end,
		#pt_public_act_turntable_point_reward_list{
			id 			= Id,
			need_point  = NeedPoint,
			reward 		= fun_item_api:make_item_pt_list(ItemList),
			desc 		= Desc,
			status 		= Status
		}
	end,
	lists:map(Fun, Exchange).

get_all_item([], Acc) -> Acc;
get_all_item([{_Id, _ItemList, _Prob, _Effect, 1} | Rest], Acc) ->
	get_all_item(Rest, Acc);
get_all_item([{_Id, ItemList, _Prob, _Effect, _} | Rest], Acc) ->
	get_all_item(Rest, lists:append(ItemList, Acc)).

get_item_num(UsrRewardList, ItemNum) ->
	Fun = fun({_Id, _RewardList, _Prob, _Effect, Status}) ->
		Status == 1
	end,
	Times = length(lists:filter(Fun, UsrRewardList)) + 1,
	case lists:keyfind(Times, 1, ItemNum) of
		{Times, Num} -> {Times, Num};
		_ -> {100, 10000}
	end.

get_all_item_num(Times, ItemNum, Acc) ->
	case lists:keyfind(Times, 1, ItemNum) of
		{Times, Num} -> get_all_item_num(Times + 1, ItemNum, Num + Acc);
		_ -> Acc
	end.

set_point(Uid, Point) ->
	UsrActivityRec = fun_gm_activity_ex:get_usr_activity_data(Uid, ?THIS_TYPE),
	OldPoint = fun_gm_activity_ex:get_list_data_by_key(point, UsrActivityRec#gm_activity_usr.act_data, 0),
	ActData = lists:keystore(point, 1, UsrActivityRec#gm_activity_usr.act_data, {point, OldPoint + Point}),
	UsrActivityRec2 = UsrActivityRec#gm_activity_usr{act_data = ActData},
	fun_gm_activity_ex:set_usr_activity_data(UsrActivityRec2),
	UsrActivityRec2.

refresh_data_reward_help(Reward, UsrActivityRec) ->
	List = make_usr_reward_help(Reward),
	ActData = lists:keystore(usr_reward, 1, UsrActivityRec#gm_activity_usr.act_data, {usr_reward, List}),
	Prob = make_prop_help(Reward, 0),
	ActData2 = lists:keystore(usr_prob, 1, ActData, {usr_prob, Prob}),
	UsrActivityRec2 = UsrActivityRec#gm_activity_usr{act_data = ActData2},
	fun_gm_activity_ex:set_usr_activity_data(UsrActivityRec2),
	List.
%% =============================================================================
%% ========================= 测试方法 ==========================================
% world_svr:debug_call(agent_mng, fun() -> gm_act_return_investment:test_set_config() end).
% world_svr:debug_call(agent_mng, fun() -> gm_act_return_investment:test_del_config() end).
% test_set_config() ->
% 	ActivityRec = #gm_activity{
% 		act_id       = ?THIS_TYPE,
% 		act_name     = "name",
% 		type         = ?THIS_TYPE,
% 		start_time   = util:unixtime() + 10,
% 		end_time     = util:unixtime() + 20000,
% 		close_time   = util:unixtime() + 25000,
% 		act_des      = "ActDes",
% 		setting      = [],
% 		reward_datas = util:term_to_string(test_reward_datas(?THIS_TYPE))
% 	},
% 	db:insert(ActivityRec),
% 	fun_gm_activity_ex:activity_config_help(ActivityRec),
% 	ok.	

% test_del_config() ->
% 	fun_gm_activity_ex:del_config(?THIS_TYPE, ?THIS_TYPE).

% test_reward_datas(?THIS_TYPE) ->
% 	[{
% 		2000,
% 		[
% 			{1,[{2,10}],"第1天"},
% 			{2,[{1,10000}],"第2天"},
% 			{3,[{9,10000}],"第3天"},
% 			{4,[{11,100}],"第4天"},
% 			{5,[{2,20}],"第5天"},
% 			{6,[{1,10000}],"第6天"},
% 			{7,[{9003,5}],"第7天"}
% 		]
% 	}].