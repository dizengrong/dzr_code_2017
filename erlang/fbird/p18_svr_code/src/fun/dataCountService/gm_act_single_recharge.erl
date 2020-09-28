%% @doc gm活动：单笔充值
-module (gm_act_single_recharge).
-include("common.hrl").
-compile([export_all]).

-define(THIS_TYPE, ?GM_ACTIVITY_SINGLE_RECHARGE).

%% 解析后台传来的数据
parse_config_datas_field(KvList) ->
	Id 			= util:to_integer(fun_gm_activity_ex:get_json_value(KvList, "id")),
	Type 		= util:to_integer(fun_gm_activity_ex:get_json_value(KvList, "type")),
	Items 		= fun_gm_activity_ex:string_to_term(util:to_list(fun_gm_activity_ex:get_json_value(KvList, "items"))),
	Times 		= util:to_integer(fun_gm_activity_ex:get_json_value(KvList, "times")),
	SystemType  = util:to_integer(fun_gm_activity_ex:get_json_value(KvList, "system_type")),
	{Id, Type, Items, Times, SystemType}.

%% 充值的处理，返回true将会发送info协议
on_recharge_help(_ActivityRec, _Uid, UsrActivityRec, _RechargeDiamond, RechargeConfigID) ->
	ActData = UsrActivityRec#gm_activity_usr.act_data,
	ChargeList = fun_gm_activity_ex:get_list_data_by_key(charge_record, UsrActivityRec#gm_activity_usr.act_data, []),
	NewList = case lists:keyfind(RechargeConfigID, 1, ChargeList) of
		{RechargeConfigID, Num} -> lists:keystore(RechargeConfigID, 1, ChargeList, {RechargeConfigID, Num + 1});
		_ -> lists:keystore(RechargeConfigID, 1, ChargeList, {RechargeConfigID, 1})
	end,
	ActData2 = lists:keystore(charge_record, 1, ActData, {charge_record, NewList}),
	UsrActivityRec2 = UsrActivityRec#gm_activity_usr{act_data = ActData2, act_time = util_time:unixtime()},
	fun_gm_activity_ex:set_usr_activity_data(UsrActivityRec2),
	true.

%% 消费金币的处理，返回true将会发送info协议
on_cost_coin(_Uid, _Cost, _UsrActivityRec) ->
	skip.

%% 发送info数据给前端
send_info_to_client(Uid, Sid, ActivityRec, UsrActivityRec) ->
	Pt = #pt_gm_act_single_recharge{
		startTime = ActivityRec#gm_activity.start_time + util_time:get_time_zone(ActivityRec#gm_activity.start_time),
		endTime   = ActivityRec#gm_activity.end_time + util_time:get_time_zone(ActivityRec#gm_activity.end_time),
		desc 	  = util:to_list(ActivityRec#gm_activity.act_des),
		datas     = get_reward_state_list(Uid, ActivityRec, UsrActivityRec)
	},
	?send(Sid, proto:pack(Pt)).

%% 领取奖励的item_way日志
get_reward_way() -> ?ITEM_WAY_SINGLE_RECHARGE.

%% 领取奖励的展示类型
get_fetched_reward_show_type() -> ?SHOW_REWARD_COMMON.

%% 领取奖励的判断
check_fetch_reward(_Uid, UsrActivityRec, ActivityRec, RewardId) ->
	{RewardId, _, Items, Times, _} = lists:keyfind(RewardId, 1, ActivityRec#gm_activity.reward_datas),
	ChargeList = fun_gm_activity_ex:get_list_data_by_key(charge_record, UsrActivityRec#gm_activity_usr.act_data, []),
	FetchData = UsrActivityRec#gm_activity_usr.fetch_data,
	case lists:keyfind(RewardId, 1, ChargeList) of
		{RewardId, ChargeTimes} ->
			case lists:keyfind(RewardId, 1, FetchData) of
				{RewardId, FetchTimes} when FetchTimes < Times andalso ChargeTimes > FetchTimes -> 
					FetchData2 = lists:keystore(RewardId, 1, FetchData, {RewardId, FetchTimes + 1}),
					UsrActivityRec2 = UsrActivityRec#gm_activity_usr{fetch_data = FetchData2},
					RewardItem = lists:map(fun fun_item_api:make_item_get_pt/1, Items),
					{ok, UsrActivityRec2, RewardItem};
				false ->
					FetchData2 = lists:keystore(RewardId, 1, FetchData, {RewardId, 1}),
					UsrActivityRec2 = UsrActivityRec#gm_activity_usr{fetch_data = FetchData2},
					RewardItem = lists:map(fun fun_item_api:make_item_get_pt/1, Items),
					{ok, UsrActivityRec2, RewardItem};
				_ -> {error, "error_fetch_reward_already_fetched"}
			end;
		_ -> {error, "error_fetch_reward_not_reached"}
	end.

%% 活动结束的处理
do_activity_end_help(ActivityRec, UsrActivityRec) ->
	Uid = UsrActivityRec#gm_activity_usr.uid,
	do_activity_end_help2(Uid, ActivityRec, UsrActivityRec),
	case db:dirty_get(ply, Uid) of
		[#ply{sid=Sid} | _] ->
			Pt = #pt_gm_act_single_recharge{},
			?send(Sid, proto:pack(Pt));
		_ -> skip
	end.

do_activity_end_help2(Uid, ActivityRec, UsrActivityRec) ->
	ChargeList = fun_gm_activity_ex:get_list_data_by_key(charge_record, UsrActivityRec#gm_activity_usr.act_data, []),
	FetchData = UsrActivityRec#gm_activity_usr.fetch_data,
	Fun = fun({Id, _, Items, Times, _}) ->
		ChargeTimes = case lists:keyfind(Id, 1, ChargeList) of
			{Id, Num} -> Num;
			_ -> 0
		end,
		PickTimes = case lists:keyfind(Id, 1, FetchData) of
			{Id, Num1} -> Num1;
			_ -> 0
		end,
		case PickTimes < Times andalso ChargeTimes > PickTimes of
			true ->
				RewardNum = ChargeTimes - PickTimes,
				RewardItem = [{T, N * RewardNum, L} || {T, N, L} <- Items],
				fun_gm_activity_ex:send_not_fetch_mail(?GM_ACTIVITY_SINGLE_RECHARGE, Uid, ActivityRec#gm_activity.act_name, fun_item_api:make_item_pt_list(RewardItem), 1);
			_ -> skip
		end
	end,
	lists:foreach(Fun, ActivityRec#gm_activity.reward_datas).

%% ================================================================
%% =========================== 内部方法 ===========================
get_reward_state_list(_Uid, ActivityRec, UsrActivityRec) ->
	ChargeList = fun_gm_activity_ex:get_list_data_by_key(charge_record, UsrActivityRec#gm_activity_usr.act_data, []),
	FetchData = UsrActivityRec#gm_activity_usr.fetch_data,
	Fun = fun({Id, Type, Items, Times, SystemType}) ->
		ChargeTimes = case lists:keyfind(Id, 1, ChargeList) of
			{Id, Num} -> Num;
			_ -> 0
		end,
		PickTimes = case lists:keyfind(Id, 1, FetchData) of
			{Id, Num1} -> Num1;
			_ -> 0
		end,
		#pt_public_single_recharge_des{
			id 			 = Id,
			type 		 = Type,
			items 		 = fun_item_api:make_item_pt_list(Items),
			system_type  = SystemType,
			charge_times = ChargeTimes,
			pick_times 	 = PickTimes,
			max_times 	 = Times
		}
	end,
	lists:map(Fun, ActivityRec#gm_activity.reward_datas).

%% =============================================================================
%% ========================= 测试方法 ==========================================
% world_svr:debug_call(agent_mng, fun() -> gm_act_single_recharge:test_set_config() end).
% world_svr:debug_call(agent_mng, fun() -> gm_act_single_recharge:test_del_config() end).
test_set_config() ->
	ActivityRec = #gm_activity{
		act_id       = ?THIS_TYPE,
		act_name     = "name",
		type         = ?THIS_TYPE,
		start_time   = util:unixtime() + 10,
		end_time     = util:unixtime() + 20000,
		close_time   = util:unixtime() + 25000,
		act_des      = "ActDes",
		setting      = [],
		reward_datas = util:term_to_string(test_reward_datas(?THIS_TYPE))
	},
	db:insert(ActivityRec),
	fun_gm_activity_ex:activity_config_help(ActivityRec),
	ok.	

test_del_config() ->
	fun_gm_activity_ex:del_config(?THIS_TYPE, ?THIS_TYPE).

test_reward_datas(?THIS_TYPE) ->
	[
		{1,120,[{2,10,0}],5,1},
		{2,240,[{2,20,0}],5,1},
		{3,360,[{2,30,0}],5,1}
	].