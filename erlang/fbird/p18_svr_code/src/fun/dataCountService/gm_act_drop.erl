%% @doc gm活动：掉落
-module (gm_act_drop).
-include("common.hrl").
-compile([export_all]).

%% ================================= 通用回调 ==================================
%% 解析后台传来的数据
parse_config_datas_field(KvList) ->
	Sort  = util:to_integer(fun_gm_activity_ex:get_json_value(KvList, "sort")), 
	BoxId = util:to_integer(fun_gm_activity_ex:get_json_value(KvList, "reward")), 
	{Sort, BoxId}.

%% 充值的处理，返回true将会发送info协议
on_recharge_help(_ActivityRec, _Uid, _UsrActivityRec, _RechargeDiamond, _RechargeConfigID) ->
	skip.

%% 消费金币的处理，返回true将会发送info协议
on_cost_coin(_Uid, _Cost, _UsrActivityRec) ->
	skip.

%% 发送info数据给前端
send_info_to_client(_Uid, Sid, ActivityRec, _UsrActivityRec) ->
	Pt = #pt_gm_act_drop{
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

do_activity_end_help(_ActivityRec, #gm_activity_usr{uid = Uid}) ->
	case db:dirty_get(ply, Uid) of
		[#ply{sid=Sid} | _] ->
			Pt = #pt_gm_act_drop{},
			?send(Sid, proto:pack(Pt));
		_ -> skip
	end.
%% ================================= 通用回调 ==================================

%% =============================================================================
%% ================================ 本模块方法 =================================
get_extra_drop(_Uid, Prof, Type) ->
	case fun_gm_activity_ex:find_open_activity(?GM_ACTIVITY_DROP) of
		false -> [];
		{true, ActivityRec} -> 
			case lists:keyfind(Type, 1, ActivityRec#gm_activity.reward_datas) of
				false -> [];
				{_, BoxId} -> fun_draw:box(BoxId, Prof)
			end
	end.
