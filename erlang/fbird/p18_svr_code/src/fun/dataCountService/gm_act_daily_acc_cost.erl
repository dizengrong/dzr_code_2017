%% @doc gm活动：每日累积消费
-module (gm_act_daily_acc_cost).
-include("common.hrl").
-compile([export_all]).

%% 解析后台传来的数据
parse_config_datas_field(KvList) ->
	Id       = util:to_integer(fun_gm_activity_ex:get_json_value(KvList, "id")), 
	NeedCost = util:to_integer(fun_gm_activity_ex:get_json_value(KvList, "condition")), 
	Items    = fun_gm_activity_ex:string_to_term(util:to_list(fun_gm_activity_ex:get_json_value(KvList, "items"))),
	{Id, NeedCost, Items}.

%% 充值的处理，返回true将会发送info协议
on_recharge_help(_ActivityRec, _Uid, _UsrActivityRec, _RechargeDiamond, _RechargeConfigID) ->
	skip.

%% 消费金币的处理，返回true将会发送info协议
on_cost_coin(_Uid, Cost, UsrActivityRec) ->
	ActData  = UsrActivityRec#gm_activity_usr.act_data,
	TotalCost = Cost + fun_gm_activity_ex:get_list_data_by_key(cost_coin, ActData, 0),
	ActData3 = lists:keystore(cost_coin, 1, ActData, {cost_coin, TotalCost}),
	UsrActivityRec2 = UsrActivityRec#gm_activity_usr{act_data = ActData3},
	fun_gm_activity_ex:set_usr_activity_data(UsrActivityRec2),
	true.

%% 发送info数据给前端
send_info_to_client(Uid, Sid, ActivityRec, UsrActivityRec) ->
	Pt = #pt_daily_acc_cost{
		startTime = ActivityRec#gm_activity.start_time + util_time:get_time_zone(ActivityRec#gm_activity.start_time),
		endTime   = ActivityRec#gm_activity.end_time + util_time:get_time_zone(ActivityRec#gm_activity.end_time),
		desc      = ActivityRec#gm_activity.act_des,
		cost_coin     = fun_gm_activity_ex:get_list_data_by_key(cost_coin, UsrActivityRec#gm_activity_usr.act_data, 0),
		datas         = get_reward_state_list(Uid, ActivityRec, UsrActivityRec)
	},
	?send(Sid, proto:pack(Pt)).	

%% 领取奖励的item_way日志
get_reward_way() -> ?ITEM_WAY_GM_ACT_DAILY_ACC_COST.

%% 领取奖励的展示类型
get_fetched_reward_show_type() -> ?SHOW_REWARD_COMMON.

%% 领取奖励的判断
check_fetch_reward(Uid, UsrActivityRec, ActivityRec, RewardId) ->
	StateList = get_reward_state_list(Uid, ActivityRec, UsrActivityRec),
	?debug("RewardId:~p", [RewardId]),
	?debug("StateList:~p", [StateList]),
	case lists:keyfind(RewardId, #pt_public_daily_acc_cost_des.id, StateList) of
		false -> {error, "error_fetch_reward_not_reached"};
		#pt_public_daily_acc_cost_des{state = ?REWARD_STATE_CAN_FETCH, items = RewardItems} ->
			FetchData = UsrActivityRec#gm_activity_usr.fetch_data,
			Tuple = case lists:keyfind(RewardId, 1, FetchData) of
				false -> {RewardId, 1};
				{_, Times} -> {RewardId, Times + 1}
			end,
			FetchData2      = lists:keystore(RewardId, 1, FetchData, Tuple),
			UsrActivityRec2 = UsrActivityRec#gm_activity_usr{fetch_data = FetchData2},
			{ok, UsrActivityRec2, RewardItems};
		_ -> 
			{error, "error_fetch_reward_not_reached"}
	end.

do_activity_end_help(_ActivityRec, #gm_activity_usr{uid = Uid}) ->
	case db:dirty_get(ply, Uid) of
		[#ply{sid=Sid} | _] ->
			Pt = #pt_daily_acc_cost{},
			?send(Sid, proto:pack(Pt));
		_ -> skip
	end.

%% ================================================================
%% =========================== 内部方法 ===========================
get_reward_state_list(_Uid, ActivityRec, UsrActivityRec) ->
	Fun = fun({Id, NeedCost, Items}) ->
		case lists:keyfind(Id, 1, UsrActivityRec#gm_activity_usr.fetch_data) of
			false -> ExchangTimes = 0;
			{_, ExchangTimes} -> ok
		end,
		CostCoin = fun_gm_activity_ex:get_list_data_by_key(cost_coin, UsrActivityRec#gm_activity_usr.act_data, 0),
		State = if
			ExchangTimes > 0 -> ?REWARD_STATE_FETCHED;
			CostCoin >= NeedCost -> ?REWARD_STATE_CAN_FETCH;
			true -> ?REWARD_STATE_NOT_REACHED
		end,
		#pt_public_daily_acc_cost_des{
			id        = Id,
			need_cost = NeedCost,
			state     = State,
			items     = lists:map(fun fun_item_api:make_item_get_pt/1, Items)
		}
	end,
	lists:map(Fun, ActivityRec#gm_activity.reward_datas).