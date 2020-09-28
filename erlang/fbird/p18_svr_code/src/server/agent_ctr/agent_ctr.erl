-module(agent_ctr).
-behaviour(gen_server).

-export([start_link/0, stop/0, init/1, terminate/2, code_change/3, handle_cast/2, handle_info/2, handle_call/3 ]).
-export([start_role_process/6]).

-include("common.hrl").

-record(state, {id = 0}).

-define (AgentCtrSvrId, 1).

start_link() ->

    process_flag(trap_exit, true),
    gen_server:start_link(?MODULE, [?AgentCtrSvrId, 2000], []).

stop() ->
    gen_server:cast(?MODULE, stop).

start_role_process(Sid, Ip, Seq, Aid, Uid, PhoneType) ->
    agent_sup:add(Sid,Ip,Seq,Aid,Uid,PhoneType,?AgentCtrSvrId).


init([Id,_Maxagent]) ->	
    {ok, #state{id=Id}}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->    
    {ok, State}.

handle_call(_Request, _From, State) ->    
    {reply, ok, State}.

handle_info(Request, State) ->
	?log_trace("Request=~p,State=~p",[Request,State]),
    {noreply, State}.


handle_cast(stop, State) ->
    {stop, normal, State};

handle_cast(Request, State) ->
    ?WARNING("Request:~p not handled", [Request]),
    {noreply, State}.


