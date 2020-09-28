%% @doc 这个是服务器启动和停止的总入口

-module (main).
-include ("common.hrl").
-export ([start/0, stop/0, info/0, backup_db/0, migration_db/1, restore_db/1, merge_db/1]).
-export ([stop_player_node/0, stop_cross_node/0, reload/1]).
-export ([check_game_node_status/0]).
-export ([print_remshell_cmd/0]).



%% @doc 启动玩家节点
start() -> 
	%% 节点注册到epmd使用的端口，设置一个范围，运维需要设置防火墙的
	application:set_env(kernel, inet_dist_listen_min, 60000),
	application:set_env(kernel, inet_dist_listen_max, 60200),
	application:set_env(kernel, dist_auto_connect, never),
	?LIB_MAP_MODULE == lib_c_map_module andalso (ok = cerl_map_api:init()),
	case catch server_config:init() of
		{'EXIT', Reason} ->
			Reason2 = util_str:format_string("init config error:~p~n", [Reason]),
			erlang:halt(Reason2);
		_ -> 
			case server_checker:check_before_start() of
				{error, Reason} -> 
					erlang:halt(util_str:format_string("start node failed:~s~n", [Reason]));
				_ ->
					log:start(),
					util_server:make_server_dirs(),
					start_help(util_server:is_cross_node())
			end
	end,
	ok.


start_help(false) ->
	Apps = [inets, ?APP_SERVER, ?APP_SCENE],
	work_helper_main:start(),
	[ok = application:start(App) || App <- Apps],
	?INFO("This game server opened ~p days", [util_server:get_server_open_days()]),
	case ?DEBUG_MODE of
    	true -> 
			?INFO("game serve started in debug mode, notice this should not in product mode");
		false -> 
			?INFO("game server started in release mode")
	end;
start_help(true) -> 
	ssl:start(),
	Apps = [inets, ?APP_CROSS],
	[ok = application:start(App) || App <- Apps],
	case ?DEBUG_MODE of
    	true -> 
			?WARNING("cross serve started in debug mode, notice this should not in product mode");
		false -> 
			?INFO("cross server started in release mode")
	end.


%% 数据库备份，无论游戏服是否开启都可以备份
backup_db() ->
	log:start(),
	mt_backup:start(),
	init:stop(),
	ok.


%% 数据库迁移
migration_db([From, To, Source0, Target0]) ->
	Source = atom_to_list(Source0), 
	Target = atom_to_list(Target0), 
	mnesia_migration:migration(From, To, Source, Target),
	io:format("migration from ~p to ~p success~n~n", [From, To]),
	init:stop().


%% 数据库恢复 BackupDBFile0:备份文件名的路径
restore_db([BackupDBFile0]) ->
	server_config:init(),
	log:start(),
	BackupDBFile = atom_to_list(BackupDBFile0), 
	mt_restore:start(BackupDBFile),
	init:stop().


%% 合服
merge_db([Cmd]) -> 
	io:format("usage:server_ctr.bat(.sh) ~s {server_id1} {server_id2} ~n", [Cmd]),
	erlang:halt();
merge_db([_Cmd | ServerIdList0]) -> 
	server_config:init(),
	ServerIdList = [list_to_integer(Id) || Id <- ServerIdList0],
	mt_merge:start(ServerIdList),
	init:stop().

%% 热更新
reload([_ | ModuleList]) ->
	NodeName = util_server:get_node_name(debug),
	case net_kernel:start([NodeName]) of
		{ok, _Pid} -> 
			Cookie = server_config:get_conf(cookie),
			erlang:set_cookie(NodeName, Cookie),
			reload_help(ModuleList);
		_ -> skip
	end,
	init:stop().


reload_help(ModuleList) -> 
	NodeKey = ?_IF(util_server:is_cross_node(), ?CROSS_NODE_KEY, ?PLAYER_NODE_KEY),
	NodeName = util_server:get_node_name(NodeKey),
	case net_adm:ping(NodeName) of
		pong -> 
			{mod_server_manage, NodeName} ! {reload_modules, ModuleList};
		_ -> 
			io:format("reload failed, not connected to node~p~n", [NodeName])
	end.


%% @doc 关闭玩家节点
stop_player_node() -> 
	util_server:kick_usr_all(game_shutdown),
	net_tcp_sup:stop_acceptors(),
	mod_rank_service:save_all(),
	work_helper_main:stop(),
	fun_http_client:stop(),
	% clear_msg_queue(),
	util:sleep(2000),
	application:stop(?APP_SERVER),
	application:stop(ssl),
	application:stop(inets),
	mnesia_manager:stop(),
	init:stop(),
	io:format("stop node ~s ... succ~n", [node()]),
	ok.	


% clear_msg_queue() ->
% 	receive
% 		Msg  ->
% 			?ERROR("clearn msg:~p", [Msg]),
% 			clear_msg_queue()
% 	after 0 ->
% 			ok
% 	end.


stop_cross_node() ->
	mnesia_manager:stop(),
	init:stop(),
	io:format("stop node ~s ... succ~n", [node()]),
	ok.


%% @doc 关闭系统
stop() ->
	code:which(server_config_gen) == non_existing andalso server_config:init(),
	NodeName = util_server:get_node_name(debug),
	case net_kernel:start([NodeName]) of
		{ok, _Pid} -> 
			Cookie = server_config:get_conf(cookie),
			erlang:set_cookie(NodeName, Cookie),
			case util_server:is_cross_node() of
				false -> stop_help(?PLAYER_NODE_KEY);
				true  -> stop_help(?CROSS_NODE_KEY)
			end;
		_ ->
			io:format("start stop node failed!~n")
	end,
	init:stop().


stop_help(NodeKey) ->
	NodeName = util_server:get_node_name(NodeKey),
	case net_adm:ping(NodeName) of
		pong ->
			stop_node(NodeKey);
		pang -> 
			io:format("stop node ~p failed, it's not running~n", [NodeName])
	end.


stop_node(NodeKey) when NodeKey == ?PLAYER_NODE_KEY ->
	Node = util_server:get_node_name(NodeKey),
	rpc:call(Node, ?MODULE, stop_player_node, []);
stop_node(NodeKey) when NodeKey == ?CROSS_NODE_KEY ->
	Node = util_server:get_node_name(NodeKey),
	rpc:call(Node, ?MODULE, stop_cross_node, []).


%% 检测节点状态
check_game_node_status() -> 
	code:which(server_config_gen) == non_existing andalso server_config:init(),
	NodeName = util_server:get_node_name(debug),
	case net_kernel:start([NodeName]) of
		{ok, _Pid} -> 
			Cookie = server_config:get_conf(cookie),
			erlang:set_cookie(NodeName, Cookie),
			case util_server:is_cross_node() of
				false -> 
					check_game_node_status_help(?PLAYER_NODE_KEY, 10);
				true -> 
					check_game_node_status_help(?CROSS_NODE_KEY, 10)
			end;
		_ ->
			io:format("start debug node failed!~n")
	end,
	halt(0).


check_game_node_status_help(NodeKey, 0) ->
	NodeName = util_server:get_node_name(NodeKey),
	io:format("~s is not run~n", [NodeName]);
check_game_node_status_help(NodeKey, Count) ->
	NodeName = util_server:get_node_name(NodeKey),
	case net_adm:ping(NodeName) of
		pong ->
			App = ?_IF(util_server:is_cross_node(), ?APP_CROSS, ?APP_SERVER),
			case rpc:call(NodeName, util_server, is_app_started, [App], 3000) of
				false -> 
					timer:sleep(1000),
					check_game_node_status_help(NodeKey, Count - 1);
				true -> 
					io:format("~s is running~n", [NodeName])
			end;
		pang -> 
			io:format("ping ~s failed~n", [NodeName]),
			timer:sleep(1000),
			check_game_node_status_help(NodeKey, Count - 1)
	end.


%% 打印远程连接erlang节点的命令
print_remshell_cmd() -> 
	NodeKey = ?_IF(util_server:is_cross_node(), ?CROSS_NODE_KEY, ?PLAYER_NODE_KEY),
	Cookie     = server_config:get_conf(cookie),
	DebugNode  = util_server:get_node_name(remshell),
	RemoteNode = util_server:get_node_name(NodeKey),
	Format     = "erl -setcookie ~s -name ~s -remsh ~s -pa ebin ebin/lib~n",
	io:format(Format, [Cookie, DebugNode, RemoteNode]),
	halt(0).


%% @doc 获取运行时的一些系统数据
info() ->
	SchedId      = erlang:system_info(scheduler_id),
	SchedNum     = erlang:system_info(schedulers),
	ProcCount    = erlang:system_info(process_count),
	ProcLimit    = erlang:system_info(process_limit),
	ProcMemUsed  = erlang:memory(processes_used),
	ProcMemAlloc = erlang:memory(processes),
	MemTot       = erlang:memory(total),
	io:format("runtime information:
					   ~n   Scheduler id:                         ~w
					   ~n   Num scheduler:                        ~w
					   ~n   Process count:                        ~w
					   ~n   Process limit:                        ~w
					   ~n   Memory used by erlang processes:      ~w
					   ~n   Memory allocated by erlang processes: ~w
					   ~n   The total amount of memory allocated: ~w
					   ",
			[SchedId, SchedNum, ProcCount, ProcLimit, ProcMemUsed, ProcMemAlloc, MemTot]),
	  ok.