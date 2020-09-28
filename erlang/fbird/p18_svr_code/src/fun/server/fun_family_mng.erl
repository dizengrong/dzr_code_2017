%% @doc 家园管理全局进程
-module (fun_family_mng).
-include("common.hrl").


-export([do_init/0,do_close/0,do_call/1,do_info/1,do_time/1,do_msg/1]).

do_init()-> 
	Time = util_time:unixtime(),
	fun_family:check_time(Time),
	{_Date, {_Hour, Min, _}} = util_time:seconds_to_datetime(Time),
	put(world_minute,Min),
	ok.


do_close() -> ok.

do_time(Time) -> 
	Now = Time div 1000,
	check_clock(Now),
	1000.

check_clock(Now) ->
	{_Date, {_Hour, Min, _}} = util_time:seconds_to_datetime(Now),
	case get(world_minute) of
		Min -> skip;
		_ ->
			put(world_minute, Min),
			do_minute_loop(Now)
	end.

do_minute_loop(Now) -> 
	fun_family:check_time(Now).

do_call(_) -> 
	skip.


do_info({timeout, _TimerRef, CallBackInfo}) ->
	case CallBackInfo of
		{Module, Function} ->
			try
				Module:Function()
			catch E:R ->?log_error("timeout error,data=~p,E=~p,R=~p,stack=~p",[CallBackInfo,E,R,erlang:get_stacktrace()])
			end;
		{Module, Function, Args} ->
			try
				Module:Function(Args)
			catch E:R ->?log_error("timeout error,data=~p,E=~p,R=~p,stack=~p",[CallBackInfo,E,R,erlang:get_stacktrace()])
			end;
		_ ->
			?log_warning("unknown timer callback,CallbackInfo=~p", [CallBackInfo])
	end;

do_info(_Info) -> ok.

do_msg({handle_msg,Module,Msg}) -> Module:handle(Msg);

do_msg({action_int,Action,Uid,Sid,Seq,Data}) ->
	case Action of
		?ACTION_REQ_HALL_REWARD -> fun_family:req_hall_reward(Uid,Sid,Data,Seq);
		?ACTION_REQ_HOME_BUILDING_LIST -> fun_family:req_building_list(Uid, Sid, Data, Seq);
		?ACTION_REQ_REMOVE_COMMANDER -> fun_family:req_remove_commander(Uid, Sid, Data, Seq);
		?ACTION_REQ_BUY_QUICK_MINE -> fun_family:req_quick_mine(Uid, Sid, Data, Seq);
		_ -> skip
	end;

do_msg({action_two_int_d012,Action,Uid,Sid,Data1,Data2,Seq})->
	case Action of
		?ACTION_REQ_JOIN_MEETING -> fun_family:req_join_meeting(Uid, Sid, Data1, Data2, Seq);
		_ -> skip
	end;

do_msg({join_result_from_other_server, IsSucc, _ServerID, Uid}) ->
	fun_family:join_result_from_other_server({IsSucc, Uid});

do_msg({join_meeting_from_other_server, FromServerID, FromServerName, FromUid, Uid, FromName}) ->
	fun_family:join_meeting_from_other_server({FromServerID, FromServerName, FromUid, Uid, FromName});

do_msg({upgrade_home_building, {BuildingId, Seq}}) ->
	fun_family:begin_upgrade_building({BuildingId, Seq});

do_msg({on_early_get_hall_reward, {Uid, Sid, BuildingId, Seq}}) ->
	fun_family:early_get_hall_reward({Uid, Sid, BuildingId, Seq});

do_msg({enable_home, Uid}) ->
	fun_family:enable_home(Uid);

do_msg({begin_meeting, Uid, Sid, BuildingId, Seq}) ->
	fun_family:begin_meeting(Uid, Sid, BuildingId, Seq);

do_msg({on_building_upgrade_complete, BuildingId}) ->
	fun_family:on_building_upgrade_complete(BuildingId);

do_msg({get_mine_reward, {BuildingId, Seq}}) ->
	fun_family:get_mine_reward_complete(BuildingId, Seq);

do_msg({settled_commander, {Uid, Sid, BuildingId, HeroType, Seq}}) ->
	fun_family:settled_commander(Uid, Sid, BuildingId, HeroType, Seq);

do_msg({settled_worker, {Uid, Sid, TargetUid, BuildingId, HeroType, Seq}}) ->
	fun_family:settled_worker(Uid, Sid, TargetUid, BuildingId, HeroType, Seq);

do_msg({on_institue_skill_upgrade, {BuildingId, SkillId, Seq}}) ->
	fun_family:upgrade_institue_skill(BuildingId, SkillId, Seq);

do_msg(_Msg) -> 
	?debug("unhandled family msg,msg=~p",[_Msg]),
	ok.





