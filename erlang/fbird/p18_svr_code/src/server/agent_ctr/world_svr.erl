-module(world_svr).
-behaviour(gen_server).
-export([start_link/2, stop/1, init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export([debug_call/2]).
-include("common.hrl").
-record(state, {key,lastontime=0}).

start_link(Key,Moudle) ->
%% 	?debug("Info:start world server,key=~p,moudle=~p", [Key,Moudle]),
	%process_flag(trap_exit, true),
	{ok, Pid} = gen_server:start_link({local, Key}, ?MODULE, [Key,Moudle], []),
%% 	?debug("key=~p,Pid=~p",[Key,Pid]),
	{ok, Pid}.

stop(Key) ->
	gen_server:cast(Key, stop).

%% 用于测试的，正常代码不要调用
debug_call(Key, Fun) ->
	gen_server:call(Key, {debug, Fun}).

init([Key,Moudle]) -> 
	put(id,Moudle),
	put(world_moudle,Moudle),
	put(world_key,Key),
	Ret = do_init(),
	
	erlang:start_timer(1000, self(), {timercast}),
	Ret.


handle_call({debug, Fun}, _From, State) ->   
    {reply, catch Fun(), State};

handle_call(Msg, _From, State) ->
%% 	?debug("handle_call:~p,~p",[Msg,State]),	
	Reply = try 
				Moudle = get_moudle(),
				Moudle:do_call(Msg)
			catch 
				E:R -> 
					?EXCEPTION_LOG(E,R,do_call,Msg),
					error
			end,	
	{reply, Reply, State}.  

handle_cast(stop, State) ->
	{stop, normal, State}; 
handle_cast(Msg, State) ->
	try 
		Moudle = get_moudle(),		
		Moudle:do_msg(Msg)
	catch 
		E:R -> 
			?EXCEPTION_LOG(E, R, do_msg, Msg)
	end,	
	{noreply, State}.
handle_info({timeout, _TimerRef, {timercast}}, State) ->
	Now = util:longunixtime(),
	try		
		Moudle = get_moudle(),
		Last = Moudle:do_time(Now),
		case erlang:is_integer(Last) of
			?TRUE ->
				erlang:start_timer(Last, self(), {timercast});
			_ -> ?SKIP
		end
	catch 
		E:R -> 
			?EXCEPTION_LOG(E, R, do_time, Now),
			erlang:start_timer(1000, self(), {timercast})
	end,
	{noreply, State};	
handle_info(Info, State) ->
	Moudle = get_moudle(),
	try 
		Moudle:do_info(Info)
	catch 
		E:R -> ?EXCEPTION_LOG(E, R, do_info, Info)
	end,	
	{noreply, State}.

terminate(_Reason, State) ->
	?log_error("Info:public server stoped!Reason=~p,State=~p", [_Reason, State]),
	try 
		Moudle = get_moudle(),
		Moudle:do_close()
	catch 
		E:R -> ?log_error("world terminate  error E=~p,R=~p",[E,R])
	end,	  
	ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.


get_key() -> get(world_key).
get_moudle() -> get(world_moudle).

do_init() ->
	Key = get_key(),
	Moudle = get_moudle(),
	Moudle:do_init(),
	{ok, #state{key=Key}}.