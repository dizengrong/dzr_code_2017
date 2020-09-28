%% @doc gm活动：每周任务
-module (gm_act_week_task).
-include("common.hrl").
-compile([export_all]).

%% ================================= 通用回调 ==================================
%% 解析后台传来的数据
parse_config_datas_field(KvList) ->
	TabTitle = fun_gm_activity_ex:get_json_value(KvList, "tab_title"), 
	Id       = util:to_integer(fun_gm_activity_ex:get_json_value(KvList, "id")), 
	Sort     = util:to_integer(fun_gm_activity_ex:get_json_value(KvList, "sort")), 
	Condtion = util:string_to_term(fun_gm_activity_ex:get_json_value(KvList, "num")), 
	Items    = util:string_to_term(util:to_list(fun_gm_activity_ex:get_json_value(KvList, "items"))),
	{Id, Sort, TabTitle, condition_to_list(Condtion), Items}.

%% 充值的处理，返回true将会发送info协议
on_recharge_help(_ActivityRec, _Uid, _UsrActivityRec, _RechargeDiamond, _RechargeConfigID) ->
	skip.

%% 消费金币的处理，返回true将会发送info协议
on_cost_coin(Uid, Cost, _UsrActivityRec) ->
	handle_task(Uid, get(sid), ?WEEK_TASK_COST_COIN, Cost).

%% 发送info数据给前端
send_info_to_client(Uid, Sid, ActivityRec, UsrActivityRec) ->
	Pt = #pt_gm_act_week_task{
		startTime = ActivityRec#gm_activity.start_time + util_time:get_time_zone(ActivityRec#gm_activity.start_time),
		endTime   = ActivityRec#gm_activity.end_time + util_time:get_time_zone(ActivityRec#gm_activity.end_time),
		desc      = ActivityRec#gm_activity.act_des,
		datas     = get_reward_state_list(Uid, ActivityRec, UsrActivityRec)
	},
	?send(Sid, proto:pack(Pt)).

%% 领取奖励的item_way日志
get_reward_way() -> 0.

%% 领取奖励的展示类型
get_fetched_reward_show_type() -> ?SHOW_REWARD_COMMON.

%% 领取奖励的判断
check_fetch_reward(Uid, UsrActivityRec, ActivityRec, RewardId) ->
	StateList = get_reward_state_list(Uid, ActivityRec, UsrActivityRec),
	case lists:keyfind(RewardId, #pt_public_gm_act_week_task_des.id, StateList) of
		false -> {error, "error_fetch_reward_not_reached"};
		#pt_public_gm_act_week_task_des{state = ?REWARD_STATE_CAN_FETCH, items = RewardItems} ->
			FetchData = UsrActivityRec#gm_activity_usr.fetch_data,
			Tuple = case lists:keyfind(RewardId, 1, FetchData) of
				false -> {RewardId, 1};
				{_, Times} -> {RewardId, Times + 1}
			end,
			FetchData2      = lists:keystore(RewardId, 1, FetchData, Tuple),
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
			Pt = #pt_gm_act_week_task{},
			?send(Sid, proto:pack(Pt));
		_ -> skip
	end.

do_activity_end_help2(Uid, ActivityRec, PtState) ->
	#pt_public_gm_act_week_task_des{state = State, items = RewardItems} = PtState,
	case State of
		?REWARD_STATE_CAN_FETCH ->
			fun_gm_activity_ex:send_not_fetch_mail(?GM_ACTIVITY_WEEK_TASK, Uid, ActivityRec#gm_activity.act_name, RewardItems, 1);
		_ -> skip
	end.
%% ================================= 通用回调 ==================================

%% =============================================================================
%% ================================ 本模块方法 =================================
handle_task(Uid, Sid, Type, N) ->
	case fun_gm_activity_ex:find_open_activity(?GM_ACTIVITY_WEEK_TASK) of
		false -> skip;
		{true, ActivityRec} ->
			UsrActivityRec = fun_gm_activity_ex:get_usr_activity_data(Uid, ?GM_ACTIVITY_WEEK_TASK),
			handle_task_help(Uid, Sid, Type, N, ActivityRec, UsrActivityRec)
	end.

handle_task_help(Uid, Sid, Type, N, ActivityRec, UsrActivityRec) ->
	ActData = UsrActivityRec#gm_activity_usr.act_data,
	ActData2 = handle_task_help2(ActivityRec#gm_activity.reward_datas, Type, N, ActData),
	UsrActivityRec2 = UsrActivityRec#gm_activity_usr{act_data = ActData2},
	fun_gm_activity_ex:set_usr_activity_data(UsrActivityRec2),
	send_info_to_client(Uid, Sid, ActivityRec, UsrActivityRec2),
	ok.

handle_task_help2([], _Type, _N, Acc) -> Acc; 
handle_task_help2([{Id, Sort, _TabTitle, Condtion, _Items} | Rest], Type, N, Acc) when 
	Type == Sort andalso Sort == ?WEEK_TASK_COST_ITEM ->
	Acc2 = case {Condtion, N} of
		{[NeedItem, Max], [NeedItem, UseNum]} ->
			UseNum2 = fun_gm_activity_ex:get_list_data_by_key(Id, Acc, 0) + UseNum,
			lists:keystore(Id, 1, Acc, {Id, min(Max, UseNum2)});
		_ -> Acc
	end,
	handle_task_help2(Rest, Type, N, Acc2);
handle_task_help2([{Id, Sort, _TabTitle, _Condtion, _Items} | Rest], Type, N, Acc) when 
	Type == Sort andalso Sort == ?WEEK_TASK_LOGIN ->
	Date = N,
	
	LoginDates = fun_gm_activity_ex:get_list_data_by_key(Id, Acc, []),
	Acc2 = case lists:member(Date, LoginDates) of
		true  -> Acc;
		false -> 
			LoginDates2 = [Date | LoginDates],
			lists:keystore(Id, 1, Acc, {Id, LoginDates2})
	end,
	handle_task_help2(Rest, Type, N, Acc2);	
handle_task_help2([{Id, Sort, _TabTitle, Condtion, _Items} | Rest], Type, N, Acc) when Type == Sort ->
	N2   = fun_gm_activity_ex:get_list_data_by_key(Id, Acc, 0) + N,
	Acc2 = lists:keystore(Id, 1, Acc, {Id, min(Condtion, N2)}),
	handle_task_help2(Rest, Type, N, Acc2);
handle_task_help2([{_Id, _Sort, _TabTitle, _Condtion, _Items} | Rest], Type, N, Acc) ->
	handle_task_help2(Rest, Type, N, Acc).


condition_to_list(Condtion) when is_integer(Condtion) -> [Condtion];
condition_to_list(Condtion) when is_tuple(Condtion) -> tuple_to_list(Condtion). 

get_reward_state_list(_Uid, ActivityRec, UsrActivityRec) ->
	%% 同一类的任务只最多显示一个状态不在奖励已领取的
	Datas = ActivityRec#gm_activity.reward_datas,
	% Fun = fun({Id, Sort, TabTitle, Condtion, Items}, {PreId, PreSort, Acc}) ->
	% 	case PreSort == Sort of
	% 		true -> {Id, Sort, Acc};
	% 		false ->
	% 			Acc2 = case PreId /= 0 andalso not (lists:keymember(PreSort, #pt_public_gm_act_week_task_des.sort, Acc)) of
	% 				true -> 
	% 					{_, PreSort2, TabTitle2, Condtion2, Items2} = lists:keyfind(PreId, 1, Datas),
	% 					Pt2 = make_done_pt(PreId, PreSort2, TabTitle2, Condtion2, Items2, ActivityRec, UsrActivityRec),
	% 					[Pt2 | Acc];
	% 				false -> 
	% 					Acc
	% 			end,
	% 			Done = get_done_data(Id, ActivityRec, UsrActivityRec),
	% 			State = get_week_task_state(Id, Sort, Done, Condtion, UsrActivityRec),
	% 			case State of 
	% 				?REWARD_STATE_FETCHED -> 
	% 					{Id, Sort, Acc2};
	% 				_ ->
	% 					Pt22 = make_done_pt(Id, Sort, TabTitle, Condtion, Items, ActivityRec, UsrActivityRec),
	% 					{Id, Sort, [Pt22 | Acc2]}
	% 			end
	% 	end
	% end,
	% {PreId, PreSort, List} = lists:foldl(Fun, {0, 0, []}, Datas),
	% lists:reverse(List).
	get_reward_state_list_help(ActivityRec, UsrActivityRec, Datas, 0, 0, []).

get_reward_state_list_help(ActivityRec, UsrActivityRec, [], PreId, PreSort, Acc) ->
	Datas = ActivityRec#gm_activity.reward_datas,
	case PreId /= 0 andalso not (lists:keymember(PreSort, #pt_public_gm_act_week_task_des.sort, Acc)) of
		true -> 
			{_, PreSort2, TabTitle2, Condtion2, Items2} = lists:keyfind(PreId, 1, Datas),
			Pt2 = make_done_pt(PreId, PreSort2, TabTitle2, Condtion2, Items2, ActivityRec, UsrActivityRec),
			[Pt2 | Acc];
		false -> 
			Acc
	end;
get_reward_state_list_help(ActivityRec, UsrActivityRec, [{Id, Sort, TabTitle, Condtion, Items} | Rest], PreId, PreSort, Acc) ->
	Datas = ActivityRec#gm_activity.reward_datas,
	case PreSort == Sort of
		true -> 
			get_reward_state_list_help(ActivityRec, UsrActivityRec, Rest, Id, Sort, Acc);
		false ->
			Acc2 = case PreId /= 0 andalso not (lists:keymember(PreSort, #pt_public_gm_act_week_task_des.sort, Acc)) of
				true -> 
					{_, PreSort2, TabTitle2, Condtion2, Items2} = lists:keyfind(PreId, 1, Datas),
					Pt2 = make_done_pt(PreId, PreSort2, TabTitle2, Condtion2, Items2, ActivityRec, UsrActivityRec),
					[Pt2 | Acc];
				false -> 
					Acc
			end,
			Done = get_done_data(Id, ActivityRec, UsrActivityRec),
			State = get_week_task_state(Id, Sort, Done, Condtion, UsrActivityRec),
			case State of 
				?REWARD_STATE_FETCHED -> 
					get_reward_state_list_help(ActivityRec, UsrActivityRec, Rest, Id, Sort, Acc2);
				_ ->
					Pt22 = make_done_pt(Id, Sort, TabTitle, Condtion, Items, ActivityRec, UsrActivityRec),
					get_reward_state_list_help(ActivityRec, UsrActivityRec, Rest, Id, Sort, [Pt22 | Acc2])
			end
	end.



make_done_pt(Id, Sort, TabTitle, Condtion, Items, ActivityRec, UsrActivityRec) ->
	Done = get_done_data(Id, ActivityRec, UsrActivityRec),
	State = get_week_task_state(Id, Sort, Done, Condtion, UsrActivityRec),
	#pt_public_gm_act_week_task_des{
		id        = Id,
		sort      = Sort,
		tab_title = TabTitle,
		done      = Done,
		condtion  = Condtion,
		items     = lists:map(fun fun_item_api:make_item_get_pt/1, Items),
		state     = State
	}.


get_done_data(Id, ActivityRec, UsrActivityRec) ->
	case lists:keyfind(Id, 1, UsrActivityRec#gm_activity_usr.act_data) of
		false -> 0;
		{_, Done} -> 
			case lists:keyfind(Id, 1, ActivityRec#gm_activity.reward_datas) of
				{_Id, Sort, _TabTitle, _Condtion, _Items} when Sort == ?WEEK_TASK_LOGIN ->
					length(Done);
				_ -> Done
			end
	end.

get_week_task_state(Id, Sort, Done, Condtion, UsrActivityRec) ->
	case lists:keyfind(Id, 1, UsrActivityRec#gm_activity_usr.fetch_data) of
		false -> 
			case is_task_finished(Sort, Done, Condtion) of
				true -> ?REWARD_STATE_CAN_FETCH;
				false -> ?REWARD_STATE_NOT_REACHED
			end;
		_ -> ?REWARD_STATE_FETCHED
	end.

is_task_finished(?WEEK_TASK_COST_ITEM, Done, [_ItemType, Num]) -> Done >= Num;
is_task_finished(_, Done, [Num]) -> Done >= Num.



%% =============================================================================
%% ========================= 测试方法 ==========================================
% world_svr:debug_call(10, fun() -> fun_gm_activity_ex:test_set_config() end).
% world_svr:debug_call(10, fun() -> fun_gm_activity_ex:test_del_config() end).
test_set_config() ->
	ActivityRec = #gm_activity{
		act_id       = ?GM_ACTIVITY_WEEK_TASK,
		act_name     = "name",
		type         = ?GM_ACTIVITY_WEEK_TASK,
		start_time   = util:unixtime() + 10,
		end_time     = util:unixtime() + 20000,
		act_des      = "ActDes",
		setting      = [],
		reward_datas = util:term_to_string(test_reward_datas(?GM_ACTIVITY_WEEK_TASK))
	},
	db:insert(ActivityRec),
	fun_gm_activity_ex:activity_config_help(ActivityRec),
	ok.	

test_del_config() ->
	fun_gm_activity_ex:del_config(?GM_ACTIVITY_WEEK_TASK, ?GM_ACTIVITY_WEEK_TASK).

test_reward_datas(?GM_ACTIVITY_WEEK_TASK) ->
	[].
