%% 主线任务模块
-module(fun_main_task).
-include("common.hrl"). 
-export([init_data/1, on_login/1]).
-export([init_listener_events/1, reset_listener_events/1, on_role_event/5]).
-export([req_task_reward/3, req_chapter_rewards/3, send_info_to_client/3]).

%% =============================================================================
init_data(Uid) ->
	Count = init_count(Uid, 1, 1),
	{Status, NewCount} = check_count(1, 1, Count),
	Rec = #t_main_task{
		uid     = Uid,
		task_id = 1,
		chapter = 1,
		count   = NewCount,
		status  = Status
	},
	set_data(Rec).

get_data(Uid) -> 
	case mod_role_tab:lookup(Uid, t_main_task) of
		[] -> #t_main_task{uid = Uid};
		[Rec] -> Rec
	end.

set_data(Rec) -> 
	mod_role_tab:insert(Rec#t_main_task.uid, Rec).
%% =============================================================================

on_login(Uid) ->
	Rec = get_data(Uid),
	TaskId = Rec#t_main_task.task_id,
	Chapter = Rec#t_main_task.chapter,
	case Rec#t_main_task.status of
		?NO_ACCEPT_STATE ->
			case data_main_task:get_task_data(TaskId, Chapter) of
				{_, _, _} ->
					Count = init_count(Uid, TaskId, Chapter),
					{Status, NewCount} = check_count(TaskId, Chapter, Count),
					NewRec = Rec#t_main_task{status = Status, count = NewCount},
					set_data(NewRec),
					init_listener_events(Uid);
				_ -> skip
			end;
		?FINISH_STATE ->
			case data_main_task:get_next_task(TaskId, Chapter) of
				0 -> skip;
				NewTask ->
					Count = init_count(Uid, NewTask, Chapter),
					{Status, NewCount} = check_count(NewTask, Chapter, Count),
					NewRec = Rec#t_main_task{task_id = NewTask, status = Status, count = NewCount},
					set_data(NewRec),
					init_listener_events(Uid)
			end;
		_ -> skip
	end.

init_count(Uid, TaskId, Chapter) ->
	 case data_main_task:get_task_data(TaskId, Chapter) of
		{Type, _, _} -> fun_condition:init_condition(Type, Uid);
		_ -> 0
	end.

init_listener_events(Uid) ->
	#t_main_task{task_id = TaskId, chapter = Chapter} = get_data(Uid),
	case data_main_task:get_task_data(TaskId, Chapter) of 
		{Type, _, _} -> mod_role_event:register_listener(?MODULE, Type);
		_ -> skip
	end,
	ok.

reset_listener_events(Uid) ->
	mod_role_event:unregister_listener(?MODULE),
	init_listener_events(Uid),
	ok.

%% 任务事件
on_role_event(Uid, Sid, EventType, Val1, Val2) ->
	Rec = get_data(Uid),
	case Rec#t_main_task.status of
		?ACCEPT_STATE ->
			TaskId = Rec#t_main_task.task_id,
			Chapter = Rec#t_main_task.chapter,
			Num = Rec#t_main_task.count,
			{Type, NeedNum, NeedVal} = data_main_task:get_task_data(TaskId, Chapter),
			case fun_condition:is_condition_matched({Type, NeedVal, NeedNum},{EventType, Val1, Val2}) of
				true ->
					{IsFinished, NewNum} = fun_condition:is_condition_finished(Uid, {EventType, Val1, Val2}, Num, {Type, NeedVal, NeedNum}),
					NewRec = if
						IsFinished -> Rec#t_main_task{status = ?CAN_FINISH_STATE, count = NeedNum};
						true -> Rec#t_main_task{count = NewNum}
					end,
					set_data(NewRec),
					send_info_to_client(Uid, Sid, 0);
				_ -> skip
			end;
		_ -> skip
	end.

req_task_reward(Uid, Sid, Seq) ->
	Rec = get_data(Uid),
	case Rec#t_main_task.status of
		?CAN_FINISH_STATE ->
			TaskId = Rec#t_main_task.task_id,
			Chapter = Rec#t_main_task.chapter,
			AddItem = data_main_task:get_task_reward(TaskId, Chapter),
			Succ = fun() ->
				NewRec = case data_main_task:get_next_task(TaskId, Chapter) of
					0 -> Rec#t_main_task{status = ?FINISH_STATE};
					NextTask ->
						Count = init_count(Uid, NextTask, Chapter),
						{Status, NewCount} = check_count(NextTask, Chapter, Count),
						Rec#t_main_task{task_id = NextTask, count = NewCount, status = Status}
				end,
				set_data(NewRec),
				reset_listener_events(Uid),
				fun_item_api:send_show_fetched_reward(Uid, Sid, ?SHOW_REWARD_COMMON, AddItem),
				send_info_to_client(Uid, Sid, Seq)
			end,
			Args = #api_item_args{
				way      = ?ITEM_WAY_MAIN_TASK,
				add      = AddItem,
				succ_fun = Succ
			},
			fun_item_api:add_items(Uid, Sid, Seq, Args);
		_ -> skip
	end.

req_chapter_rewards(Uid, Sid, Seq) ->
	Rec = get_data(Uid),
	case Rec#t_main_task.status of
		?FINISH_STATE ->
			Chapter = Rec#t_main_task.chapter,
			AddItem = data_main_task:get_chapter_reward(Chapter),
			Succ = fun() ->
				{Status, NewCount} = case data_main_task:get_chapter_reward(Chapter + 1) of
					[] -> {?NO_ACCEPT_STATE, 0};
					_ ->
						Count = init_count(Uid, 1, Chapter + 1),
						check_count(1, Chapter + 1, Count)
				end,
				NewRec = Rec#t_main_task{task_id = 1, chapter = Chapter + 1, count = NewCount, status = Status},
				set_data(NewRec),
				fun_item_api:send_show_fetched_reward(Uid, Sid, ?SHOW_REWARD_COMMON, AddItem),
				send_info_to_client(Uid, Sid, Seq)
			end,
			Args = #api_item_args{
				way      = ?ITEM_WAY_CHAPTER,
				add      = AddItem,
				succ_fun = Succ
			},
			fun_item_api:add_items(Uid, Sid, Seq, Args);
		_ -> skip
	end.

send_info_to_client(Uid, Sid, Seq) ->
	Rec = get_data(Uid),
	Pt = #pt_main_task_info{
		status    = Rec#t_main_task.status,
		task_id   = Rec#t_main_task.task_id,
		chapter   = Rec#t_main_task.chapter,
		task_list = [#pt_public_task_list{num = Rec#t_main_task.count}]
	},
	?send(Sid, proto:pack(Pt, Seq)).

check_count(TaskId, Chapter, OldCount) ->
	{_, NeedVal, _} = data_main_task:get_task_data(TaskId, Chapter),
	if
		OldCount >= NeedVal -> {?CAN_FINISH_STATE, NeedVal};
		true -> {?ACCEPT_STATE, OldCount}
	end.