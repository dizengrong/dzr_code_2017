%% @doc gm活动：人民币每日礼包
-module (gm_act_rmb_package).
-include("common.hrl").
-compile([export_all]).

-define(THIS_TYPE, ?GM_ACTIVITY_RMB_PACKAGE).

%% 解析后台传来的数据
parse_config_datas_field(KvList) ->
	Id    = util:to_integer(fun_gm_activity_ex:get_json_value(KvList, "buy")),
	First = fun_gm_activity_ex:string_to_term(util:to_list(fun_gm_activity_ex:get_json_value(KvList, "firstTime"))),
	Daily = fun_gm_activity_ex:string_to_term(util:to_list(fun_gm_activity_ex:get_json_value(KvList, "everyday"))),
	{Id, First, Daily}.

%% 充值的处理，返回true将会发送info协议
on_recharge_help(ActivityRec, _Uid, UsrActivityRec, _RechargeDiamond, RechargeConfigID) ->
	RewardDatas = ActivityRec#gm_activity.reward_datas,
	ActData = UsrActivityRec#gm_activity_usr.act_data,
	case lists:keyfind(RechargeConfigID, 1, RewardDatas) of
		{RechargeConfigID, _First, _Daily} ->
			case lists:keyfind(RechargeConfigID, 1, ActData) of
				{RechargeConfigID, _} -> skip;
				_ ->
					ActData2 = lists:keystore(RechargeConfigID, 1, ActData, {RechargeConfigID, 1}),
					UsrActivityRec2 = UsrActivityRec#gm_activity_usr{act_data = ActData2},
					fun_gm_activity_ex:set_usr_activity_data(UsrActivityRec2),
					true
			end;
		_ -> skip
	end.

%% 消费金币的处理，返回true将会发送info协议
on_cost_coin(_Uid, _Cost, _UsrActivityRec) ->
	skip.

refresh_global_data(_ActivityRec) -> skip.

%% 发送info数据给前端
send_info_to_client(Uid, Sid, ActivityRec, UsrActivityRec) ->
	Pt = #pt_gm_act_rmb_package{
		startTime 		= ActivityRec#gm_activity.start_time + util_time:get_time_zone(ActivityRec#gm_activity.start_time),
		endTime   		= ActivityRec#gm_activity.end_time + util_time:get_time_zone(ActivityRec#gm_activity.end_time),
		desc 			= util:to_list(ActivityRec#gm_activity.act_des),
		datas     		= get_reward_state_list(Uid, ActivityRec, UsrActivityRec)
	},
	?send(Sid, proto:pack(Pt)).

%% 领取奖励的item_way日志
get_reward_way() -> ?ITEM_WAY_GM_ACT_RMB_PACKAGE.

%% 领取奖励的展示类型
get_fetched_reward_show_type() -> ?SHOW_REWARD_COMMON.

%% 领取奖励的判断
check_fetch_reward(_Uid, UsrActivityRec, ActivityRec, RewardId) ->
	RewardDatas = ActivityRec#gm_activity.reward_datas,
	FetchData = UsrActivityRec#gm_activity_usr.fetch_data,
	ActData = UsrActivityRec#gm_activity_usr.act_data,
	case lists:keyfind(RewardId, 1, RewardDatas) of
		{RewardId, First, Daily} -> 
			case lists:keyfind(RewardId, 1, ActData) of
				{RewardId, Days} ->
					case lists:keyfind(RewardId, 1, FetchData) of
						{RewardId, Times} ->
							if
								Days > Times ->
									FetchData2 = lists:keystore(RewardId, 1, FetchData, {RewardId, Days}),
									UsrActivityRec2 = UsrActivityRec#gm_activity_usr{fetch_data = FetchData2},
									Reward = [{T, N * (Days - Times), L} || {T, N, L} <- Daily],
									RewardItem = lists:map(fun fun_item_api:make_item_get_pt/1, Reward),
									{ok, UsrActivityRec2, RewardItem};
								true -> {error, "error_fetch_reward_already_fetched"}
							end;
						_ ->
							FetchData2 = lists:keystore(RewardId, 1, FetchData, {RewardId, Days}),
							UsrActivityRec2 = UsrActivityRec#gm_activity_usr{fetch_data = FetchData2},
							Reward1 = [{T, N * Days, L} || {T, N, L} <- Daily],
							Reward = lists:append(Reward1, First),
							RewardItem = lists:map(fun fun_item_api:make_item_get_pt/1, Reward),
							{ok, UsrActivityRec2, RewardItem}
					end;
				_ -> {error, "error_fetch_reward_not_reached"}
			end;
		_ -> {error, "error_fetch_reward_not_reached"}
	end.

on_start_activity(_ActType) -> skip.

on_refresh_part_data(Uid, ActivityRec, _UsrActivityRec) ->
	Now = util_time:unixtime(),
	case util_time:is_same_day(Now, ActivityRec#gm_activity.start_time) of
		true -> skip;
		_ ->
			Fun = fun({RewardId, _First, _Daily}) ->
				UsrActivityRec = fun_gm_activity_ex:get_usr_activity_data(Uid, ?THIS_TYPE),
				ActData = UsrActivityRec#gm_activity_usr.act_data,
				case lists:keyfind(RewardId, 1, ActData) of
					{RewardId, Days} ->
						ActData2 = lists:keystore(RewardId, 1, ActData, {RewardId, Days + 1}),
						UsrActivityRec2 = UsrActivityRec#gm_activity_usr{act_data = ActData2},
						fun_gm_activity_ex:set_usr_activity_data(UsrActivityRec2);
					_ -> skip
				end
			end,
			lists:foreach(Fun, ActivityRec#gm_activity.reward_datas)
	end.

%% 活动结束的处理
do_activity_end_help(_ActivityRec, UsrActivityRec) ->
	Uid = UsrActivityRec#gm_activity_usr.uid,
	case db:dirty_get(ply, Uid) of
		[#ply{sid=Sid} | _] ->
			Pt = #pt_gm_act_rmb_package{},
			?send(Sid, proto:pack(Pt));
		_ -> skip
	end.

%% ================================================================
%% =========================== 内部方法 ===========================
get_reward_state_list(_Uid, ActivityRec, UsrActivityRec) ->
	ActData = UsrActivityRec#gm_activity_usr.act_data,
	FetchData = UsrActivityRec#gm_activity_usr.fetch_data,
	Fun = fun({Id, First, Daily}) ->
		Multi = case lists:keyfind(Id, 1, ActData) of
			{Id, Days} ->
				case lists:keyfind(Id, 1, FetchData) of
					{Id, Times} -> Days - Times;
					_ -> Days
				end;
			_ -> 0
		end,
		Status = case lists:keyfind(Id, 1, ActData) of
			{Id, _} ->
				if
					Multi > 0 -> ?REWARD_STATE_CAN_FETCH;
					true -> ?REWARD_STATE_FETCHED
				end;
			_ -> ?REWARD_STATE_NOT_REACHED
		end,
		#pt_public_act_rmb_package_des{
			id 		= Id,
			reward 	= fun_item_api:make_item_pt_list(First),
			item 	= fun_item_api:make_item_pt_list(Daily),
			status 	= Status,
			multi 	= max(Multi, 1)
		}
	end,
	lists:map(Fun, ActivityRec#gm_activity.reward_datas).

handle(Msg) -> ?log_error("~p unhandled message:~p", [?MODULE, Msg]).

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