%% @doc gm活动：累积充值
-module (gm_act_daily_acc_recharge).
-include("common.hrl").
-compile([export_all]).

-define(THIS_TYPE, ?GM_ACTIVITY_DAILY_ACC_RECHARGE).

%% 解析后台传来的数据
parse_config_datas_field(KvList) ->
	NeedDiamond = util:to_integer(fun_gm_activity_ex:get_json_value(KvList, "diamond_lev")),
	Sort        = util:to_integer(fun_gm_activity_ex:get_json_value(KvList, "grade")), 
	SortDesc    = "", 
	Items       = fun_gm_activity_ex:string_to_term(util:to_list(fun_gm_activity_ex:get_json_value(KvList, "items"))),
	Desc        = "", 
	{NeedDiamond, Items, Sort, SortDesc, Desc}.

%% 充值的处理，返回true将会发送info协议
on_recharge_help(_ActivityRec, _Uid, UsrActivityRec, RechargeDiamond, _RechargeConfigID) ->
	Total    = fun_gm_activity_ex:get_list_data_by_key(diamond, UsrActivityRec#gm_activity_usr.act_data, 0),
	ActData  = UsrActivityRec#gm_activity_usr.act_data,
	ActData2 = lists:keystore(diamond, 1, ActData, {diamond, Total + RechargeDiamond}),
	UsrActivityRec2 = UsrActivityRec#gm_activity_usr{act_data = ActData2},
	fun_gm_activity_ex:set_usr_activity_data(UsrActivityRec2),
	true.

%% 消费金币的处理，返回true将会发送info协议
on_cost_coin(_Uid, _Cost, _UsrActivityRec) ->
	skip.

%% 发送info数据给前端
send_info_to_client(Uid, Sid, ActivityRec, UsrActivityRec) ->
	Pt = #pt_daily_acc_recharge_info{
		startTime = ActivityRec#gm_activity.start_time + util_time:get_time_zone(ActivityRec#gm_activity.start_time),
		endTime   = ActivityRec#gm_activity.end_time + util_time:get_time_zone(ActivityRec#gm_activity.end_time),
		datas     = get_reward_state_list(Uid, ActivityRec, UsrActivityRec)
	},
	?send(Sid, proto:pack(Pt)).

%% 领取奖励的item_way日志
get_reward_way() -> ?ITEM_WAY_GM_ACT_DAILY_ACC_RECHARGE.

%% 领取奖励的展示类型
get_fetched_reward_show_type() -> ?SHOW_REWARD_COMMON.

%% 领取奖励的判断
check_fetch_reward(Uid, UsrActivityRec, ActivityRec, RewardId) ->
	StateList = get_reward_state_list(Uid, ActivityRec, UsrActivityRec),
	case lists:keyfind(RewardId, #pt_public_daily_acc_recharge_des.need_diamond, StateList) of
		false -> {error, "error_fetch_reward_not_reached"};
		#pt_public_daily_acc_recharge_des{state = ?REWARD_STATE_CAN_FETCH, products = RewardItems} ->
			FetchData       = UsrActivityRec#gm_activity_usr.fetch_data,
			FetchData2      = [RewardId | FetchData],
			UsrActivityRec2 = UsrActivityRec#gm_activity_usr{fetch_data = FetchData2},
			{ok, UsrActivityRec2, RewardItems};
		_ -> 
			{error, "error_fetch_reward_not_reached"}
	end.

%% 活动结束的处理
do_activity_end_help(ActivityRec, UsrActivityRec) ->
	Uid       = UsrActivityRec#gm_activity_usr.uid,
	StateList = get_reward_state_list(Uid, ActivityRec, UsrActivityRec),
	[do_activity_end_help2(Uid, ActivityRec, PtState) || PtState <- StateList],
	case db:dirty_get(ply, Uid) of
		[#ply{sid=Sid} | _] ->
			Pt = #pt_daily_acc_recharge_info{},
			?send(Sid, proto:pack(Pt));
		_ -> skip
	end.

do_activity_end_help2(Uid, ActivityRec, PtState) ->
	#pt_public_daily_acc_recharge_des{state = State, products = RewardItems} = PtState,
	case State of
		?REWARD_STATE_CAN_FETCH ->
			fun_gm_activity_ex:send_not_fetch_mail(?THIS_TYPE, Uid, ActivityRec#gm_activity.act_name, RewardItems, 1);
		_ -> skip
	end.	

%% ================================================================
%% =========================== 内部方法 ===========================
get_reward_state_list(_Uid, ActivityRec, UsrActivityRec) ->
	TotalRecharge = fun_gm_activity_ex:get_list_data_by_key(diamond, UsrActivityRec#gm_activity_usr.act_data, 0),
	Fun = fun({NeedDiamond, Items, Sort, SortDesc, Desc}) ->
		State = case lists:member(NeedDiamond, UsrActivityRec#gm_activity_usr.fetch_data) of
			false -> 
				?_IF(TotalRecharge >= NeedDiamond, ?REWARD_STATE_CAN_FETCH, ?REWARD_STATE_NOT_REACHED);
			true -> ?REWARD_STATE_FETCHED
		end,
		#pt_public_daily_acc_recharge_des{
			sort             = Sort,
			need_diamond     = NeedDiamond,
			recharge_diamond = TotalRecharge,
			state            = State,
			sort_desc        = SortDesc,
			desc             = Desc,
			products         = lists:map(fun fun_item_api:make_item_get_pt/1, Items)
		}
	end,
	lists:map(Fun, ActivityRec#gm_activity.reward_datas).

%% =============================================================================
%% ========================= 测试方法 ==========================================
% world_svr:debug_call(agent_mng, fun() -> gm_act_daily_acc_recharge:test_set_config() end).
% world_svr:debug_call(agent_mng, fun() -> gm_act_daily_acc_recharge:test_del_config() end).
test_set_config() ->
	ActivityRec = #gm_activity{
		act_id       = ?THIS_TYPE,
		act_name     = "name",
		type         = ?THIS_TYPE,
		start_time   = util:unixtime() + 10,
		end_time     = util:unixtime() + 20000,
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
	[{100, [{2, 100}], 1, "SortDescripte", "ActivityDescripte"},
	 {300, [{2, 100}], 1, "SortDescripte", "ActivityDescripte"},
	 {500, [{2, 100}], 1, "SortDescripte", "ActivityDescripte"},
	 {980, [{2, 100}], 2, "SortDescripte", "ActivityDescripte"},
	 {1980, [{2, 100}], 2, "SortDescripte", "ActivityDescripte"},
	 {3280, [{2, 100}], 2, "SortDescripte", "ActivityDescripte"},
	 {6480, [{2, 100}], 3, "SortDescripte", "ActivityDescripte"},
	 {8888, [{2, 100}], 3, "SortDescripte", "ActivityDescripte"},
	 {9999, [{2, 100}], 3, "SortDescripte", "ActivityDescripte"}].
