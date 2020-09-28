%% @doc gm活动：双倍活动
-module (gm_act_double_reward).
-include("common.hrl").
-compile([export_all]).

%% 解析后台传来的数据
parse_config_datas_field(KvList) ->
	TabTitle   = fun_gm_activity_ex:get_json_value(KvList, "tab_title"), 
	Desc       = fun_gm_activity_ex:get_json_value(KvList, "desc"),
	DoubleType = util:to_integer(fun_gm_activity_ex:get_json_value(KvList, "type")), 
	Double     = util:to_integer(fun_gm_activity_ex:get_json_value(KvList, "double")), 
	Items      = fun_gm_activity_ex:string_to_term(util:to_list(fun_gm_activity_ex:get_json_value(KvList, "items"))),
	{TabTitle, Desc, DoubleType, Double, Items}.

%% 充值的处理，返回true将会发送info协议
on_recharge_help(_ActivityRec, _Uid, _UsrActivityRec, _RechargeDiamond, _RechargeConfigID) ->
	skip.

%% 消费金币的处理，返回true将会发送info协议
on_cost_coin(_Uid, _Cost, _UsrActivityRec) ->
	skip.

%% 发送info数据给前端
send_info_to_client(_Uid, Sid, ActivityRec, _UsrActivityRec) ->
	Fun = fun({TabTitle, Desc, DoubleType, Double, Items}) ->
		#pt_public_gm_act_double_des{
			type         = DoubleType,
			tab_title    = TabTitle,
			desc         = Desc,
			double_times = Double,
			extra_reward = lists:map(fun fun_item_api:make_item_get_pt/1, Items)
		}
	end,
	Pt = #pt_gm_act_double{
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
			Pt = #pt_gm_act_double{},
			?send(Sid, proto:pack(Pt));
		_ -> skip
	end.

%% 返回:false | {true, Double, ExtraItems}
is_double(Type) -> 
	case fun_gm_activity_ex:find_open_activity(?GM_ACTIVITY_DOUBLE_REWARD) of
		false -> false;
		{true, ActivityRec} -> 
			List = ActivityRec#gm_activity.reward_datas,
			case lists:keyfind(Type, 3, List) of
				{_, _, _, Double, Items} when Double > 0 -> {true, Double, Items};
				_ -> false
			end
	end.

%% ================================================================
%% =========================== 内部方法 ===========================


%% =============================================================================
%% ========================= 测试方法 ==========================================
% world_svr:debug_call(10, fun() -> fun_gm_activity_ex:test_set_config() end).
% world_svr:debug_call(10, fun() -> fun_gm_activity_ex:test_del_config() end).
test_set_config() ->
	ActivityRec = #gm_activity{
		act_id       = ?GM_ACTIVITY_DOUBLE_REWARD,
		act_name     = "name",
		type         = ?GM_ACTIVITY_DOUBLE_REWARD,
		start_time   = util:unixtime() + 10,
		end_time     = util:unixtime() + 20000,
		act_des      = "ActDes",
		setting      = [],
		reward_datas = util:term_to_string(test_reward_datas(?GM_ACTIVITY_DOUBLE_REWARD))
	},
	db:insert(ActivityRec),
	fun_gm_activity_ex:activity_config_help(ActivityRec),
	ok.	

test_del_config() ->
	fun_gm_activity_ex:del_config(?GM_ACTIVITY_DOUBLE_REWARD, ?GM_ACTIVITY_DOUBLE_REWARD).

test_reward_datas(?GM_ACTIVITY_DOUBLE_REWARD) ->
	[].
