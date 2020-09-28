-module(scene_ctr).
-behaviour(gen_server).
-export([start_link/0, stop/0, init/1, terminate/2, code_change/3, handle_cast/2, handle_info/2, handle_call/3 ]).
-include("common.hrl").

-record(state, {id = 0}).
start_link() ->
	
    process_flag(trap_exit, true),
    gen_server:start_link(?MODULE, [1,2000], []).
stop() ->
    gen_server:cast(?MODULE, stop).

init([Id,_Maxscene]) ->
    {ok, #state{id=Id}}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->    
    {ok, State}.

handle_call(_Request, _From, State) ->    
    {reply, ok, State}.

handle_info(_Request, State) ->
    {noreply, State}.


handle_cast({req_create_scene,{Key,UsrInfoList,{Scene,MaxWire},SceneData,ActivityDropItem,OpenSvrTime}},State) ->	
	scene_sup:add(Key,UsrInfoList,{Scene,MaxWire},SceneData,ActivityDropItem,OpenSvrTime), 
	{noreply, State};

handle_cast(stop, State) ->
    {stop, normal, State};

handle_cast(_Request, State) ->
	?log_error("unmatch _Request=~p",[_Request]),
    {noreply, State}.


