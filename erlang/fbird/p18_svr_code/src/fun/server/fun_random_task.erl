-module(fun_random_task).
-include("common.hrl").
% -export([check_random_task/2,req_random_task/3,req_get_task_reward/3]).
% -export([do_get_diamond/3,do_arena_rank/3,do_vip_lev/3,do_pass_copy/2,do_add_entourage/2,do_throw_copy/2,do_use_diamond/3]).
% -export([do_global_rank/3,do_melleboss/2,do_recharge/3]).
% -export([req_give_up_task/3]).


% -define(NONE_NEED,	0).
% -define(VIP_LEV,	1).

% -define(NO_TASK,	0).
% -define(HAVE_TASK,	1).

% -define(NOT_POP,	0).
% -define(POP,		1).

% get_data(Uid) -> fun_usr_misc:get_misc_data(Uid, random_task).

% set_data(Uid, Val) -> fun_usr_misc:set_misc_data(Uid, random_task, Val).

% do_get_diamond(Uid,Sid,N) -> handle_task(Uid,Sid,?TASK_GET_DIOMAND,N).
% do_arena_rank(Uid,Sid,N) -> handle_task(Uid,Sid,?TASK_AREAN_RANK,N).
% do_vip_lev(Uid,Sid,N) -> handle_task(Uid,Sid,?TASK_VIP_LEV,N).
% do_pass_copy(Uid,Sid) -> handle_task(Uid,Sid,?TASK_PASS_RANDOM_BARRIER).
% do_add_entourage(Uid,Sid) -> handle_task(Uid,Sid,?TASK_ENTOURAGE_NUM).
% do_throw_copy(Uid,Sid) -> handle_task(Uid,Sid,?TASK_THROW_BARRIER).
% do_use_diamond(Uid,Sid,N) -> handle_task(Uid,Sid,?TASK_USE_DIOMAND,N).
% do_global_rank(Uid,Sid,N) -> handle_task(Uid,Sid,?TASK_RANK_LEV,N).
% do_melleboss(Uid,Sid) -> handle_task(Uid,Sid,?TASK_MELLEBOSS_BOSS).
% do_recharge(Uid,Sid,N) -> handle_task(Uid,Sid,?TASK_RECHARGE_DIAMOND,N).

% handle_task(Uid,Sid,Type) ->
% 	handle_task(Uid,Sid,Type,1).
% handle_task(Uid,Sid,Type,N) ->
% 	Now = util_time:unixtime(),
% 	case get_data(Uid) of
% 		{false,_,_,_,_,_} -> skip;
% 		{true,TaskId,{Type1,Num1},{Type2,Num2},EndTime,CheckId} when EndTime >= Now ->
% 			case data_random_task:get_data(TaskId) of
% 				#st_random_task{id=TaskId,type1=Type1,need1=Need1,type2=Type2,need2=Need2} ->
% 					NewNum1 = case Type of
% 						Type1 -> check_add_num(Type1,Need1,Num1,N);
% 						_ -> Num1
% 					end,
% 					NewNum2 = case Type of
% 						Type2 -> check_add_num(Type2,Need2,Num2,N);
% 						_ -> Num2
% 					end,
% 					set_data(Uid,{true,TaskId,{Type1,NewNum1},{Type2,NewNum2},EndTime,CheckId}),
% 					send_info_to_client(Uid,Sid,0,?NOT_POP);
% 				_ -> skip
% 			end;
% 		_ -> skip
% 	end.

% req_random_task(Uid,Sid,Seq) ->
% 	send_info_to_client(Uid,Sid,Seq,?NOT_POP).

% req_get_task_reward(Uid,Sid,Seq) ->
% 	Now = util_time:unixtime(),
% 	case get_data(Uid) of
% 		{true,TaskId,{Type1,Num1},{Type2,Num2},EndTime,CheckId} ->
% 			case data_random_task:get_data(TaskId) of
% 				#st_random_task{id=TaskId,type1=Type1,need1=Need1,type2=Type2,need2=Need2,reward1=RewardList1,reward2=RewardList2} ->
% 					Status1 = check_status(Type1,Need1,Num1),
% 					Status2 = check_status(Type2,Need2,Num2),
% 					{Reason,AddItem,ShowList} = do_reward_help2(Status1,Status2,RewardList1,RewardList2),
% 					% ?debug("Reason~p",[Reason]),
% 					case (Reason == double) orelse (Reason == single andalso Now >= EndTime) of
% 						true ->
% 							set_data(Uid, {false,TaskId,{0,0},{0,0},0,CheckId}),
% 							Succ = fun() ->
% 								fun_item_api:send_show_fetched_reward(Uid, Sid, ?SHOW_REWARD_COMMON, ShowList),
% 								send_info_to_client(Uid,Sid,Seq,?NOT_POP)
% 							end,
% 							fun_item_api:check_and_add_items(Uid,Sid,[],AddItem,Succ,undefined);
% 						_ -> skip
% 					end;
% 				_ -> skip
% 			end;
% 		_ -> skip
% 	end.

% req_give_up_task(Uid,Sid,Seq) ->
% 	Now = util_time:unixtime(),
% 	case get_data(Uid) of
% 		{true,TaskId,{Type1,Num1},{Type2,Num2},EndTime,CheckId} when Now >= EndTime ->
% 			case data_random_task:get_data(TaskId) of
% 				#st_random_task{id=TaskId,type1=Type1,need1=Need1,type2=Type2,need2=Need2,reward1=RewardList1,reward2=RewardList2} ->
% 					Status1 = check_status(Type1,Need1,Num1),
% 					Status2 = check_status(Type2,Need2,Num2),
% 					{Reason,_,_} = do_reward_help2(Status1,Status2,RewardList1,RewardList2),
% 					case Reason == false of
% 						true ->
% 							set_data(Uid, {false,TaskId,{0,0},{0,0},0,CheckId}),
% 							send_info_to_client(Uid,Sid,Seq,?NOT_POP);
% 						_ -> skip
% 					end;
% 				_ -> skip
% 			end;
% 		_ -> skip
% 	end.

% do_reward_help2(Status1,Status2,RewardList1,RewardList2) ->
% 	if  Status1 == 1 andalso Status2 == 1 ->
% 			List = util_list:add_and_merge_list(RewardList1, RewardList2, 1, 2),
% 			AddList = [{?ITEM_WAY_RANDOM_TASK,T,N} || {T,N} <- List],
% 			{double,AddList,List};
% 		Status1 == 1 andalso Status2 == 0 ->
% 			List = [{?ITEM_WAY_RANDOM_TASK,T,N} || {T,N} <- RewardList1],
% 			{single,List,RewardList1};
% 		Status1 == 0 andalso Status2 == 1 ->
% 			List = [{?ITEM_WAY_RANDOM_TASK,T,N} || {T,N} <- RewardList2],
% 			{single,List,RewardList2};
% 		true -> {false,[],[]}
% 	end.

% check_random_task(Uid, Sid) ->
% 	case mod_scene_lev:get_curr_scene_lv(Uid) >= util:get_data_para_num(1088) of
% 		true -> 
% 			case get_data(Uid) of
% 				{false,TaskId,_,_,_,_} ->					
% 					case TaskId >= data_random_task:get_max_task() of 
% 						true -> skip;
% 						_ -> check_random_task2(Uid, Sid)
% 					end;
% 				_ ->
% 					skip
% 			end;
% 		_ -> skip
% 	end.

% check_random_task2(Uid, Sid) ->
% 	Rate = case get(random_task_probability) of
% 		undefined ->
% 			put(random_task_probability,0),
% 			0;
% 		Rate1 -> Rate1
% 	end,
% 	Rand = util:rand(0, 9999),
% 	case Rand >= Rate of
% 		false ->
% 			put(random_task_probability,0),
% 			do_random_task_help(Uid, Sid);
% 		_ -> 
% 			put(random_task_probability,Rate + (util:get_data_para_num(1087) * 100))
% 	end.

% do_random_task_help(Uid, Sid) ->
% 	case db:dirty_get(usr, Uid) of
% 		[#usr{vip_lev=VipLev}] ->
% 			Now = util:unixtime(),
% 			case get_data(Uid) of
% 				{false,TaskId,_,_,EndTime,CheckId} when Now > EndTime ->
% 					% ?debug("TaskId=~p,CheckId=~p",[TaskId,CheckId]),
% 					NewTaskId = check_task_id(TaskId+1,CheckId),
% 					% ?debug("NewTaskId=~p",[NewTaskId]),
% 					case NewTaskId > data_random_task:get_max_task() of
% 						true -> 
% 							set_data(Uid, {false,NewTaskId,{0,0},{0,0},0,CheckId}),
% 							send_info_to_client(Uid, Sid, 0, ?NOT_POP);
% 						_ ->
% 							case data_random_task:get_data(NewTaskId) of
% 								#st_random_task{id=NewTaskId,step=Step,condition=Condition,type1=Type1,need1=Need1,type2=Type2,need2=Need2} ->
% 									case Condition of
% 										{?NONE_NEED,_} ->
% 											Num1 = check_num(Type1,Need1,fun_task_condition:init_condition({Type1,0,0},Uid)),
% 											Num2 = check_num(Type2,Need2,fun_task_condition:init_condition({Type2,0,0},Uid)),
% 											set_data(Uid,{true,NewTaskId,{Type1,Num1},{Type2,Num2},Now + ?ONE_DAY_SECONDS,Step}),
% 											send_info_to_client(Uid, Sid, 0, ?POP);
% 										{?VIP_LEV,NeedNum} ->
% 											Tuple = other_task_set(Uid,VipLev,NeedNum,NewTaskId,Now+?ONE_DAY_SECONDS,Step),
% 											set_data(Uid, Tuple),
% 											send_info_to_client(Uid, Sid, 0, ?POP)
% 									end;
% 								_ -> skip
% 							end
% 					end;
% 				_ -> skip
% 			end;
% 		_ -> skip
% 	end.

% other_task_set(Uid,Num,_NeedNum,TaskId,Time,CheckId) ->
% 	#st_random_task{id=TaskId,type1=Type1,need1=Need1,type2=Type2,need2=Need2,condition={_,NewNeedNum}} = data_random_task:get_data(TaskId),
% 	% ?debug("Num=~p,NewNeedNum=~p",[Num,NewNeedNum]),
% 	case Num >= NewNeedNum of
% 		true ->
% 			Num1 = check_num(Type1,Need1,fun_task_condition:init_condition({Type1,0,0},Uid)),
% 			Num2 = check_num(Type2,Need2,fun_task_condition:init_condition({Type2,0,0},Uid)),
% 			{true,TaskId,{Type1,Num1},{Type2,Num2},Time,CheckId};
% 		_ -> 
% 			other_task_set(Uid,Num,NewNeedNum,TaskId+1,Time,CheckId)
% 	end.

% check_num(Type,{NeedNum,_},Num) ->
% 	NewNum = case Type of
% 		?TASK_AREAN_RANK ->
% 			case Num =< NeedNum of
% 				true -> NeedNum;
% 				_ -> Num
% 			end;
% 		_ ->
% 			case Num >= NeedNum of
% 				true -> NeedNum;
% 				_ -> Num
% 			end
% 	end,
% 	NewNum.

% check_add_num(Type,{NeedNum,_},Num,N) ->
% 	NewNum = case Type of
% 		?TASK_AREAN_RANK ->
% 			case N =< NeedNum of
% 				true -> NeedNum;
% 				_ -> N
% 			end;
% 		?TASK_RANK_LEV ->
% 			case N >= NeedNum of
% 				true -> NeedNum;
% 				_ -> N
% 			end;
% 		_ ->
% 			case Num + N >= NeedNum of
% 				true -> NeedNum;
% 				_ -> Num + N
% 			end
% 	end,
% 	NewNum.

% check_task_id(TaskId,CheckId) ->
% 	case data_random_task:get_data(TaskId) of
% 		#st_random_task{id=TaskId,step=Step} ->
% 			case Step == CheckId of
% 				true -> check_task_id(TaskId+1,CheckId);
% 				_ -> TaskId
% 			end;
% 		_ -> data_random_task:get_max_task() + 1
% 	end.

% check_status(Type,{NeedNum,_},Num) ->
% 	Status = case Type of
% 		?TASK_AREAN_RANK ->
% 			case Num =< NeedNum of
% 				true -> 1;
% 				_ -> 0
% 			end;
% 		_ ->
% 			case Num >= NeedNum of
% 				true -> 1;
% 				_ -> 0
% 			end
% 	end,
% 	Status.

% check_pt_num(Type,{NeedNum,_},Num) ->
% 	case Type of
% 		?TASK_AREAN_RANK ->
% 			case Num =< NeedNum of
% 				true -> 1;
% 				_ -> 0
% 			end;
% 		?TASK_RANK_LEV ->
% 			case Num >= NeedNum of
% 				true -> 1;
% 				_ -> 0
% 			end;
% 		_ ->
% 			case Num >= NeedNum of
% 				true -> NeedNum;
% 				_ -> Num
% 			end
% 	end.

% send_info_to_client(Uid, Sid, Seq, IsPop) ->
% 	{IsTask,NewTaskId,NewNum1,NewStatus1,NewNum2,NewStatus2,NewEndTime} = case get_data(Uid) of
% 		{false,TaskId,_,_,_,_} -> {?NO_TASK,TaskId,0,0,0,0,0};
% 		{true,TaskId,{Type1,Num1},{Type2,Num2},EndTime,_} ->
% 			case data_random_task:get_data(TaskId) of
% 				#st_random_task{id=TaskId,type1=Type1,need1=Need1,type2=Type2,need2=Need2} -> 
% 					Status1 = check_status(Type1,Need1,Num1),
% 					Status2 = check_status(Type2,Need2,Num2),
% 					Num11 = check_pt_num(Type1,Need1,Num1),
% 					Num21 = check_pt_num(Type2,Need2,Num2),
% 					{?HAVE_TASK,TaskId,Num11,Status1,Num21,Status2,EndTime};
% 				_ -> {?NO_TASK,TaskId,0,0,0,0,0}
% 			end
% 	end,
% 	Pt = #pt_random_task{
% 			is_task 	= IsTask,
% 			task_id 	= NewTaskId,
% 			task1_num 	= NewNum1,
% 			task1_status= NewStatus1,
% 			task2_num 	= NewNum2,
% 			task2_status= NewStatus2,
% 			end_time 	= NewEndTime,
% 			is_pop		= IsPop
% 	},
% 	?send(Sid,proto:pack(Pt,Seq)).