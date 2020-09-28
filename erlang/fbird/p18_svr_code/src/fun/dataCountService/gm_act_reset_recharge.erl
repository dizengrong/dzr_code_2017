%% @doc gm活动：首充重置
-module(gm_act_reset_recharge).
-include("common.hrl").
-compile([export_all]).

%% 解析后台传来的数据
parse_config_datas_field(KvList) ->
	TabTitle = fun_gm_activity_ex:get_json_value(KvList, "tab_title"),
	Desc     = fun_gm_activity_ex:get_json_value(KvList, "desc"),
	{TabTitle, Desc}.

%% 充值的处理，返回true将会发送info协议
on_recharge_help(_ActivityRec, _Uid, _UsrActivityRec, _RechargeDiamond, _RechargeConfigID) ->
	skip.

%% 消费金币的处理，返回true将会发送info协议
on_cost_coin(_Uid, _Cost, _UsrActivityRec) ->
	skip.

%% 发送info数据给前端
send_info_to_client(_Uid, Sid, ActivityRec, _UsrActivityRec) ->
	Fun = fun({TabTitle, Desc}) ->
		#pt_public_gm_act_reset_recharge_des{
			tab_title = TabTitle,
			desc      = Desc
		}
	end,
	Pt = #pt_gm_act_reset_recharge{
		startTime = ActivityRec#gm_activity.start_time + util_time:get_time_zone(ActivityRec#gm_activity.start_time),
		endTime   = ActivityRec#gm_activity.end_time + util_time:get_time_zone(ActivityRec#gm_activity.end_time),
		desc      = ActivityRec#gm_activity.act_des,
		datas     = [Fun(D) || D <- ActivityRec#gm_activity.reward_datas]
	},
	?send(Sid, proto:pack(Pt)).

%% 领取奖励的item_way日志
get_reward_way() -> 0.

%% 领取奖励的展示类型
get_fetched_reward_show_type() -> 0.

%% 领取奖励的判断
check_fetch_reward(_Uid, _UsrActivityRec, _ActivityRec, _RewardId) ->
	{error, "error_fetch_reward_not_reached"}.

%% 活动结束的处理
do_activity_end_help(_ActivityRec, #gm_activity_usr{uid = Uid}) ->
	case db:dirty_get(ply, Uid) of
		[#ply{sid=Sid} | _] ->
			Pt = #pt_gm_act_reset_recharge{},
			?send(Sid, proto:pack(Pt));
		_ -> skip
	end.

on_start_activity(ActType) ->
	?debug("check_open"),
	List = db:dirty_match(ply, #ply{_ = '_'}),
	[gen_server:cast(Pid,{on_start_activity_help,Uid,ActType}) || #ply{uid = Uid,agent_hid = Pid} <- List].

check_recharge_config(Uid) ->
	case fun_gm_activity_ex:find_open_activity(?GM_ACTIVITY_RESET_RECHARGE) of
		{true, ActivityRec} ->
			List = fun_usr_misc:get_misc_data(Uid, first_recharge),
			case lists:member(ActivityRec#gm_activity.act_id, List) of
				false -> fun_usr_misc:set_misc_data(Uid, first_recharge, [ActivityRec#gm_activity.act_id]);
				_ -> skip
			end;
		_ -> skip
	end.
%% ================================================================
%% =========================== 内部方法 ===========================


%% =============================================================================
%% ========================= 测试方法 ==========================================
% world_svr:debug_call(agent_mng, fun() -> gm_act_reset_recharge:test_set_config() end).
% world_svr:debug_call(agent_mng, fun() -> gm_act_reset_recharge:test_del_config() end).
% world_svr:debug_call(agent_mng, fun() -> fun_toplist:get_toplist_rank(14, 1000000999) end).
test_set_config() ->
	ActivityRec = #gm_activity{
		act_id       = ?GM_ACTIVITY_RESET_RECHARGE,
		act_name     = "name",
		type         = ?GM_ACTIVITY_RESET_RECHARGE,
		start_time   = util:unixtime() + 10,
		end_time     = util:unixtime() + 20000,
		act_des      = "ActDes",
		setting      = [],
		reward_datas = util:term_to_string(test_reward_datas(?GM_ACTIVITY_RESET_RECHARGE))
	},
	db:insert(ActivityRec),
	fun_gm_activity_ex:activity_config_help(ActivityRec),
	ok.	

test_del_config() ->
	fun_gm_activity_ex:del_config(?GM_ACTIVITY_RESET_RECHARGE, ?GM_ACTIVITY_RESET_RECHARGE).

test_reward_datas(?GM_ACTIVITY_RESET_RECHARGE) ->
	[{"123123","456456"}].
