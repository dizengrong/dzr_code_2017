-module(scene).
-behaviour(gen_server).

-export([start_link/1, stop/0, init/1, terminate/2, code_change/3, 
		 handle_cast/2, handle_info/2, handle_call/3]).
-export([get_scene_long_now/0, get_scene_now/0, is_single_copy/0]).
-export([debug_call/2]).

-include("common.hrl").

-record(state, {id = 0,type=0,start_time=0,scene_model=0,script_items=[]}).
-define(SCENE_LOOP_MS,200).
-define(SCENE_LOOP_SECONDS,1000).


start_link(Data) ->
    gen_server:start_link(?MODULE, Data, []).

stop() ->
    gen_server:cast(?MODULE, stop).

%% 用于测试的，正常代码不要调用
debug_call(Uid, Fun) when is_integer(Uid) ->
	[Rec] = db:dirty_get(ply, Uid),
	gen_server:call(Rec#ply.scene_hid, {debug, Fun});
debug_call(PidStr, Fun) when is_list(PidStr) ->
	gen_server:call(list_to_pid(PidStr), {debug, Fun});
debug_call(Pid, Fun) when is_pid(Pid) ->
	gen_server:call(Pid, {debug, Fun}).

%% init({Key,UsrInfoList,NeedUsrInfo,Scene,SceneData}) ->
%% UsrInfoList => [{Uid,Seq,Pos,_} | Next]
init([MapName, {Key,UsrInfoList,Scene,Line,SceneData,ActivityDropItem,OpenSvrTime,WorldLev}]) ->
    erlang:process_flag(trap_exit, true), 
    erlang:register(MapName, self()),
	LongNow = util:longunixtime(),
	set_scene_long_now(LongNow),
	scene_big_loop:init(),
	put(id,Scene),
	put(map_name,MapName),
	put(key,Key),
	put(scene,Scene),
	put(line,Line),
	put(wire_size,1),
	put(scene_usr_info,UsrInfoList),
	put(scene_info,SceneData),
	put(activity_drop_item,ActivityDropItem),
	put(open_svr_time,OpenSvrTime),
	put(world_lev,WorldLev),
	put(on_time,[]),%%飞位面的时候load还没执行,人就已经进场景了
	check_and_set_single_copy(Scene),
	#st_scene_config{script_scene=Script} = data_scene_config:get_scene(get(scene)),
	Script2 = util:to_atom("scene_config_" ++ util:to_list(Script)),
	?_IF(Script2 /= no andalso code:is_loaded(Script2) /= false, put(scene_script, Script2), skip),

	self() ! load,
	
	fun_scene:on_init(), 

	State = #state{type =Scene,start_time=LongNow},
	SceneModule = case data_scene_config:get_scene(Scene) of
		#st_scene_config{sort = ?SCENE_SORT_HERO_EXPEDITION} -> fun_scene_hero_expedition;
		#st_scene_config{sort = ?SCENE_SORT_ACTIVITY_COPY} ->	fun_scene_activity_copy;
		#st_scene_config{sort = ?SCENE_SORT_MAIN} ->         	fun_scene_main;
		#st_scene_config{sort = ?SCENE_SORT_ARENA} ->        	fun_scene_arena;
		#st_scene_config{sort = ?SCENE_SORT_CITY} ->         	fun_scene_city;
		#st_scene_config{sort = ?SCENE_SORT_COPY} ->         	fun_scene_copy;
		#st_scene_config{sort = ?SCENE_SORT_PEACE} ->        	fun_scene_outdoor;
		#st_scene_config{sort = ?SCENE_SORT_CAMP} ->         	fun_scene_outdoor;
		#st_scene_config{sort = ?SCENE_SORT_WORLDBOSS} ->    	fun_scene_worldboss;
		#st_scene_config{sort = ?SCENE_SORT_MELLEBOSS} ->    	fun_scene_melleboss
	end,
	mod_scene_manager:scene_created(get(scene), get(line), self()),
	{ok, State#state{scene_model = SceneModule}}.


terminate(_Reason, _) -> 
	ok.

code_change(_OldVsn, State, _Extra) ->    
    {ok, State}.

handle_call({debug, Fun}, _From, State) ->   
    {reply, catch Fun(), State};

handle_call(_Request, _From, State) ->    
    {reply, ok, State}.

handle_info(loop_ms,  #state{type =Scene,script_items=_Script_items} = State) -> 	
	Now = util:longunixtime(),
	set_scene_long_now(Now),
	try
		fun_scene:do_time(Scene,Now)
	catch
		ES:RS -> ?EXCEPTION_LOG(ES, RS, do_time, [Scene,Now])
	end,
	
	T1 = util:longunixtime(),
	T1 - Now > 100 andalso ?WARNING("scene:~p over time:~w",[Scene, T1-Now]),

	erlang:send_after(?SCENE_LOOP_MS, self(), loop_ms),
    {noreply, State};

handle_info(loop, State = #state{type = Scene}) -> 
	erlang:send_after(?SCENE_LOOP_SECONDS, self(), loop),
	try
		scene_big_loop:tick_loop()
	catch
		IES:IRS -> 
			?EXCEPTION_LOG(IES, IRS, loop, Scene)
	end,
	{noreply, State};

handle_info({timeout, _TimerRef, CallBackInfo}, State) ->
	case CallBackInfo of
		{Module, Function} ->
			try
				Module:Function()
			catch 
				E:R -> ?EXCEPTION_LOG(E, R, Function, [])
			end;
		{Module, Function, Args} -> 
			try
				Module:Function(Args)
			catch 
				E:R -> ?EXCEPTION_LOG(E, R, Function, Args)
			end;
		_ ->
			?WARNING("unknown timer callback,CallbackInfo=~p", [CallBackInfo])
	end,
	{noreply, State};

handle_info(kick_all_usr, State) -> 
	fun_scene:kick_all_usr(),
	{noreply, State};

handle_info(close_scene, State) -> 
	try
		mod_scene_manager:sync_scene_closed(get(scene), get(line), self())
	catch
		E:R ->
			?EXCEPTION_LOG(E, R, handle_info, close_scene)
	end,
	{stop, normal, State};

handle_info(recycle_line, State) -> 
	?DEBUG("scene ~p line ~p pid ~p recycled", [get(scene), get(line), self()]),
	{stop, normal, State};

handle_info(load, #state{type =Scene,scene_model = SceneModel} = State) -> 
	set_scene_long_now(util:longunixtime()),
	erlang:send_after(?SCENE_LOOP_MS, self(), loop_ms),
	erlang:send_after(?SCENE_LOOP_SECONDS, self(), loop),
 	fun_scene:on_scene_loaded(SceneModel,Scene),
	{noreply, State};

handle_info(Request, State) ->
	?ERROR("Request:~p not handled", [Request]),
    {noreply, State}.

				
handle_cast({usr_enter_scene, Uid,Sid,Seq,LoginDataSet,EnterSceneData}, State) ->
	?debug("usr_enter_scene"),
	try	
		fun_scene:on_usr_login(Uid,Sid,LoginDataSet,EnterSceneData,Seq),
		Num = length(fun_scene_obj:get_all_ids(?SPIRIT_SORT_USR)),
		mod_scene_manager:scene_role_change(get(scene), get(line), self(), Num)
	catch
		E:R -> 
			?EXCEPTION_LOG(E, R, usr_enter_scene, Uid)
	end,
    {noreply, State};

handle_cast({agent_out, ActionSort, Uid}, State) ->    
    % ?INFO("agent_out, uid = ~p", [Uid]),
	try
		fun_scene:on_usr_logout(Uid,ActionSort),
		Num = length(fun_scene_obj:get_all_ids(?SPIRIT_SORT_USR)),
		mod_scene_manager:scene_role_change(get(scene), get(line), self(), Num)
	catch
		E:R -> 
			?EXCEPTION_LOG(E, R, agent_out, Uid)
	end,
    {noreply, State};


handle_cast(stop, #state{type =Scene} = State) ->
	try 
		fun_scene:on_close(Scene)
	catch 
		E:R -> 
			?EXCEPTION_LOG(E, R, on_close, Scene)
	end,
    {stop, normal, State};

handle_cast(Msg, State) ->
	try 
		fun_scene:do_msg(Msg)
	catch 
		E:R -> 
			?EXCEPTION_LOG(E, R, do_msg, Msg)
	end,		   
	{noreply, State}.


set_scene_long_now(Now) ->
	put(long_now, Now).

get_scene_long_now() ->
	get(long_now).


get_scene_now() ->
	get(long_now) div 1000.

check_and_set_single_copy(Scene) ->
	IsSingle = case util_scene:scene_type(Scene) of
		?SCENE_SORT_MAIN -> false;
		?SCENE_SORT_ARENA -> true;
		?SCENE_SORT_ACTIVITY_COPY -> true;
		?SCENE_SORT_HERO_EXPEDITION -> true;
		_ -> false
	end,
	put(single_copy, IsSingle).


%% 场景内判断是否为单人副本
is_single_copy() -> 
	get(single_copy) == true.