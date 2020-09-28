%% @doc 场景创建模块
%% 场景支持分线，只有SCENE_TYPE_CITY和SCENE_TYPE_OUTDOOR类型场景会分线，其他不分线
%% 玩家进入场景优先分配到前面的分线，直到人数满为止
%% 空闲的分线进程将会被回收，除了1号线
%% 玩家进入场景的请求统一发到这里进行处理
-module (mod_scene_manager).
-include ("common.hrl").
-export([sync_create_scene/4, scene_created/3, scene_role_change/4, enter_get_line/2,update_world_lev/1]).
-export([sync_scene_closed/3]).

-export([init/0, handle_call/1, handle_msg/1, terminate/0, do_loop/1]).


%% 同步创建场景
sync_create_scene(SceneId, Args, UsrInfoList, SceneData) ->
	gen_server:call(?MODULE, {sync_create_scene, SceneId, Args, UsrInfoList, SceneData}).


%% 同步场景关闭
sync_scene_closed(SceneId, Line, MapPid) -> 
	gen_server:call(?MODULE, {sync_scene_closed, SceneId, Line, MapPid}).


enter_get_line(Scene, SceneKey) -> 
	gen_server:call(?MODULE, {enter_get_line, Scene, SceneKey}).


scene_created(SceneId, Line, MapPid) -> 
	gen_server:cast(?MODULE, {scene_created, SceneId, Line, MapPid}).


%% 场景分线人数改变时的通知
scene_role_change(SceneId, Line, MapPid, Num) -> 
	gen_server:cast(?MODULE, {scene_role_change, SceneId, Line, MapPid, Num}).

update_world_lev(NewWorldLev) ->
	gen_server:cast(?MODULE, {world_lev_update, NewWorldLev}).

% is_scene_have_line(Scene) ->
% 	is_scene_have_line2(util_scene:scene_type(Scene)).

is_scene_have_line2(SceneType) ->
	SceneType == ?SCENE_SORT_CITY orelse 
	SceneType == ?SCENE_SORT_PEACE orelse 
	SceneType == ?SCENE_SORT_CAMP. 


init() -> 
	set_scene_list([]),
	case util_server:is_cross_node() of
		false -> auto_create_scene();
		_ -> skip
	end,
	% WorldLev=fun_agent_mng:get_world_lev(),
	put(world_lev,1),
	ok.

auto_create_scene() -> 
	[auto_create_scene(Scene) || Scene <- data_scene_config:get_all()],
	ok.

auto_create_scene(SceneId) ->
	case data_scene_config:get_scene(SceneId) of
		#st_scene_config{sort = ?SCENE_SORT_CITY} -> %% 预创建的场景一定是不需要额外参数的
			create_scene(SceneId, undefined, [], undefined);
		% #st_scene_config{sort = ?SCENE_SORT_GUILDDMGBOSS} ->
		% 	create_scene(SceneId, undefined, [], undefined);
		_ -> skip
	end.


handle_call({sync_create_scene, SceneId, Args, UsrInfoList, SceneData}) ->
	create_scene(SceneId, Args, UsrInfoList, SceneData);
	
handle_call({enter_get_line, SceneId, SceneKey}) -> 
	enter_get_line2(SceneId, SceneKey);

handle_call({sync_scene_closed, SceneId, Line, MapPid}) ->
	delete_scene_line(SceneId, Line, MapPid),
	ok;

handle_call(Request) ->
	?ERROR("~p recieve call:~p, but not handled!", [?MODULE, Request]),
	not_handled.


handle_msg({scene_created, SceneId, Line, MapPid}) -> 
	set_line_info(SceneId, Line, MapPid, {0, util_time:unixtime()});
handle_msg({scene_role_change, SceneId, Line, MapPid, Num}) -> 
	?DEBUG("scene ~p change role to ~p", [SceneId, Num]),
	case Num of
		0 -> %% 回收场景在这里做
			case util_scene:scene_type(SceneId) of
				?SCENE_SORT_MAIN -> 
					recycle_line(SceneId, Line, MapPid);
				?SCENE_SORT_COPY -> 
					recycle_line(SceneId, Line, MapPid);
				?SCENE_SORT_ACTIVITY_COPY -> 
					recycle_line(SceneId, Line, MapPid);
				?SCENE_SORT_HERO_EXPEDITION -> 
					recycle_line(SceneId, Line, MapPid);
				?SCENE_SORT_ARENA -> 
					recycle_line(SceneId, Line, MapPid);
				_ -> 
					set_line_info(SceneId, Line, MapPid, {Num, util_time:unixtime()})
			end;
		_ -> 
			set_line_info(SceneId, Line, MapPid, {Num, util_time:unixtime()})
	end;
handle_msg({send_open_svr_time, Time}) -> 
	put(open_svr_time,Time);

handle_msg({world_lev_update, WorldLev}) ->
	put(world_lev,WorldLev);

handle_msg(Msg) ->
	?ERROR("~p recieve msg:~p, but not handled!", [?MODULE, Msg]),
	ok.


terminate() -> 
	ok.


%% 返回: no_line | {ok, Line(空闲的分线), MapPid}
enter_get_line2(SceneId, SceneKey) -> 
	LinesSet = get_scene_lines(SceneId),
	SceneType = util_scene:scene_type(SceneId),
	enter_get_line2_help(SceneType, SceneId, SceneKey, ordsets:to_list(LinesSet)).

enter_get_line2_help(SceneType, SceneId, SceneKey, [{Line, MapPid} | Rest]) -> 
	MapName = get_scene_name(SceneType, SceneId, Line, SceneKey),
	case whereis(MapName) == MapPid of
		true -> 
			case erlang:get({line_info, SceneId, Line, MapPid}) of
				{Num, _LastUpdateTime} when Num < ?MAX_NUM_IN_SCENE -> 
					set_line_info(SceneId, Line, MapPid, {Num, util_time:unixtime()}),
					{ok, Line, MapPid};
				{Num, _} when Num >= ?MAX_NUM_IN_SCENE -> 
					enter_get_line2_help(SceneType, SceneId, SceneKey, Rest)
			end;
		_ -> 
			enter_get_line2_help(SceneType, SceneId, SceneKey, Rest)
	end;
enter_get_line2_help(_SceneType, _SceneId, _SceneKey, []) -> 
	no_line.

			
do_loop(Now) -> 
	[check_line(Now, SceneId) || SceneId <- get_scene_list()],
	ok.


check_line(Now, SceneId) ->
	LinesSet = get_scene_lines(SceneId),
	[check_line_help(Now, SceneId, Line, Pid) || {Line, Pid} <- ordsets:to_list(LinesSet)],
	ok.

check_line_help(Now, SceneId, Line, Pid) -> 
	%% 回收场景在这里做
	SceneType = util_scene:scene_type(SceneId),
	case SceneType of
		?SCENE_SORT_MAIN ->
			check_line_help2(Now, SceneId, Line, Pid);
		?SCENE_SORT_COPY ->
			check_line_help2(Now, SceneId, Line, Pid);
		?SCENE_SORT_ACTIVITY_COPY ->
			check_line_help2(Now, SceneId, Line, Pid);
		?SCENE_SORT_HERO_EXPEDITION ->
			check_line_help2(Now, SceneId, Line, Pid);
		_ when Line /= 1 -> 
			check_line_help2(Now, SceneId, Line, Pid);
		_ -> 
			skip
	end.

check_line_help2(Now, SceneId, Line, Pid) ->
	case get_line_info(SceneId, Line, Pid) of
		{0, 0} -> %% 还没初始化
			ignore;
		{0, LastUpdateTime} when LastUpdateTime + 60 < Now -> 
			%% 没有人的场景，分线超过1分钟无人进来，将其回收
			%% 通知场景进行回收关闭
			recycle_line(SceneId, Line, Pid);
		_ -> 
			ignore
	end.

recycle_line(SceneId, Line, Pid) ->
	Pid ! recycle_line,
	delete_scene_line(SceneId, Line, Pid).


delete_scene_line(SceneId, Line, Pid) ->
	?DEBUG("scene ~p line ~p recycled:~p", [SceneId, Line, Pid]),
	erase_line_info(SceneId, Line, Pid),
	LinesSet = get_scene_lines(SceneId),
	set_scene_lines(SceneId, ordsets:del_element({Line, Pid}, LinesSet)),
	ok.


%% 操作所有的场景列表
get_scene_list() ->
	erlang:get(scene_list).
set_scene_list(List) ->
	erlang:put(scene_list, List).
add_2_scene_list(SceneId) ->
	L = get_scene_list(),
	case lists:member(SceneId, L) of
		true  -> ignore;
		false -> set_scene_list([SceneId | L])
	end.


%% 获取分线列表，返回: [分线id]
get_scene_lines(SceneId) ->
	case erlang:get({scene_lines, SceneId}) of
		undefined -> ordsets:new();
		LinesSet -> LinesSet
	end.
set_scene_lines(SceneId, LinesSet) ->
	erlang:put({scene_lines, SceneId}, LinesSet).


%% 获取分线信息，返回: {分线人数, 数据更新时刻}
get_line_info(SceneId, Line, MapPid) ->
	case erlang:get({line_info, SceneId, Line, MapPid}) of
		undefined -> {0, 0};
		Info -> Info
	end.
set_line_info(SceneId, Line, MapPid, Info) ->
	erlang:put({line_info, SceneId, Line, MapPid}, Info).
erase_line_info(SceneId, Line, MapPid) -> 
	erlang:erase({line_info, SceneId, Line, MapPid}).


%% 创建场景进程，Args为场景key
%% return: {ok, Pid, Line} | {error, Reason}
create_scene(SceneId, Args, UsrInfoList, SceneData) ->
	SceneType = util_scene:scene_type(SceneId),
	Line      = get_new_line(SceneType, SceneId),
	SceneName = get_scene_name(SceneType, SceneId, Line, Args),
	case create_scene_help(SceneName, SceneId, Line, Args, UsrInfoList, SceneData) of
		{ok, Pid} -> 
			add_2_scene_list(SceneId), 
			LinesSet = get_scene_lines(SceneId),
			set_scene_lines(SceneId, ordsets:add_element({Line, Pid}, LinesSet)),
			{ok, Pid, Line};
		Ret -> 
			Ret
	end.


get_new_line(SceneType, SceneId) ->
	case is_scene_have_line2(SceneType) of
		true -> 
			LinesSet = get_scene_lines(SceneId),
			get_new_line_help(ordsets:to_list(LinesSet), 1);
		false -> %% 其他类型不分线
			1
	end.


get_new_line_help(Lines, Line) ->
	case lists:keymember(Line, 1, Lines) of
		false -> Line;
		true  -> get_new_line_help(Lines, Line + 1)
	end.


get_scene_name(SceneType, SceneId, Line, Args) ->
	case SceneType of
		?SCENE_SORT_MAIN ->
			{main_scene, Uid, _Stage} = Args,
			util_misc:list_2_atom(lists:concat(["main_", SceneId, "_", Uid]));
		?SCENE_SORT_WORLDBOSS -> 
			util_misc:list_2_atom(lists:concat(["worldboss_", SceneId]));
		?SCENE_SORT_CITY -> 
			util_misc:list_2_atom(lists:concat(["city_", SceneId, "_", Line]));
		?SCENE_SORT_PEACE -> 
			util_misc:list_2_atom(lists:concat(["outdoor_", SceneId, "_", Line]));
		?SCENE_SORT_CAMP -> 
			util_misc:list_2_atom(lists:concat(["outdoor_", SceneId, "_", Line]));	
		?SCENE_SORT_COPY -> 
			case Args of
				{user_copy, Uid, _Scene} -> 
					util_misc:list_2_atom(lists:concat(["single_copy_", SceneId, "_", Uid]));
				{guild_ex_copy,GuildId,_Scene}->
					util_misc:list_2_atom(lists:concat(["guild_ex_copy_", SceneId, "_", GuildId]));
				{scene_key, Uid, _Stage}->
					util_misc:list_2_atom(lists:concat(["stage_", SceneId, "_", Uid]))
			end;
		?SCENE_SORT_ACTIVITY_COPY -> 
			{scene_key, Uid} = Args,
			util_misc:list_2_atom(lists:concat(["act_copy_", SceneId, "_", Uid]));
		?SCENE_SORT_HERO_EXPEDITION -> 
			{scene_key, Uid} = Args,
			util_misc:list_2_atom(lists:concat(["expedition", SceneId, "_", Uid]));
		?SCENE_SORT_ARENA -> 
			{scene_key, Uid} = Args,
			util_misc:list_2_atom(lists:concat(["usr_pk_", SceneId, "_", Uid]))
	end.


create_scene_help(SceneName, SceneId, Line, Args, UsrInfoList, SceneData) -> 
	% DropItemList     = gm_act_drop_item:get_rewards_data(),
	% ActivityTime     = gm_act_drop_item:get_drop_item_activity_time(),
	% ActivityDropItem = {ActivityTime,DropItemList},
	OpenSvrTime      = get_open_svr_time(),
	WorldLev		 = get_world_lev(),	
	SceneArgs        = [SceneName, {Args,UsrInfoList,SceneId,Line,SceneData,[],OpenSvrTime,WorldLev}],
	case supervisor:start_child(scene_sup, {SceneName, 
            {scene, start_link, [SceneArgs]}, 
            temporary, 5000, worker, [scene]}) of
        {ok, Pid} ->
            {ok, Pid};
        {error, Reason} ->
        	?ERROR("Create scene ~p, scene name ~p failed for reason:~n~p", [SceneId, SceneName, Reason]),
            {error, Reason}
    end.



get_open_svr_time() ->
	case get(open_svr_time) of
		undefined -> util:get_relative_day(?AUTO_REFRESH_TIME);			
		OpenDay -> OpenDay
	end.

get_world_lev() ->
	case get(world_lev) of
		undefined -> 1;			
		WorldLev -> WorldLev
	end.	

