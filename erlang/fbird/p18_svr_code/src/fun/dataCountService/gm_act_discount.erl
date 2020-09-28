%% @doc gm活动：折扣活动
-module (gm_act_discount).
-include("common.hrl").
-compile([export_all]).

%% 解析后台传来的数据
parse_config_datas_field(KvList) ->
	TabTitle = fun_gm_activity_ex:get_json_value(KvList, "tab_title"), 
	Desc     = fun_gm_activity_ex:get_json_value(KvList, "desc"), 
	Type     = util:to_integer(fun_gm_activity_ex:get_json_value(KvList, "type")), 
	Discount = util:to_integer(fun_gm_activity_ex:get_json_value(KvList, "discount")), 
	{TabTitle, Desc, Type, Discount}.

%% 充值的处理，返回true将会发送info协议
on_recharge_help(_ActivityRec, _Uid, _UsrActivityRec, _RechargeDiamond, _RechargeConfigID) ->
	skip.

%% 消费金币的处理，返回true将会发送info协议
on_cost_coin(_Uid, _Cost, _UsrActivityRec) ->
	skip.

%% 发送info数据给前端
send_info_to_client(_Uid, Sid, ActivityRec, _UsrActivityRec) ->
	Fun = fun({TabTitle, Desc, Type, Discount}) ->
		#pt_public_gm_act_discount_des{
			type      = Type,
			tab_title = TabTitle,
			desc      = Desc,
			discount  = Discount
		}
	end,
	Pt = #pt_gm_act_discount{
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
			Pt = #pt_gm_act_discount{},
			?send(Sid, proto:pack(Pt));
		_ -> skip
	end.

%% 返回:false | {true, 折扣(如0.8)}
is_discount(Type) -> 
	case fun_gm_activity_ex:find_open_activity(?GM_ACTIVITY_DISCOUNT) of
		false -> false;
		{true, ActivityRec} -> 
			List = ActivityRec#gm_activity.reward_datas,
			case lists:keyfind(Type, 3, List) of
				{_, _, _, Discount} when Discount > 0 -> {true, Discount/100};
				_ -> false
			end
	end.

%% ================================================================
%% =========================== 内部方法 ===========================


%% =============================================================================
%% ========================= 测试方法 ==========================================
% world_svr:debug_call(agent_mng, fun() -> fun_gm_activity_ex:test_set_config() end).
% world_svr:debug_call(agent_mng, fun() -> fun_gm_activity_ex:test_del_config() end).
test_set_config() ->
	ActivityRec = #gm_activity{
		act_id       = ?GM_ACTIVITY_DISCOUNT,
		act_name     = "name",
		type         = ?GM_ACTIVITY_DISCOUNT,
		start_time   = util:unixtime() + 10,
		end_time     = util:unixtime() + 20000,
		act_des      = "ActDes",
		setting      = [],
		reward_datas = util:term_to_string(test_reward_datas(?GM_ACTIVITY_DISCOUNT))
	},
	db:insert(ActivityRec),
	fun_gm_activity_ex:activity_config_help(ActivityRec),
	ok.	

test_del_config() ->
	fun_gm_activity_ex:del_config(?GM_ACTIVITY_DISCOUNT, ?GM_ACTIVITY_DISCOUNT).

test_reward_datas(?GM_ACTIVITY_DISCOUNT) ->
	[].
