%% @doc gm活动：单笔充值
-module (gm_act_acc_login).
-include("common.hrl").
-compile([export_all]).

-define(THIS_TYPE, ?GM_ACTIVITY_ACC_LOGIN).

%% 解析后台传来的数据
parse_config_datas_field(KvList) ->
	Id 	  = util:to_integer(fun_gm_activity_ex:get_json_value(KvList, "id")),
	Days  = util:to_integer(fun_gm_activity_ex:get_json_value(KvList, "days")),
	Items = fun_gm_activity_ex:string_to_term(util:to_list(fun_gm_activity_ex:get_json_value(KvList, "items"))),
	{Id, Days, Items}.

%% 充值的处理，返回true将会发送info协议
on_recharge_help(_ActivityRec, _Uid, _UsrActivityRec, _RechargeDiamond, _RechargeConfigID) ->
	skip.

%% 消费金币的处理，返回true将会发送info协议
on_cost_coin(_Uid, _Cost, _UsrActivityRec) ->
	skip.

%% 发送info数据给前端
send_info_to_client(Uid, Sid, ActivityRec, UsrActivityRec) ->
	Pt = #pt_gm_act_acc_login{
		startTime = ActivityRec#gm_activity.start_time + util_time:get_time_zone(ActivityRec#gm_activity.start_time),
		endTime   = ActivityRec#gm_activity.end_time + util_time:get_time_zone(ActivityRec#gm_activity.end_time),
		days 	  = fun_gm_activity_ex:get_list_data_by_key(login_days, UsrActivityRec#gm_activity_usr.act_data, 1),
		desc 	  = util:to_list(ActivityRec#gm_activity.act_des),
		datas     = get_reward_state_list(Uid, ActivityRec, UsrActivityRec)
	},
	?send(Sid, proto:pack(Pt)).

%% 领取奖励的item_way日志
get_reward_way() -> ?ITEM_WAY_LOGINACT.

%% 领取奖励的展示类型
get_fetched_reward_show_type() -> ?SHOW_REWARD_COMMON.

%% 领取奖励的判断
check_fetch_reward(_Uid, UsrActivityRec, ActivityRec, RewardId) ->
	{RewardId, Need, Items} = lists:keyfind(RewardId, 1, ActivityRec#gm_activity.reward_datas),
	Days = fun_gm_activity_ex:get_list_data_by_key(login_days, UsrActivityRec#gm_activity_usr.act_data, 1),
	FetchData = UsrActivityRec#gm_activity_usr.fetch_data,
	case lists:member(RewardId, FetchData) of
		false ->
			case Days >= Need of
				true -> 
					FetchData2 = [RewardId | FetchData],
					UsrActivityRec2 = UsrActivityRec#gm_activity_usr{fetch_data = FetchData2},
					RewardItem = lists:map(fun fun_item_api:make_item_get_pt/1, Items),
					{ok, UsrActivityRec2, RewardItem};
				_ -> {error, "error_fetch_reward_already_fetched"}
			end;
		_ -> {error, "error_fetch_reward_not_reached"}
	end.

on_start_activity(_ActType) ->
	[first_day_help(Uid) || Uid <- db:dirty_all_keys(ply)].

%% 活动结束的处理
do_activity_end_help(ActivityRec, UsrActivityRec) ->
	Uid = UsrActivityRec#gm_activity_usr.uid,
	StateList = get_reward_state_list(Uid, ActivityRec, UsrActivityRec),
	[do_activity_end_help2(Uid, ActivityRec, PtState) || PtState <- StateList],
	case db:dirty_get(ply, Uid) of
		[#ply{sid=Sid} | _] ->
			Pt = #pt_gm_act_acc_login{},
			?send(Sid, proto:pack(Pt));
		_ -> skip
	end.

do_activity_end_help2(Uid, ActivityRec, PtState) ->
	#pt_public_acc_login_des{fetched = Fetched, items = RewardItem} = PtState,
	case Fetched of
		?REWARD_STATE_CAN_FETCH ->
			fun_gm_activity_ex:send_not_fetch_mail(?GM_ACTIVITY_ACC_LOGIN, Uid, ActivityRec#gm_activity.act_name, RewardItem, 1);
		_ -> skip
	end.

%% ================================================================
%% =========================== 内部方法 ===========================
get_reward_state_list(_Uid, ActivityRec, UsrActivityRec) ->
	Days = fun_gm_activity_ex:get_list_data_by_key(login_days, UsrActivityRec#gm_activity_usr.act_data, 1),
	Fun = fun({Id, Need, Items}) ->
		Fetched = case lists:member(Id, UsrActivityRec#gm_activity_usr.fetch_data) of
			false ->
				case Days >= Need of
					true -> ?REWARD_STATE_CAN_FETCH;
					_ -> ?REWARD_STATE_NOT_REACHED
				end;
			_ -> ?REWARD_STATE_FETCHED
		end,
		#pt_public_acc_login_des{
			id 			 = Id,
			days 		 = Need,
			fetched 	 = Fetched,
			items  		 = fun_item_api:make_item_pt_list(Items)
		}
	end,
	lists:map(Fun, ActivityRec#gm_activity.reward_datas).

on_login(Uid) ->
	case fun_gm_activity_ex:find_open_activity(?THIS_TYPE) of
		{true, ActivityRec} ->
			UsrActivityRec = fun_gm_activity_ex:get_usr_activity_data(Uid, ?THIS_TYPE),
			on_login_help(Uid, ActivityRec, UsrActivityRec);
		_ -> skip
	end.

on_login_help(_Uid, ActivityRec, UsrActivityRec) ->
	Now = util_time:unixtime(),
	case util_time:is_same_day(Now, ActivityRec#gm_activity.start_time) of
		false ->
			ActData = UsrActivityRec#gm_activity_usr.act_data,
			Days = fun_gm_activity_ex:get_list_data_by_key(login_days, UsrActivityRec#gm_activity_usr.act_data, 0),
			ActData2 = lists:keystore(login_days, 1, ActData, {login_days, Days + 1}),
			UsrActivityRec2 = UsrActivityRec#gm_activity_usr{act_data = ActData2},
			fun_gm_activity_ex:set_usr_activity_data(UsrActivityRec2);
		_ -> skip
	end.

first_day_help(Uid) ->
	case fun_gm_activity_ex:find_open_activity(?THIS_TYPE) of
		{true, ActivityRec} ->
			UsrActivityRec = fun_gm_activity_ex:get_usr_activity_data(Uid, ?THIS_TYPE),
			on_first_day_help(Uid, ActivityRec, UsrActivityRec);
		_ -> skip
	end.

on_first_day_help(_Uid, ActivityRec, UsrActivityRec) ->
	Now = util_time:unixtime(),
	case util_time:is_same_day(Now, ActivityRec#gm_activity.start_time) of
		true ->
			ActData = UsrActivityRec#gm_activity_usr.act_data,
			Days = fun_gm_activity_ex:get_list_data_by_key(login_days, UsrActivityRec#gm_activity_usr.act_data, 0),
			case Days >= 1 of
				true -> skip;
				_ ->
					ActData2 = lists:keystore(login_days, 1, ActData, {login_days, Days + 1}),
					UsrActivityRec2 = UsrActivityRec#gm_activity_usr{act_data = ActData2},
					fun_gm_activity_ex:set_usr_activity_data(UsrActivityRec2)
			end;
		_ -> skip
	end.


%% =============================================================================
%% ========================= 测试方法 ==========================================
% world_svr:debug_call(agent_mng, fun() -> gm_act_acc_login:test_set_config() end).
% world_svr:debug_call(agent_mng, fun() -> gm_act_acc_login:test_del_config() end).
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
		{1,1,[{2,10,0}]},
		{2,2,[{2,20,0}]},
		{3,4,[{2,30,0}]}
	].