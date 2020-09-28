%% @doc gen_server的通用版，为了统一入口，和减少写gen_server的callback函数编写
%% 以模块回调的方式来调用代码，回调模块需要定义如下方法：
%% init()
%% handle_call(Request)
%% handle_msg(Msg)
%% terminate()
%% do_loop(Now)
%% 除了handle_call/1需要返回一个返回值外，其他回调方法的返回值都会忽略

-module (common_server).
-include ("common.hrl").
-behaviour(gen_server).

-export([start_link/2, start_link/3]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export([debug_call/2]).


start_link(CallBackModule, StartTimer) ->
	start_link(CallBackModule, StartTimer, tick_loop).
%% @doc CallBackModule:回调模块，StartTimer:是否启动定时器循环，定时器的时长(毫秒)
-spec start_link(CallBackModule::atom(), StartTimer::boolean(), Interval::integer()|tick_loop) -> {ok, pid()}. 
start_link(CallBackModule, StartTimer, Interval) ->
	{ok, Pid} = gen_server:start_link({local, CallBackModule}, ?MODULE, {CallBackModule, StartTimer, Interval}, []),
	{ok, Pid}.


debug_call(ServerName, Fun) ->
	gen_server:call(ServerName, {debug, Fun}).


%% @private
init({CallBackModule, StartTimer, Interval}) ->
    erlang:process_flag(trap_exit, true),
	put(id, CallBackModule),  %% for debug log
	case StartTimer of
		true -> 
			case Interval of
				tick_loop -> 
					erlang:put(tick_loop, true),
					erlang:put({CallBackModule, loop_interval}, 1000),
					erlang:start_timer(1000, self(), loop),
					srv_loop:init();
				_ -> 
					erlang:put({CallBackModule, loop_interval}, Interval),
					erlang:start_timer(Interval, self(), loop)
			end;
		_ -> false
	end,
	CallBackModule:init(),
	{ok, CallBackModule}.


%% 用于测试
handle_call({debug, Fun}, _From, State) ->   
    {reply, catch Fun(), State};
handle_call(Request, _From, CallBackModule) ->
	Reply = try
		CallBackModule:handle_call(Request)
	catch
		E:R ->
			?EXCEPTION_LOG(E, R, handle_call, Request),
			{error, exception_happened}
	end,
	{reply, Reply, CallBackModule}.


handle_cast(stop, State) ->
	{stop, normal, State}; 
handle_cast(Msg, CallBackModule) ->
	try
		CallBackModule:handle_msg(Msg)
	catch
		E:R ->
			?EXCEPTION_LOG(E, R, handle_cast, Msg),
			exception_happened
	end,
	{noreply, CallBackModule}.


handle_info({timeout, _TimerRef, loop}, CallBackModule) ->
	Interval = erlang:get({CallBackModule, loop_interval}),
	erlang:start_timer(Interval, self(), loop),
	try
		(get(tick_loop) == true) andalso srv_loop:tick_loop(),
		Now = util_time:unixtime(),
		CallBackModule:do_loop(Now)
	catch
		E:R ->
			?EXCEPTION_LOG(E, R, do_loop, []),
			exception_happened
	end,
	{noreply, CallBackModule};
handle_info(Msg, CallBackModule) ->
	try
		CallBackModule:handle_msg(Msg)
	catch
		E:R ->
			?EXCEPTION_LOG(E, R, handle_info, Msg),
			exception_happened
	end,
	{noreply, CallBackModule}.


%% @private
terminate(Reason, CallBackModule) ->
	try
		CallBackModule:terminate()
	catch
		E:R ->
			?EXCEPTION_LOG(E, R, terminate, []),
			exception_happened
	end,
	?ERROR("gen_server:~p terminate for reason:~p", [CallBackModule, Reason]),
	ok.


%% @private
code_change(_OldVsn, State, _Extra) ->
	{ok, State}.

