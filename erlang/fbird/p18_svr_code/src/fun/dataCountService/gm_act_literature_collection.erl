%% @doc gm活动：集字活动
-module (gm_act_literature_collection).
-include("common.hrl").
-compile([export_all]).

-define(THIS_TYPE, ?GM_ACTIVITY_LITERATURE_COLLECTION).

%% 解析后台传来的数据
parse_config_datas_field(KvList) ->
	Item = fun_gm_activity_ex:string_to_term(util:to_list(fun_gm_activity_ex:get_json_value(KvList, "item"))),
	Task = fun_gm_activity_ex:string_to_term(util:to_list(fun_gm_activity_ex:get_json_value(KvList, "src_items"))),
	{Item, Task}.

%% 充值的处理，返回true将会发送info协议
on_recharge_help(_ActivityRec, _Uid, _UsrActivityRec, _RechargeDiamond, _RechargeConfigID) ->
	skip.

%% 消费金币的处理，返回true将会发送info协议
on_cost_coin(_Uid, _Cost, _UsrActivityRec) ->
	skip.

%% 发送info数据给前端
send_info_to_client(Uid, Sid, ActivityRec, UsrActivityRec) ->
	Pt = #pt_gm_act_literature_collection{
		startTime   = ActivityRec#gm_activity.start_time + util_time:get_time_zone(ActivityRec#gm_activity.start_time),
		endTime     = ActivityRec#gm_activity.end_time + util_time:get_time_zone(ActivityRec#gm_activity.end_time),
		desc      	= ActivityRec#gm_activity.act_des,
		close_time  = ActivityRec#gm_activity.close_time + util_time:get_time_zone(ActivityRec#gm_activity.close_time),
		datas     	= get_reward_state_list(Uid, ActivityRec, UsrActivityRec)
	},
	?send(Sid, proto:pack(Pt)).

%% 领取奖励的item_way日志
get_reward_way() -> ?ITEM_WAY_GM_ACT_LITERATURE_COLLECTION.

%% 领取奖励的展示类型
get_fetched_reward_show_type() -> ?SHOW_REWARD_COMMON.

%% 领取奖励的判断
check_fetch_reward(Uid, UsrActivityRec, ActivityRec, RewardId) ->
	StateList = get_reward_state_list(Uid, ActivityRec, UsrActivityRec),
	case lists:keyfind(RewardId, #pt_public_act_literature_collection_des.task_id, StateList) of
		#pt_public_act_literature_collection_des{max_times = MaxTime, times = Times, need_item = NeedItem, reward_item = RewardItem} ->
			case MaxTime > Times of
				true ->
					ActData = UsrActivityRec#gm_activity_usr.act_data,
					TaskData = fun_gm_activity_ex:get_list_data_by_key(task_data, ActData, []),
					NewTaskData = lists:keystore(RewardId, 1, TaskData, {RewardId, Times + 1}),
					ActData2 = lists:keystore(task_data, 1, ActData, {task_data, NewTaskData}),
					UsrActivityRec2 = UsrActivityRec#gm_activity_usr{act_data = ActData2},
					SpendItems = [{?ITEM_WAY_GM_ACT_LITERATURE_COLLECTION, T, N} || #pt_public_item_list{item_id=T,item_num=N} <- NeedItem],
					{ok, UsrActivityRec2, RewardItem, SpendItems};
				_ -> skip
			end;
		_ -> skip
	end.

%% 活动结束的处理
do_activity_end_help(_ActivityRec, UsrActivityRec) ->
	Uid = UsrActivityRec#gm_activity_usr.uid,
	case db:dirty_get(ply, Uid) of
		[#ply{sid=Sid} | _] ->
			Pt = #pt_gm_act_literature_collection{},
			?send(Sid, proto:pack(Pt));
		_ -> skip
	end.

%% ================================================================
%% =========================== 内部方法 ===========================
handle({collect_drop,Uid}) ->
	case db:dirty_get(ply, Uid) of
		[#ply{sid = Sid}] ->
			AddItems = do_collect_drop(),
			fun_item_api:check_and_add_items(Uid, Sid, [], AddItems);
		_ -> skip
	end.

do_collect_drop() ->
	case fun_gm_activity_ex:find_open_activity(?GM_ACTIVITY_LITERATURE_COLLECTION) of
		{true, ActivityRec} ->
			[{Item, _}] = ActivityRec#gm_activity.reward_datas,
			Rand = util:rand(1, 10000),
			[{?ITEM_WAY_GM_ACT_LITERATURE_COLLECTION, T, N} || {T, N} <- get_drop_item(Item, Rand, 0)];
		_ -> []
	end.

get_reward_state_list(_Uid, ActivityRec, UsrActivityRec) ->
	case ActivityRec#gm_activity.reward_datas of
		[{_, Task}] ->
			ActData = UsrActivityRec#gm_activity_usr.act_data,
			TaskData = fun_gm_activity_ex:get_list_data_by_key(task_data, ActData, []),
			Fun = fun({Id, MaxTime, NeedItem, RewardItem}) ->
				Times = case lists:keyfind(Id, 1, TaskData) of
					{_, Num} -> Num;
					_ -> 0
				end,
				#pt_public_act_literature_collection_des{
					task_id 	= Id,
					max_times 	= MaxTime,
					times 		= Times,
					need_item	= lists:map(fun fun_item_api:make_item_get_pt/1, NeedItem),
					reward_item	= lists:map(fun fun_item_api:make_item_get_pt/1, RewardItem)
				}
			end,
			lists:map(Fun, Task);
		_ -> []
	end.

get_drop_item([], _Rand, _Acc) -> [];
get_drop_item([{T, R} | Rest], Rand, Acc) ->
	case Rand > Acc andalso Rand =< (Acc + R) of
		true -> [{T, 1}];
		_ -> get_drop_item(Rest, Rand, Acc + R)
	end.

%% =============================================================================
%% ========================= 测试方法 ==========================================
% world_svr:debug_call(agent_mng, fun() -> gm_act_literature_collection:test_set_config() end).
% world_svr:debug_call(agent_mng, fun() -> gm_act_literature_collection:test_del_config() end).
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
		[{7020,100},{7021,100},{7022,2000},{7023,5000}],
		[
			{1,5,[{7020,100},{7021,100},{7022,100},{7023,100}],[{2,120}]},
			{2,5,[{7020,50},{7021,50},{7022,50},{7023,50}],[{2,100}]},
			{3,3,[{7020,30},{7021,30},{7022,30},{7023,30}],[{2,80}]},
			{4,3,[{7020,10},{7021,10},{7022,10},{7023,10}],[{2,60}]}
		]
	}].