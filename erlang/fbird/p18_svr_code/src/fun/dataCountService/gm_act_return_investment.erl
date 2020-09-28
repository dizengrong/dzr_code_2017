%% @doc gm活动：投资回报
-module (gm_act_return_investment).
-include("common.hrl").
-compile([export_all]).

-define(THIS_TYPE, ?GM_ACTIVITY_RETURN_INVESTMENT).

%% 解析后台传来的数据
parse_config_datas_field(KvList) ->
	Need    = util:to_integer(fun_gm_activity_ex:get_json_value(KvList, "need")),
	Reward  = fun_gm_activity_ex:string_to_term(util:to_list(fun_gm_activity_ex:get_json_value(KvList, "reward"))),
	{Need, Reward}.

%% 充值的处理，返回true将会发送info协议
on_recharge_help(_ActivityRec, _Uid, UsrActivityRec, RechargeDiamond, _RechargeConfigID) ->
	ActData = UsrActivityRec#gm_activity_usr.act_data,
	MyDiomand = fun_gm_activity_ex:get_list_data_by_key(my_dioamnd, UsrActivityRec#gm_activity_usr.act_data, 0),
	ActData2 = lists:keystore(my_dioamnd, 1, ActData, {my_dioamnd, MyDiomand + RechargeDiamond}),
	UsrActivityRec2 = UsrActivityRec#gm_activity_usr{act_data = ActData2, act_time = util_time:unixtime()},
	fun_gm_activity_ex:set_usr_activity_data(UsrActivityRec2),
	true.

%% 消费金币的处理，返回true将会发送info协议
on_cost_coin(_Uid, _Cost, _UsrActivityRec) ->
	skip.

refresh_global_data(_ActivityRec) ->
	DailyNum = fun_agent_mng:get_global_value(return_investment_num, 0),
	fun_agent_mng:set_global_value(return_investment_num, DailyNum + 1).

%% 发送info数据给前端
send_info_to_client(Uid, Sid, ActivityRec, UsrActivityRec) ->
	Pt = #pt_return_investment_info{
		startTime 		= ActivityRec#gm_activity.start_time + util_time:get_time_zone(ActivityRec#gm_activity.start_time),
		endTime   		= ActivityRec#gm_activity.end_time + util_time:get_time_zone(ActivityRec#gm_activity.end_time),
		desc 			= util:to_list(ActivityRec#gm_activity.act_des),
		datas     		= get_reward_state_list(Uid, ActivityRec, UsrActivityRec)
	},
	?send(Sid, proto:pack(Pt)).

%% 领取奖励的item_way日志
get_reward_way() -> ?ITEM_WAY_GM_ACT_RETURN_INVESTMENT.

%% 领取奖励的展示类型
get_fetched_reward_show_type() -> ?SHOW_REWARD_COMMON.

%% 领取奖励的判断
check_fetch_reward(_Uid, UsrActivityRec, ActivityRec, RewardId) ->
	[{Need, Reward}] = ActivityRec#gm_activity.reward_datas,
	MyDiomand = fun_gm_activity_ex:get_list_data_by_key(my_dioamnd, UsrActivityRec#gm_activity_usr.act_data, 0),
	DailyNum = fun_agent_mng:get_global_value(return_investment_num, 0),
	FetchData = UsrActivityRec#gm_activity_usr.fetch_data,
	case lists:keyfind(RewardId, 1, Reward) of
		{RewardId, ItemList, _} ->
			case lists:member(RewardId, FetchData) of
				false -> 
					case MyDiomand >= Need andalso DailyNum >= RewardId of
						true ->
							FetchData2 = [RewardId | FetchData],
							UsrActivityRec2 = UsrActivityRec#gm_activity_usr{fetch_data = FetchData2},
							RewardItem = lists:map(fun fun_item_api:make_item_get_pt/1, ItemList),
							{ok, UsrActivityRec2, RewardItem};
						_ -> {error, "error_fetch_reward_not_reached"}
					end;
				true -> {error, "error_fetch_reward_already_fetched"}
			end;
		_ -> {error, "error_fetch_reward_already_fetched"}
	end.

on_start_activity(_ActType) ->
	fun_agent_mng:set_global_value(return_investment_num, 1).

%% 活动结束的处理
do_activity_end_help(ActivityRec, UsrActivityRec) ->
	Uid = UsrActivityRec#gm_activity_usr.uid,
	StateList = get_reward_state_list(Uid, ActivityRec, UsrActivityRec),
	[do_activity_end_help2(Uid, ActivityRec, PtState) || PtState <- StateList],
	case db:dirty_get(ply, Uid) of
		[#ply{sid=Sid} | _] ->
			Pt = #pt_return_investment_info{},
			?send(Sid, proto:pack(Pt));
		_ -> skip
	end,
	mod_msg:handle_to_agnetmng(?MODULE, {refresh_daily_num, 0}).

do_activity_end_help2(Uid, ActivityRec, PtState) ->
	#pt_public_return_investment_des{reward_list = RewardList} = PtState,
	Fun = fun(#pt_public_return_investment_reward_list{status = Status, reward = Rewards}) ->
		case Status of
			?REWARD_STATE_CAN_FETCH ->
				fun_gm_activity_ex:send_not_fetch_mail(?GM_ACTIVITY_RETURN_INVESTMENT, Uid, ActivityRec#gm_activity.act_name, Rewards, 1);
			_ -> skip
		end
	end,
	lists:foreach(Fun, RewardList).

%% ================================================================
%% =========================== 内部方法 ===========================
get_reward_state_list(_Uid, ActivityRec, UsrActivityRec) ->
	MyDiomand = fun_gm_activity_ex:get_list_data_by_key(my_dioamnd, UsrActivityRec#gm_activity_usr.act_data, 0),
	Fun = fun({Need, Reward}) ->
		#pt_public_return_investment_des{
			my_dioamnd   = MyDiomand,
			need_diomand = Need,
			reward_list  = get_reward_state_list_help(Reward, Need, MyDiomand, UsrActivityRec)
		}
	end,
	lists:map(Fun, ActivityRec#gm_activity.reward_datas).

get_reward_state_list_help(Reward, Need, MyDiomand, UsrActivityRec) ->
	DailyNum = fun_agent_mng:get_global_value(return_investment_num, 0),
	Fun = fun({Id, RewardItem, Desc}) ->
		Can = case lists:member(Id, UsrActivityRec#gm_activity_usr.fetch_data) of
			false -> 
				case MyDiomand >= Need andalso DailyNum >= Id of
					true -> ?REWARD_STATE_CAN_FETCH;
					_ -> ?REWARD_STATE_NOT_REACHED
				end;
			true -> ?REWARD_STATE_FETCHED
		end,
		#pt_public_return_investment_reward_list{
			id 	   = Id,
			des    = Desc,
			status = Can,
			reward = lists:map(fun fun_item_api:make_item_get_pt/1, RewardItem)
		}
	end,
	lists:map(Fun, Reward).

handle({refresh_daily_num, Num}) ->
	fun_agent_mng:set_global_value(return_investment_num, Num);

handle(Msg) -> ?log_error("~p unhandled message:~p", [?MODULE, Msg]).

%% =============================================================================
%% ========================= 测试方法 ==========================================
% world_svr:debug_call(agent_mng, fun() -> gm_act_return_investment:test_set_config() end).
% world_svr:debug_call(agent_mng, fun() -> gm_act_return_investment:test_del_config() end).
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
	[{
		2000,
		[
			{1,[{2,10}],"第1天"},
			{2,[{1,10000}],"第2天"},
			{3,[{9,10000}],"第3天"},
			{4,[{11,100}],"第4天"},
			{5,[{2,20}],"第5天"},
			{6,[{1,10000}],"第6天"},
			{7,[{9003,5}],"第7天"}
		]
	}].