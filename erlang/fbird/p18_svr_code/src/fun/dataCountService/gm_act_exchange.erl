%% @doc gm活动：道具兑换
-module (gm_act_exchange).
-include("common.hrl").
-compile([export_all]).

%% ================================= 通用回调 ==================================
%% 解析后台传来的数据
parse_config_datas_field(KvList) ->
	Id            = util:to_integer(fun_gm_activity_ex:get_json_value(KvList, "type")), 
	TabTitle      = fun_gm_activity_ex:get_json_value(KvList, "tab_title"), 
	SrcItems      = fun_gm_activity_ex:string_to_term(util:to_list(fun_gm_activity_ex:get_json_value(KvList, "src_items"))),
	ExchangeItems = fun_gm_activity_ex:string_to_term(util:to_list(fun_gm_activity_ex:get_json_value(KvList, "exchange_items"))),
	MaxTimes      = util:to_integer(fun_gm_activity_ex:get_json_value(KvList, "max_times")), 
	{Id, TabTitle, SrcItems, ExchangeItems, MaxTimes}.

%% 充值的处理，返回true将会发送info协议
on_recharge_help(_ActivityRec, _Uid, _UsrActivityRec, _RechargeDiamond, _RechargeConfigID) ->
	skip.

%% 消费金币的处理，返回true将会发送info协议
on_cost_coin(_Uid, _Cost, _UsrActivityRec) ->
	skip.

%% 发送info数据给前端
send_info_to_client(Uid, Sid, ActivityRec, UsrActivityRec) ->
	Pt = #pt_gm_act_exchange{
		startTime = ActivityRec#gm_activity.start_time + util_time:get_time_zone(ActivityRec#gm_activity.start_time),
		endTime   = ActivityRec#gm_activity.end_time + util_time:get_time_zone(ActivityRec#gm_activity.end_time),
		desc      = ActivityRec#gm_activity.act_des,
		datas     = get_reward_state_list(Uid, ActivityRec, UsrActivityRec)
	},
	?send(Sid, proto:pack(Pt)).	

%% 领取奖励的item_way日志
get_reward_way() -> ?ITEM_WAY_GM_ACT_EXCHANGE.

%% 领取奖励的展示类型
get_fetched_reward_show_type() -> ?SHOW_REWARD_COMMON.

%% 领取奖励的判断
check_fetch_reward(Uid, UsrActivityRec, ActivityRec, RewardId) ->
	StateList = get_reward_state_list(Uid, ActivityRec, UsrActivityRec),
	case lists:keyfind(RewardId, #pt_public_gm_act_exchange_des.id, StateList) of
		false -> {error, "error_fetch_reward_not_reached"};
		#pt_public_gm_act_exchange_des{state = ?REWARD_STATE_CAN_FETCH, exchange_items = RewardItems, src_items = SrcItems} ->
			FetchData = UsrActivityRec#gm_activity_usr.fetch_data,
			Tuple = case lists:keyfind(RewardId, 1, FetchData) of
				false -> {RewardId, 1};
				{_, Times} -> {RewardId, Times + 1}
			end,
			FetchData2      = lists:keystore(RewardId, 1, FetchData, Tuple),
			UsrActivityRec2 = UsrActivityRec#gm_activity_usr{fetch_data = FetchData2},
			Way             = get_reward_way(),
			SrcItems2       = [{Way, T, N} || #pt_public_item_list{item_id = T, item_num = N} <- SrcItems],
			{ok, UsrActivityRec2, RewardItems, SrcItems2};
		_ -> 
			{error, "error_fetch_reward_not_reached"}
	end.

do_activity_end_help(_ActivityRec, #gm_activity_usr{uid = Uid}) ->
	case db:dirty_get(ply, Uid) of
		[#ply{sid=Sid} | _] ->
			Pt = #pt_gm_act_exchange{},
			?send(Sid, proto:pack(Pt));
		_ -> skip
	end.
%% ================================= 通用回调 ==================================

%% =============================================================================
%% ================================ 本模块方法 =================================
get_reward_state_list(_Uid, ActivityRec, UsrActivityRec) ->
	Fun = fun({Id, TabTitle, SrcItems, ExchangeItems, MaxTimes}) ->
		ExchangTimes = fun_gm_activity_ex:get_list_data_by_key(Id, UsrActivityRec#gm_activity_usr.fetch_data, 0),
		State = if
			MaxTimes == 0 -> ?REWARD_STATE_CAN_FETCH;
			ExchangTimes < MaxTimes -> ?REWARD_STATE_CAN_FETCH;
			true -> ?REWARD_STATE_FETCHED
		end,
		#pt_public_gm_act_exchange_des{
			id             = Id,
			state          = State,
			tab_title      = TabTitle,
			max_times      = MaxTimes,
			exchange_times = ExchangTimes,
			src_items      = lists:map(fun fun_item_api:make_item_get_pt/1, SrcItems),
			exchange_items = lists:map(fun fun_item_api:make_item_get_pt/1, ExchangeItems)
		}
	end,
	lists:map(Fun, ActivityRec#gm_activity.reward_datas).
