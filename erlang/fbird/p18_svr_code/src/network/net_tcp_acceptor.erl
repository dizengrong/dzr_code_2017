%% @doc 网络tcp监听后的等待accept客户端连接模块
-module(net_tcp_acceptor).
-behaviour(gen_server).

-export([start_link/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-include("common.hrl").

-record(state, {listen_socket, ref, line}).


start_link(LSock) ->
    gen_server:start_link(?MODULE, {LSock}, []).


init({LSock}) ->
    erlang:process_flag(trap_exit, true),
    {ok, #state{listen_socket=LSock}}.

handle_call(_Request, _From, State) ->
    {noreply, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

terminate(Reason, _State) ->
    ?INFO("acceptor process terminate, reason:~p", [Reason]),
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.


handle_info({event, start}, State) ->
    accept(State);

handle_info({inet_async, LSock, Ref, {ok, Sock}}, State = #state{listen_socket=LSock, ref=Ref}) ->
    %% patch up the socket so it looks like one we got from
    %% gen_tcp:accept/1
    {ok, Mod} = inet_db:lookup_socket(LSock),
    inet_db:register_socket(Sock, Mod),
    try        
        %% report
        {ok, {Address, Port}} = inet:sockname(LSock),
        {ok, {PeerAddress, PeerPort}} = inet:peername(Sock),
        ?DEBUG("accepted TCP connection on ~s:~p from ~s:~p~n",
                    [inet_parse:ntoa(Address), Port,
                     inet_parse:ntoa(PeerAddress), PeerPort]),
        spawn_socket_controller(Sock)
    catch Error:Reason ->
        gen_tcp:close(Sock),
        ?ERROR("unable to accept TCP connection: ~p ~p~n", [Error, Reason])
    end,
    accept(State);

handle_info({inet_async, LSock, Ref, {error, closed}}, State=#state{listen_socket=LSock, ref=Ref}) ->
    %% It would be wrong to attempt to restart the acceptor when we
    %% know this will fail.
    {stop, normal, State};

handle_info({'EXIT', _, shutdown}, State) ->    
    {stop, normal, State};

handle_info(Info, State) ->
    ?ERROR("recieve unknown message:~p", [Info]),
    {noreply, State}.


accept(State = #state{listen_socket=LSock}) ->
    case prim_inet:async_accept(LSock, -1) of
        {ok, Ref} -> 
            {noreply, State#state{ref=Ref}};
        Error -> 
            {stop, {cannot_accept, Error}, State}
    end.

spawn_socket_controller(ClientSock) ->
    case supervisor:start_child(net_tcp_client_sup, [ClientSock]) of
        {ok, CPid} ->
            inet:setopts(ClientSock, ?ACCEPTED_SOCKET_OPTS),
            % ?DEBUG("socket sndbuf opt:~w", [inet:getopts(ClientSock, [sndbuf])]),
            up_socket_watermark(ClientSock),
            gen_tcp:controlling_process(ClientSock, CPid),
            CPid ! start;
        {error, Error} ->
            ?CRITICAL("cannt accept client:~w", [Error]),
            catch erlang:port_close(ClientSock)
    end.


up_socket_watermark(Socket) -> 
    {ok, [{high_watermark, High}]} = inet:getopts(Socket, [high_watermark]),
    % ?DEBUG("Default TCP high_watermark:~p, set to:~p", [High, High*4]),
    {ok, [{low_watermark, Low}]}   = inet:getopts(Socket, [low_watermark]),
    % ?DEBUG("Default TCP low_watermark:~p, set to:~p", [Low, Low*4]),
    inet:setopts(Socket, [{high_watermark, High*4}, {low_watermark, Low*4}]).


    