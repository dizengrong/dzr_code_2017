%% @doc 数据库备份
-module (mt_backup).
-include ("common.hrl").
-export ([start/0, backup/0, backup/1]).


start() ->
	case server_checker:check_before_start() of
		{error, Reason} -> 
			?INFO("start agent node failed:~s~n", [Reason]);
		_ ->
			case util_server:is_game_server_running() of
				true -> 
					backup_online();
				false -> 
					backup_offline();
				{error, Reason} -> 
					?INFO("error happened:~s~n", [Reason])
			end
	end,
	ok.


backup_online() ->
	sm_tool:exe_fun([null, "agent", "mt_backup", "backup"]),
	ok.


backup_offline() ->
	NodeName = util_server:get_node_name(?PLAYER_NODE_KEY),
	case net_kernel:start([NodeName]) of
		{ok, _Pid} -> 
			Cookie = server_config:get_conf(cookie),
			erlang:set_cookie(NodeName, Cookie),
			mnesia_manager:start(?START_MNESIA_FOR_BACKUP),
			backup(),
			mnesia_manager:stop(),
			ok;
		_ -> 
			?ERROR("start node:~p failed!!! Is game server in running?", [NodeName])
	end.



%% 备份数据库
backup() ->
	case db_api:dirty_read(t_server_info, 1) of
		[] -> 
			?ERROR("There is no version data in db when backup db!!!");
		[#t_server_info{version = Version}] ->
			backup(Version)
	end.

backup(CurrentVersion) ->
	Path = util_server:make_mnesia_backup_dir(),
	filelib:ensure_dir(Path),
	NowStr = util_time:time_to_file_string(util_time:unixtime()),
	ServerId = server_config:get_conf(serverid),
	Filename = lists:concat([CurrentVersion, "_", ServerId, "_", NowStr, ".backup"]),
	Filename2 = filename:join([Path, Filename]),
	?INFO("begin generate backup file......", []),
	ok = mnesia:backup(Filename2),
	?INFO("Backup mnesia success, version:~s, to file:~s", [CurrentVersion, Filename2]),
	{ok, Filename2}.

