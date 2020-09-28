-module(agent).
-behaviour(gen_server).

-export([start_link/1, stop/0, init/1, terminate/2, code_change/3, handle_cast/2, handle_info/2, handle_call/3]).
-export([agent_now/0, call_check_and_do_costs/2, do_save_dirty_datas/1]).
-export([debug_call/2]).

-include("common.hrl").

-record(state, {aid = 0, uid = 0, sid = 0,loadstate=0,ip=0,mapHid=0}).
-define(AGENT_TIMER,1000).

start_link(Data) ->
    gen_server:start_link(?MODULE, Data, []).

stop() ->
    gen_server:cast(?MODULE, stop).

%% 用于测试的，正常代码不要调用
debug_call(Uid, Fun) ->
	[Rec] = db:dirty_get(ply, Uid),
	gen_server:call(Rec#ply.agent_hid, {debug, Fun}).


%% 同步call扣除玩家的物品
call_check_and_do_costs(AgentPid, Costs) ->
	gen_server:call(AgentPid, {call_check_and_do_costs, Costs}, 1000).


init({Sid,Ip,Seq,Aid,Uid,PhoneType,AgentIdx}) ->
    erlang:process_flag(trap_exit, true), 
    erlang:monitor(process, Sid),
	?log_trace("agent init aid = ~p,Uid=~p Ip = ~w",[Aid,Uid,Ip]),
	put(sid,Sid),
    put(id, Uid),
    put(uid, Uid),
    put(aid, Aid),
	put(ip, Ip),
	put(agentIdx, AgentIdx),
	put(agent_now, util_time:unixtime()),
	put(phone_type, PhoneType),
	role_loop:init(),
    erlang:send_after(?AGENT_TIMER, self(), role_loop),
	fun_agent:on_init(),
	gen_server:cast(self(), {login,Seq}),	
	% role_loop:add_callback(5*60, ?MODULE, do_save_dirty_datas, Uid),
    {ok, #state{aid = Aid, uid = Uid ,sid = Sid,ip=Ip}}.

terminate(_Reason, #state{uid = Uid, ip = Ip}) ->
	do_terminate(Uid, Ip),
    ok.

code_change(_OldVsn, State, _Extra) ->    
    {ok, State}.


handle_call({call_check_and_do_costs, Costs}, _From, State) -> 
	SuccFun = fun() -> true end,
	FailFun = fun() -> false end,
	Reply = fun_item_api:check_and_add_items(get(uid), get(sid), Costs, [], SuccFun, FailFun),
    {reply, Reply, State};

handle_call({debug, Fun}, _From, State) ->   
    {reply, catch Fun(), State};

handle_call(_Request, _From, State) ->    
    {reply, ok, State}.

handle_info(role_loop, RoleId) -> 
    erlang:send_after(?AGENT_TIMER, self(), role_loop),
	Now = util_time:unixtime(),
	put(agent_now, Now),
	try
		% fun_agent:do_second_loop(Now), 现在这个do_time方法里没有东西了，所以先注释掉，如果真的需要再开启
		role_loop:tick_loop(RoleId)
	catch
		E:R ->
			?EXCEPTION_LOG(E, R, handle_info, role_loop),
			exception_happened
	end,
	{noreply, RoleId};
handle_info({'EXIT', _, Reason}, State) ->
    ?ERROR("role proc exit: ~n~p", [Reason]),
    {stop, normal, State};
handle_info({'DOWN', _, _, _PID, _}, State) -> 
    {stop, normal, State};

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

handle_info(on_login, State) -> 
	fun_agent:on_login(get(sid)),
    {noreply, State};

handle_info(stop, State) ->
    {stop, normal, State};

handle_info(_Request, State) ->
	?ERROR("unhandled msg:~p", [_Request]),
    {noreply, State}.

handle_cast({login,Seq}, #state{aid = _Aid, uid = Uid , sid = Sid ,ip =Ip} = State) ->
	case db:dirty_get(usr, Uid) of
		[Usr = #usr{}] ->
			%% 先加载个人数据到ets缓存
			case mod_role_tab:init(Uid) of
				init_fail -> 
					?ERROR("init role ets tab failed when login"),
					{stop, normal, State};
				_ -> 
					case Usr#usr.is_first_register of
						true -> init_create_usr_datas(Uid, Sid);
						_    -> skip
					end,
					NowTime=util:unixtime(),
					NewUsr = Usr#usr{is_first_register=false,last_login_time=NowTime},
					db:dirty_put(NewUsr),
					%% 这样要同步call才行，等待在线记录#ply{}创建后才能继续
					gen_server:call(agent_mng, {agent_in,Usr#usr{hp=100,mp=100},Sid,Ip,self(),get(phone_type),get(agentIdx)}),
					self() ! on_login,
					
					send_usr_info_to_client(Uid, Sid, Seq, Usr),
					
					put_login_day(Uid),
					report_usr_login(Usr, Ip),
					{noreply, State#state{loadstate = 1}}
			end;
		R ->
			?ERROR("Login no usr:~p",[R]),
			?discon(Sid,login_check_error,0),
			{stop, normal, State}
	end;

handle_cast(stop, State) ->
    {stop, normal, State};

handle_cast(Msg, State) ->
	try 
		fun_agent:do_msg(Msg)
	catch 
		E:R -> ?EXCEPTION_LOG(E, R, do_msg, Msg)
	end,		   
	{noreply, State}.



report_usr_login(Usr, Ip) -> 
	Uid = Usr#usr.id,
	fun_dataCount_update:report_usr_login(
		Uid,
		Usr#usr.name,
		Ip,
		Usr#usr.lev,
		Usr#usr.prof,
		0,
		% fun_guild:get_role_guild_id(Uid), 
		Usr#usr.vip_lev,
		Usr#usr.fighting,
		Usr#usr.camp,
		mod_role_tab:get_resoure(Uid, ?RESOUCE_COPPER_NUM),
		mod_role_tab:get_resoure(Uid, ?RESOUCE_COIN_NUM),
		mod_role_tab:get_resoure(Uid, ?RESOUCE_BINDING_COIN_NUM)
	).

report_usr_logout(Uid, Ip) ->
	[Usr] = db:dirty_get(usr, Uid),
	fun_dataCount_update:report_usr_logout(
		Uid,
		Usr#usr.name,
		Ip,
		Usr#usr.lev,
		Usr#usr.prof,
		fun_guild:get_role_guild_id(Uid), 
		Usr#usr.vip_lev,
		Usr#usr.fighting,
		Usr#usr.camp,
		mod_role_tab:get_resoure(Uid, ?RESOUCE_COPPER_NUM),
		mod_role_tab:get_resoure(Uid, ?RESOUCE_COIN_NUM),
		mod_role_tab:get_resoure(Uid, ?RESOUCE_BINDING_COIN_NUM)
	).

send_usr_info_to_client(Uid, Sid, Seq, Usr) ->
	ResourceList = mod_role_tab:login_get_init_resources(Uid),
	Fun1 = fun(Type,Val) ->
		#pt_public_resource_list{resource_type = Type,resource_num = Val}
	end,
	SceneLev = mod_scene_lev:get_curr_scene_lv(Usr#usr.id),
	NewResourceList = [Fun1(Type,Val) || {Type,Val} <- ResourceList, Val /= 0],
	Pt = #pt_usr_info{
		id            = Usr#usr.id,
		name          = util:to_list(Usr#usr.name),
		level         = Usr#usr.lev,
		exp           = Usr#usr.exp,
		camp          = Usr#usr.camp,
		guide_id      = fun_guild:get_role_guild_id(Uid),
		guild_name    = "",
		resource_list = NewResourceList,
		paragon_level = Usr#usr.paragon_level,
		vip_lev       = Usr#usr.vip_lev,
		create_time   = Usr#usr.create_time,
		scene_lev     = SceneLev
	},
	?send(Sid,proto:pack(Pt, Seq)).

do_save_dirty_datas(Uid) -> 
	do_save_dirty_datas(Uid, false). 
do_save_dirty_datas(Uid, Offline) -> 
	% role_loop:add_callback(5*60, ?MODULE, do_save_dirty_datas, Uid),
	mod_role_tab:save(Uid, Offline),
	true = is_list(ets:info(mod_role_tab:table_name(Uid))),
	ok.

do_terminate(Uid, Ip) ->
	try
		do_terminate2(Uid, Ip)
	catch
		E:T ->
			?EXCEPTION_LOG(T, E, do_terminate, Uid)
	end.

do_terminate2(Uid, Ip) -> 
	case get(already_terminate) of
		undefined -> 
			put(already_terminate, true),
			gen_server:cast(agent_mng, {agent_out,Uid}),
			?TRY_CATCH(fun() -> fun_agent:on_logout(Uid) end, Error, Reason), 
			util_misc:safe_exe_fun(fun() -> report_usr_logout(Uid, Ip) end),
			?INFO("agent terminate, do save data to db"),
			do_save_dirty_datas(Uid, true),
			ok;
		_ -> 
			skip
	end.


put_login_day(_Uid)-> skip.
	% {LoginDays, RecentLoginDate} = fun_usr_misc:get_misc_data(Uid, login_day),
	% Today = util_time:get_today_date(),
	% case Today > RecentLoginDate of
	% 	true -> 
	% 		fun_usr_misc:set_misc_data(Uid, login_day, {LoginDays + 1, Today});
	% 	_ -> skip
	% end.


agent_now() -> 
	get(agent_now).


%% 在on_login调用之前执行，可以在这里用来创建角色后初始化模块数据
%% 注意：这里初始化时候时，玩家的缓存表已创建好了，缓存的表应该使用缓存接口来操作
init_create_usr_datas(Uid, Sid) ->
	mod_time_reward:init_data(Uid),
	fun_offline_reward:init_data(Uid),
	Default = data_para:get_data(28),
	case data_entourage:get_data(Default) of
		#st_entourage_config{} ->
			Args = #api_item_args{
				way = ?ITEM_WAY_CREATE_USR,
				add = [{Default, 1}]
			},
			fun_item_api:add_items(Uid, Sid, 0, Args);
		_ -> skip
	end,
	fun_main_task:init_data(Uid),
	% fun_learn_skill:init_data(Uid),
	ok.