%% @doc gm活动：限时充值双倍
-module(gm_act_double_recharge_temp).
-include("common.hrl").
-compile([export_all]).

%% 解析后台传来的数据
parse_config_datas_field(KvList) ->
	TabTitle = fun_gm_activity_ex:get_json_value(KvList, "tab_title"),
	Desc     = fun_gm_activity_ex:get_json_value(KvList, "desc"),
	{TabTitle, Desc}.

%% 充值的处理，返回true将会发送info协议
on_recharge_help(_ActivityRec, Uid, UsrActivityRec, RechargeDiamond, RechargeConfigID) ->
	case db:dirty_get(ply, Uid) of
		[#ply{sid = Sid}] ->
			List = fun_usr_misc:get_misc_data(Uid, first_recharge),
			case lists:keyfind(RechargeConfigID, 1, List) of
				{RechargeConfigID, 2} ->
					FetchData = UsrActivityRec#gm_activity_usr.fetch_data,
					case lists:member(RechargeConfigID, FetchData) of
						true -> skip;
						_ ->
							AddItems = [{?ITEM_WAY_GM_ACT_LIMIT_DOUBLE_RECHARGE, ?RESOUCE_COIN_NUM, RechargeDiamond}],
							Succ = fun() ->
								FetchData2 = [RechargeConfigID | FetchData],
								UsrActivityRec2 = UsrActivityRec#gm_activity_usr{fetch_data = FetchData2},
								fun_gm_activity_ex:set_usr_activity_data(UsrActivityRec2)
							end,
							fun_item_api:check_and_add_items(Uid, Sid, [], AddItems, Succ, undefined),
							true
					end;
				_ -> skip
			end;
		_ -> skip
	end.

%% 消费金币的处理，返回true将会发送info协议
on_cost_coin(_Uid, _Cost, _UsrActivityRec) ->
	skip.

%% 发送info数据给前端
send_info_to_client(_Uid, Sid, ActivityRec, _UsrActivityRec) ->
	Pt = #pt_gm_act_limit_double_recharge{
		startTime = ActivityRec#gm_activity.start_time + util_time:get_time_zone(ActivityRec#gm_activity.start_time),
		endTime   = ActivityRec#gm_activity.end_time + util_time:get_time_zone(ActivityRec#gm_activity.end_time),
		desc      = ActivityRec#gm_activity.act_des
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
			Pt = #pt_gm_act_limit_double_recharge{},
			?send(Sid, proto:pack(Pt));
		_ -> skip
	end.

%% ================================================================
%% =========================== 内部方法 ===========================


%% =============================================================================
%% ========================= 测试方法 ==========================================
% world_svr:debug_call(agent_mng, fun() -> gm_act_double_recharge_temp:test_set_config() end).
% world_svr:debug_call(agent_mng, fun() -> gm_act_double_recharge_temp:test_del_config() end).
% world_svr:debug_call(agent_mng, fun() -> fun_toplist:get_toplist_rank(14, 1000000999) end).
test_set_config() ->
	ActivityRec = #gm_activity{
		act_id       = ?GM_ACTIVITY_DOUBLE_RECHARGE_TEMP,
		act_name     = "name",
		type         = ?GM_ACTIVITY_DOUBLE_RECHARGE_TEMP,
		start_time   = util:unixtime() + 10,
		end_time     = util:unixtime() + 20000,
		act_des      = "ActDes",
		setting      = [],
		reward_datas = util:term_to_string(test_reward_datas(?GM_ACTIVITY_DOUBLE_RECHARGE_TEMP))
	},
	db:insert(ActivityRec),
	fun_gm_activity_ex:activity_config_help(ActivityRec),
	ok.	

test_del_config() ->
	fun_gm_activity_ex:del_config(?GM_ACTIVITY_DOUBLE_RECHARGE_TEMP, ?GM_ACTIVITY_DOUBLE_RECHARGE_TEMP).

test_reward_datas(?GM_ACTIVITY_DOUBLE_RECHARGE_TEMP) ->
	[{"123123","456456"}].
