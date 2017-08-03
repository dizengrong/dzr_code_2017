%% @author dzr
%% @doc 使用port的例子
-module(use_port).
-include("common.hrl").
-export([start/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {port, executable, timers=[]}).


start() ->
	erlang:spawn(fun() -> start_java() end),
     % gen_server:start_link({local, ?MODULE}, ?MODULE, [], []),
	ok.

start_java() ->
	Executable = os:find_executable("java"),
    Args    = ["dzr"],
    Env = [{"HOME", "C:\\Users\\Administrator"}],
    Options = [{env, Env}, {args, Args}, {line, 10240}, exit_status],
    Port    = erlang:open_port({spawn_executable, Executable}, Options),
    loop(Port).

loop(Port) ->   
    receive
        {Port, {data, {eol, Line}}} -> 
            ?INFO(Line),
            erlang:port_command(Port, "123456\n"), 
            Info = erlang:port_info(Port),
            ?INFO("Info:~p", [Info]),
            % erlang:port_command(Port, (<<"123456">>)), 
    		loop(Port);
    	Msg ->
    		?INFO("unhandled msg:~p", [Msg])
    end. 

init([]) ->
    {ok, #state{}, 0}.

handle_info({Port, {data, {eol, Line}}}, State=#state{port=Port}) ->
    ?INFO(Line),
    erlang:port_command(Port, "123456"), 
    % erlang:port_command(Port, "ls"), 
    {noreply, State};

handle_info(timeout, #state{port=undefined} = State) ->
    Executable = os:find_executable("java"),
    Args    = [""],
    % Args    = ["-version"],
    Env = [{"HOME", "C:\\Users\\Administrator"}],
    Options = [stream, nouse_stdio, hide, {env, Env}, eof, {args, Args}, {line, 10240}, exit_status],
    Port    = erlang:open_port({spawn_executable, Executable}, Options),
    ?INFO("Port:~p", [Port]),
    {noreply, State#state{port = Port}}; 
handle_info(Msg, State) ->
    ?INFO("unhandled msg:~p", [Msg]),
    {noreply, State}.

handle_cast(Message, State) ->
    {stop, {unknown_cast, Message}, State}.

%% @doc Trap unknown calls
handle_call(Message, _From, State) ->
    {stop, {unknown_call, Message}, State}.

terminate(_Reason, #state{port=undefined}) ->
    ok;
terminate(_Reason, #state{port=Port}) ->
    catch erlang:port_close(Port),
    ok.        

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
