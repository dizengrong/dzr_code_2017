%% @doc 玩家的定时器更新处理（只能在玩家进程中调用），主要处理如下相似的业务逻辑：
% 	玩家有一个次数需要定时恢复，这个定时器到期时增加次数，如果下线了，这个定时器要持久化的
% 	然后在上线时，根据时间差计算需要恢复多少次。
% 	因为可能存在多个这样的相同需求，为了避免重复编写代码，就写了这个模块来统一处理
%   具体使用可以参照项目中已存在的案例
-module (mod_role_timer_updater).
-include("common.hrl"). 
-export ([add_timer/5, timer_cb/1, on_login/1]).


%% =============================================================================
get_data(Uid) -> 
	case mod_role_tab:lookup(Uid, t_role_timer) of
		[] -> #t_role_timer{uid = Uid};
		[Rec] -> Rec
	end.

set_data(Rec) -> 
	mod_role_tab:insert(Rec#t_role_timer.uid, Rec).
%% =============================================================================


%% 以{M, F}为Key来存定时器，Interval为间隔多少秒，到期时回调：M:F(DoTimes, Arg)
add_timer(Uid, Interval, M, F, Arg) ->
	Rec = get_data(Uid),
	case lists:keyfind({M, F}, 1, Rec#t_role_timer.timers) of
		false -> 
			role_loop:add_callback(Interval, ?MODULE, timer_cb, {M, F}),
			Now    = agent:agent_now(),
			Timers = lists:keystore({M, F}, 1, Rec#t_role_timer.timers, {{M, F}, Now, Interval, Arg}),
			Rec2   = Rec#t_role_timer{timers = Timers},
			set_data(Rec2);
		_ -> %% 定时器已存在了，则忽略
			skip
	end.


%% 定时器回调
timer_cb(Key = {M, F}) -> 
	Rec = get_data(get(uid)),
	{value, {_, BeginTime, Interval, Arg}, LeftTimers} = lists:keytake(Key, 1, Rec#t_role_timer.timers),
	set_data(Rec#t_role_timer{timers = LeftTimers}),
	%% 注意：回调时可能会再次调用add_timer来修改timers的，因此先调用set_data修改数据
	Now = agent:agent_now(),
	DoTimes = (Now - BeginTime) div Interval,
	M:F(DoTimes, Arg),
	ok.


on_login(Uid) ->
	Rec = get_data(Uid),
	Now = agent:agent_now(),
	[check_and_do_timer(Now, Tuple) || Tuple <- Rec#t_role_timer.timers],
	ok.


check_and_do_timer(Now, {Key, BeginTime, Interval, _Arg}) ->
	case Now >= BeginTime + Interval of
		true -> 
			timer_cb(Key);
		_ -> 
			role_loop:add_callback(BeginTime + Interval - Now, ?MODULE, timer_cb, Key)
	end.

