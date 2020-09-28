%% @doc 网络tcp监听模块
-module(net_tcp_listener).
-behaviour(gen_server).
-include("common.hrl").
-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {sock, on_startup, on_shutdown}).

%%--------------------------------------------------------------------

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, {}, []).

%%--------------------------------------------------------------------

init({}) ->
    process_flag(trap_exit, true),
    Port = server_config:get_conf(net_port),
    case gen_tcp:listen(Port, ?LISTEN_TCP_OPTS) of
    {ok, LSock} ->
        self() ! start_accetpor,
        {ok, #state{sock = LSock}};
    {error, Reason} ->
        ?ERROR("failed to start ~s on port:~w - ~w~n", [?MODULE, Port, Reason]),
        {stop, {cannot_listen, Port, Reason}}
    end.


handle_call(_Request, _From, State) ->
    {noreply, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(start_accetpor, State) ->
    net_tcp_sup:start_acceptor(State#state.sock),
    {noreply, State};

handle_info({'EXIT', _, Reason}, State) ->
    ?ERROR("listener stop ~w ", [Reason]),
    {stop, normal, State};

handle_info(_Info, State) ->
    {noreply, State}.

terminate(Reason, #state{sock=LSock}) ->
    {ok, {IPAddress, Port}} = inet:sockname(LSock),
    gen_tcp:close(LSock),
    ?INFO("stopped ~s on ~s:~w, reason:~w", [?MODULE, inet_parse:ntoa(IPAddress), Port, Reason]),
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
