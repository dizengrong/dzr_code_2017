%% 每日任务模块
-module(fun_daily_task).
-include("common.hrl"). 
-export([refresh_data/1]).
-export([init_listener_events/1, reset_listener_events/1, on_role_event/5]).
-export([req_task_reward/4, req_all_rewards/3, send_info_to_client/3]).

%% =============================================================================
get_data(Uid) -> 
	case mod_role_tab:lookup(Uid, t_daily_task) of
		[] -> #t_daily_task{uid = Uid, status = ?ACCEPT_STATE};
		[Rec] -> Rec
	end.

set_data(Rec) -> 
	mod_role_tab:insert(Rec#t_daily_task.uid, Rec).
%% =============================================================================

refresh_data(Uid) ->
	List = data_daily_task:get_all_task(),
	Rec = get_data(Uid),
	NewList = [refresh_data_help(Uid, Task) || Task <- List],
	NewRec = Rec#t_daily_task{tasks = NewList, status = ?ACCEPT_STATE},
	set_data(NewRec),
	reset_listener_events(Uid),
	send_info_to_client(Uid, get(sid), 0).

refresh_data_help(Uid, Task) ->
	{Type, _, _} = data_daily_task:get_task_data(Task),
	Count = fun_condition:init_condition(Type, Uid),
	{Status, NewCount} = check_count(Task, Count),
	{Task, NewCount, Status}.

check_count(Task, OldCount) ->
	{_, NeedVal, _} = data_daily_task:get_task_data(Task),
	if
		OldCount >= NeedVal -> {?CAN_FINISH_STATE, NeedVal};
		true -> {?ACCEPT_STATE, OldCount}
	end.

init_listener_events(Uid) ->
	#t_daily_task{tasks = TaskList} = get_data(Uid),
	Fun = fun({Task, _, Status}) ->
		case data_daily_task:get_task_data(Task) of 
			{Type, _, _} when Status == ?ACCEPT_STATE -> mod_role_event:register_listener(?MODULE, Type);
			_ -> skip
		end
	end,
	lists:foreach(Fun, TaskList),
	ok.

reset_listener_events(Uid) ->
	mod_role_event:unregister_listener(?MODULE),
	init_listener_events(Uid),
	ok.

%% 任务事件
on_role_event(Uid, Sid, EventType, Val1, Val2) ->
	Rec = get_data(Uid),
	TaskList = Rec#t_daily_task.tasks,
	NewList = [on_role_event_help(Uid, Task, Count, Status, EventType, Val1, Val2) || {Task, Count, Status} <- TaskList],
	NewTaskList = [{Task, Count, Status} || {Task, Count, Status, _} <- NewList],
	if
		NewTaskList == TaskList -> skip;
		true ->
			Funfilter = fun({_, _, Status}) ->
				if
					Status == ?CAN_FINISH_STATE orelse Status == ?FINISH_STATE -> true;
					true -> false
				end
			end,
			OldStatus = Rec#t_daily_task.status,
			NewRec1 = Rec#t_daily_task{tasks = NewTaskList},
			NewRec = if
				OldStatus == ?ACCEPT_STATE ->
					case length(NewTaskList) == length(lists:filter(Funfilter, NewTaskList)) of
						true -> NewRec1#t_daily_task{status = ?CAN_FINISH_STATE};
						_ -> NewRec1
					end;
				true -> NewRec1
			end,
			set_data(NewRec),
			case lists:keyfind(1, 4, NewList) of
				false -> skip;
				_ -> reset_listener_events(Uid)
			end,
			send_info_to_client(Uid, Sid, 0)
	end.

on_role_event_help(Uid, Task, Count, Status, EventType, Val1, Val2) ->
	case Status of
		?ACCEPT_STATE ->
			{Type, NeedNum, NeedVal} = data_daily_task:get_task_data(Task),
			case fun_condition:is_condition_matched({Type, NeedVal, NeedNum},{EventType, Val1, Val2}) of
				true ->
					{IsFinished, NewNum} = fun_condition:is_condition_finished(Uid, {EventType, Val1, Val2}, Count, {Type, NeedVal, NeedNum}),
					if
						IsFinished -> {Task, NeedNum, ?CAN_FINISH_STATE, 1};
						true -> {Task, NewNum, ?ACCEPT_STATE, 0}
					end;
				_ -> {Task, Count, Status, 0}
			end;
		_ -> {Task, Count, Status, 0}
	end.

req_task_reward(Uid, Sid, Seq, Task) ->
	Rec = get_data(Uid),
	case lists:keyfind(Task, 1, Rec#t_daily_task.tasks) of
		{Task, Count, Status} when Status == ?CAN_FINISH_STATE ->
			AddItems = data_daily_task:get_task_reward(Task),
			Succ = fun() ->
				NewList = lists:keystore(Task, 1, Rec#t_daily_task.tasks, {Task, Count, ?FINISH_STATE}),
				NewRec = Rec#t_daily_task{tasks = NewList},
				set_data(NewRec),
				fun_item_api:send_show_fetched_reward(Uid, Sid, ?SHOW_REWARD_COMMON, AddItems),
				send_info_to_client(Uid, Sid, Seq)
			end,
			Args = #api_item_args{
				way      = ?ITEM_WAY_DAILY_TASK,
				add      = AddItems,
				succ_fun = Succ
			},
			fun_item_api:add_items(Uid, Sid, Seq, Args);
		_ -> skip
	end.

req_all_rewards(Uid, Sid, Seq) ->
	Rec = get_data(Uid),
	case Rec#t_daily_task.status of
		?CAN_FINISH_STATE ->
			AddItems = data_daily_task:get_reward(),
			Succ = fun() ->
				NewRec = Rec#t_daily_task{status = ?FINISH_STATE},
				set_data(NewRec),
				fun_item_api:send_show_fetched_reward(Uid, Sid, ?SHOW_REWARD_COMMON, AddItems),
				send_info_to_client(Uid, Sid, Seq)
			end,
			Args = #api_item_args{
				way      = ?ITEM_WAY_DAILY_TASK,
				add      = AddItems,
				succ_fun = Succ
			},
			fun_item_api:add_items(Uid, Sid, Seq, Args);
		_ -> skip
	end.

send_info_to_client(Uid, Sid, Seq) ->
	Rec = get_data(Uid),
	Pt = #pt_daily_task_info{
		status    = Rec#t_daily_task.status,
		task_list = [#pt_public_task_list{task_id = Task, num = Count, status = Status} || {Task, Count, Status} <- Rec#t_daily_task.tasks]
	},
	?send(Sid, proto:pack(Pt, Seq)).