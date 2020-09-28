%% @doc 分时时间轮定时器，最小精度为一个tick，使用这个模块需要循环调用tick_loop/0
%% tick的时间长度由调用者确定，如每隔一秒调用则精度为一秒
%% 这里分为了两个功能：
%% 1.分时时间轮回调：
%%	 在指定的tick到期时，则执行回调代码
%%	 因为回调方法是在本定时器所在进程调用的，因此一个tick时间内，从开始回调第一个方法
%%	 到回调最后一个方法所消耗的时间不能大于一个tick时间长度
%%	 所以对于耗时比较长的回调方法应该给self()发送一个消息再去执行（role_timer模块就是干这个的）
%% 2.定时send：
%% 	 当有要使用erlang:send_after/3、erlang:start_timer/3时，都尽量转化为使用这个
%% 	 模块的方法来实现，因为大量的定时器都导致erlang调度器的延迟甚至阻塞。
%% 	 消息将在时间到了后发送消息给指定的进程
-module (tick_timer).
-export ([init/0, tick_loop/0, add_callback/4, send_after/2, send_after/3]).
-include ("common.hrl").


init() ->
	erlang:put(tick_current_time, util_time:unixtime()),
	init_tick().


init_tick() ->
	set_tick(0).
get_tick() ->
	erlang:get({?MODULE, tick}).
set_tick(Tick) ->
	erlang:put({?MODULE, tick}, Tick).


%% tick_loop是每秒一次执行的，但是会存在与实际的时间有差别的
%% 可能tick是过了一秒，但是实际时间可能过了2秒了，这样导致tick回调方法会延迟很多才会被调用的
%% 可能一天时间延迟就会长达几分钟的，因此需要判断实际时间，来决定到底调用几次tick_loop
tick_loop() ->
	NewNow = util_time:unixtime(),
	OldNow = erlang:put(tick_current_time, NewNow),
	case NewNow - OldNow of
		1 -> tick_loop_help();
		2 -> 
			tick_loop_help(),
			tick_loop_help();
		3 -> %% 一般不可能超过3秒的，除非所在进程非常繁忙
			tick_loop_help(),
			tick_loop_help(),
			tick_loop_help();
		_ -> 
			tick_loop_help(),
			tick_loop_help(),
			tick_loop_help(),
			tick_loop_help()
	end.

tick_loop_help() ->
	Tick = get_tick() + 1,
	set_tick(Tick),
	case get_delay_msg_queue(Tick) of
		undefined -> ok;
		MsgQueue  -> 
			[erlang:send(Dest, Msg) || {Dest, Msg} <- lists:reverse(MsgQueue)],
			delete_delay_msg_queue(Tick)
	end,

	case get_callback_queue(Tick) of
		undefined -> ok;
		CallBackList  -> 
			[begin 
				try
					M:F(A) 
				catch
					E:R ->
						?EXCEPTION_LOG(E, R, F, A)
				end
			end || {M, F, A} <- lists:reverse(CallBackList)],
			delete_callback_queue(Tick)
	end,
	ok.


%% 在AfterTick之后的tick上安装回调方法，AfterTick到期时将回调M:F(A)
add_callback(AfterTick, M, F, A) when AfterTick == 0 -> 
	M:F(A);
add_callback(AfterTick, M, F, A) when AfterTick > 0 andalso is_integer(AfterTick) ->
	FutureTick = get_tick() + AfterTick,
	case get_callback_queue(FutureTick) of
		undefined -> set_callback_queue(FutureTick, [{M, F, A}]);
		Queue     -> set_callback_queue(FutureTick, [{M, F, A} | Queue])
	end;
add_callback(AfterTick, M, F, A) when AfterTick < 0 ->
	?ERROR("wrong arguments call tick_timer:add_callback, AfterTick:~p, M:~p, F:~p, A:~p", [AfterTick, M, F, A]).

get_callback_queue(Tick) ->
	erlang:get({callback_queue, Tick}).
set_callback_queue(Future, MsgQueue) ->
	erlang:put({callback_queue, Future}, MsgQueue).
delete_callback_queue(Tick) ->
	erlang:erase({callback_queue, Tick}).


-spec send_after(AfterTick::non_neg_integer(), Dest::dest(), Msg::tuple()) -> any().
%% @doc 发送延迟消息
%% AfterTick为延迟多少秒，Dest同erlang:send/2中的Dest，Msg为要发送的消息
send_after(AfterTick, Msg) -> 
	send_after(AfterTick, self(), Msg).
send_after(AfterTick, Dest, Msg) when AfterTick == 0 -> 
	erlang:send(Dest, Msg);
send_after(AfterTick, Dest, Msg) when AfterTick > 0 andalso is_integer(AfterTick) ->
	Future = get_tick() + AfterTick,
	case get_delay_msg_queue(Future) of
		undefined -> set_delay_msg_queue(Future, [{Dest, Msg}]);
		MsgQueue  -> set_delay_msg_queue(Future, [{Dest, Msg} | MsgQueue])  %% 注意这里加的顺序
	end.


get_delay_msg_queue(Tick) ->
	erlang:get({delay_queue, Tick}).
set_delay_msg_queue(Future, MsgQueue) ->
	erlang:put({delay_queue, Future}, MsgQueue).
delete_delay_msg_queue(Tick) ->
	erlang:erase({delay_queue, Tick}).