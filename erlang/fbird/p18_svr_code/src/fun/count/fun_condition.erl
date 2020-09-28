-module(fun_condition).
-include("common.hrl").
-export([
	init_conditions/2,check_conditions/3,
	init_condition/2,is_condition_finished/4,is_condition_matched/2
]).

%%检查任务可以提交
check_conditions(Uid,Conditions,DO) -> 
	case Conditions of
		[] -> true;
		[Condition = {C1, C2, _}] -> 
			{Ret, _} = is_condition_finished(Uid, {C1, C2, DO}, 0, Condition),
		  	Ret
	end.


init_conditions(Conditions,Pid) -> 
	case Conditions of
		[] -> 0;
		[Condition] ->	
			InitVal = init_condition(Condition,Pid),
			InitVal
	end.

init_condition(?TASK_PASS_STAGE, Uid) ->
	mod_scene_lev:get_curr_scene_lv(Uid);

init_condition(_C, _Uid) -> 0.

is_condition_matched({DoEvent, _, _}, {CnfEvent, _, _}) ->
	DoEvent == CnfEvent.

is_condition_finished(_Uid, {EventType, DoC2, DoNum}, OldDoNum, {EventType, NeedC2, NeedNum}) ->
	case is_condition_val2_matched(EventType, DoC2, NeedC2) of
		true -> 
			NewDoNum = case fun_count:count_type(EventType) of
				?COUNT_TYPE_INCR -> DoNum + OldDoNum;
				_ -> DoNum
			end,
			is_condition_finished2(EventType, NewDoNum, NeedNum, OldDoNum);
		false -> {false, OldDoNum}
	end;
is_condition_finished(_Uid, _, _OldDoNum, _) -> {false, 0}.

%% 返回:{是否完成了, 完成数量（如果是超过了，则返回超过的了）}
is_condition_finished2(EventType, NewDoNum, NeedNum, OldDoNum) ->
	case is_event_reverse(EventType) of
		true -> 
			{NewDoNum =< NeedNum, min(NewDoNum, OldDoNum)};
		_ ->
			{NewDoNum >= NeedNum, max(NewDoNum, OldDoNum)}
	end.

%% 默认第二个参数要大于等于才行，有必须要等于才算的在这里区分
is_condition_val2_matched(_EventType, DoC2, NeedC2) -> DoC2 == NeedC2.

%% 有些计数类型是值越小反而表示越大，比如排行榜相关的
is_event_reverse(_) -> false.