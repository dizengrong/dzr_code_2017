%% @doc 与server级别有关的工具方法
-module (util_server).
-include ("common.hrl").
-export ([get_node_name/1, get_node_name/2, get_log_filename/0, get_release_type/0]).
-export ([connect_log_node/1]).
-export ([make_deploy_dir/0, make_mnesia_dir/0, make_mnesia_backup_dir/0, make_server_dirs/0]).
-export ([is_app_started/1, is_game_server_running/0]).
-export ([make_mnesia_merge_src_dir/0, get_user_tab_current_max_id/0, set_user_tab_current_max_id/1]).
-export ([is_cross_node/0, kick_usr_all/1, get_server_open_days/0, get_server_open_rec/0]).
-export ([get_share_data/2, set_share_data/2, del_share_data/1]).
-export ([parse_server_id_by_node/1, is_game_server_node_format/1]).
-export ([broadcast_msg_to_online_usr_process/1]).


is_cross_node() ->
	server_config:get_conf(is_cross_node) == true.


get_release_type() -> 
	case ?DEBUG_MODE of
		true  -> "debug";
		false -> "release"
	end.


%% 确保服务端需要的目录都存在
make_server_dirs() -> 
	filelib:ensure_dir(make_mnesia_dir()),
	filelib:ensure_dir(make_mnesia_backup_dir()),
	filelib:ensure_dir(make_mnesia_merge_src_dir()),
	ok.

%% 生成部署目录
make_deploy_dir() ->
	Agent = server_config:get_conf(agent_name),
	GameName = server_config:get_conf(game_name),
	ServerId = server_config:get_conf(serverid),
	filename:join(["/data/", Agent, GameName, util_list:to_list(ServerId)]) ++ "/".

%% 生成mnesia数据库目录
make_mnesia_dir() ->
	ServerId  = server_config:get_conf(serverid),
	AgentName = server_config:get_conf(agent_name),
	GameName  = server_config:get_conf(game_name),
	lists:concat(["/data/mnesia_db/", GameName, "_", AgentName, "_", ServerId, "/"]).


%% 生成mnesia数据库备份目录
make_mnesia_backup_dir() ->
	case os:type() of
		{win32, _} -> 
			{ok, Pwd} = file:get_cwd(),
			filename:join([Pwd, "mnesia_backup"]) ++ "/";
		_ ->
			ServerId  = server_config:get_conf(serverid),
			AgentName = server_config:get_conf(agent_name),
			GameName  = server_config:get_conf(game_name),
			lists:concat(["/data/mnesia_backup/", GameName, "_", AgentName, "_", ServerId, "/"])
	end.


%% 合服数据库来源于哪个目录
make_mnesia_merge_src_dir() ->
	case os:type() of
		{win32, _} -> 
			{ok, Pwd} = file:get_cwd(),
			filename:join([Pwd, "mnesia_merge_src"]);
		_ ->
			AgentName = server_config:get_conf(agent_name),
			GameName  = server_config:get_conf(game_name),
			lists:concat(["/data/mnesia_merge_src/", GameName, "_", AgentName, "/"])
	end.


%% ============================= 其他数据相关处理 ==============================
%% 用来存放其他数据文件的目录
get_other_datas_dir() ->
	case os:type() of
		{win32, _} -> 
			"./";
		_ ->
			"/data/mnesia_db/other_datas/"
	end.


get_user_tab_current_max_id_file() -> 
	ServerId  = server_config:get_conf(serverid),
	AgentName = server_config:get_conf(agent_name),
	GameName  = server_config:get_conf(game_name),
	lists:concat([get_other_datas_dir(), GameName, "_", AgentName, "_", ServerId, "_user_tab_current_max_id.config"]).


get_user_tab_current_max_id() ->
	File = get_user_tab_current_max_id_file(),
	case filelib:is_file(File) of
		true -> 
			{ok, TupleDatas} = file:consult(File),
			case lists:keyfind(user_max_id, 1, TupleDatas) of
				false -> 0;
				{_, MaxId} -> MaxId
			end;
		_ -> 
			0
	end.


set_user_tab_current_max_id(MaxId) -> 
	File = get_user_tab_current_max_id_file(),
	{ok, Fd} = file:open(File, [write]),
	file:write(Fd, util_str:format_string("{user_max_id, ~p}.\n", [MaxId])),
	file:close(Fd),
	ok.
%% ============================= 其他数据相关处理 ==============================


get_node_name(NodeKey) ->
	ServerId = server_config:get_conf(serverid),
	get_node_name(NodeKey, ServerId).

get_node_name(NodeKey, ServerId) ->
	AgentName = server_config:get_conf(agent_name),
	GameName = server_config:get_conf(game_name),
	Host     = server_config:get_conf(server_host),
	NodeName = util_str:format_string("~s_~s_~p_~p@~s", [GameName, AgentName, NodeKey, ServerId, Host]),
	util:list_to_atom2(NodeName).


%% 根据节点名反解析出serverid
parse_server_id_by_node(NodeName) ->
	util:to_integer(string:nth_lexeme(atom_to_list(NodeName), 4, [$_, $@])).

%% 验证一个节点名是否为正式的游戏服节点名称
is_game_server_node_format(NodeName) -> 
	AgentName = server_config:get_conf(agent_name),
	GameName = server_config:get_conf(game_name),
	NodeKey = util:to_list(?PLAYER_NODE_KEY),
	case string:lexemes(util:to_list(NodeName), [$_]) of
		[GameName, AgentName, NodeKey | _] -> true;
		_ -> false
	end.

get_log_filename() ->
	LogPath = server_config:get_conf(log_path),
	AgentName = server_config:get_conf(agent_name),
	GameName = server_config:get_conf(game_name),
	ServerId = server_config:get_conf(serverid),
    {{Year, Month, Day}, _} = erlang:localtime(),
	Basename = util_str:format_string("log_~s_~s_~p_~w_~.2.0w_~.2.0w.log", 
									  [GameName, AgentName, ServerId, Year, Month, Day]),
	filename:join([LogPath, Basename]).


connect_log_node(LogNode) ->
	case net_adm:ping(LogNode) of
		pong -> 
			io:format("connect log node ~p succ~n", [LogNode]),
			init_logger(LogNode);
		pang ->
			timer:sleep(1000),
			io:format("connect log node ~p failed, reconnect...~n", [LogNode]),
			connect_log_node(LogNode)
	end.


init_logger(LogNode) ->
	LogLv = server_config:get_conf(log_level),
	srv_loglevel:set(LogLv),
	error_logger:add_report_handler(gen_handler, LogNode).


is_app_started(App) ->
	List = application:loaded_applications(),
	case lists:keyfind(App, 1, List) /= false of
		true -> 
			case App of
				?APP_SERVER -> whereis(relation_mng) /= undefined
			end;
		false -> false
	end.


%% return true | false | {error, Reason}
is_game_server_running() ->
	NodeName = get_node_name(debug),
	case net_kernel:start([NodeName]) of
		{ok, _Pid} -> 
			Cookie = server_config:get_conf(cookie),
			erlang:set_cookie(NodeName, Cookie),
			Ret = case net_adm:ping(get_node_name(?PLAYER_NODE_KEY)) of
				pong -> true;
				pang -> false
			end,
			net_kernel:stop(),
			Ret;
		_ ->
			{error, "start debug node failed"}
	end.


kick_usr_all(Reason) -> 
	[gen_server:cast(Sid, {discon, Reason}) || #ply{sid=Sid} <- db:dirty_match(ply, #ply{_ = '_'})],
	ok.


%% 获取开服天数
get_server_open_days() ->
	Key = db_api:dirty_first(opening_server_time),
	[#opening_server_time{time=CreateTime}] = db_api:dirty_read(opening_server_time, Key),
	util_time:diff_date_by_datetime(CreateTime, util_time:unixtime()) + 1.


get_server_open_rec() -> 
	Key = db_api:dirty_first(opening_server_time),
	[Rec] = db_api:dirty_read(opening_server_time, Key),
	Rec.

%% ========================== 操作全局共用数据的方法 ===========================
%% hero_expedition_cur_id 英雄远征本次活动的id
%% hero_expedition_events 英雄远征事件
get_share_data(Key, DefaultVal) -> 
	case db_api:dirty_read(t_key_val, Key) of
		[] -> DefaultVal;
		[#t_key_val{val = Val}] -> Val
	end.

set_share_data(Key, Val) -> 
	db_api:dirty_write(#t_key_val{key = Key, val = Val}).

del_share_data(Key) -> 
	db_api:dirty_delete(t_key_val, Key).

%% ========================== 操作全局共用数据的方法 ===========================
%% 发送消息给所有在线的玩家的agent进程
broadcast_msg_to_online_usr_process(Msg) -> 
	Fun = fun(Uid) -> 
		case db_api:dirty_read(ply, Uid) of
			[#ply{agent_hid = AgentPid}] ->
				gen_server:cast(AgentPid, Msg);
			_ -> 
				skip
		end
	end,
	[Fun(Uid) || Uid <- db_api:dirty_all_keys(ply)],
	ok.
