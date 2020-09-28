%% @doc mnesia数据库恢复处理
-module (mt_restore).
-include ("common.hrl").
-compile([export_all]).


start(BackupDBFile) ->
	case check_restore_db(BackupDBFile) of
		true -> 
			NodeName = util_server:get_node_name(?PLAYER_NODE_KEY),
			case net_kernel:start([NodeName]) of
				{ok, _Pid} -> 
					Cookie = server_config:get_conf(cookie),
					erlang:set_cookie(NodeName, Cookie),
					restore_db_help(BackupDBFile);
				_ -> 
					?INFO("start node:~p failed!!! ", [NodeName])
			end;
		{error, Reason} -> 
			?INFO("restore db error:~p~n", [Reason])
	end,
	init:stop().


restore_db_help(BackupDBFile) ->
	mnesia_manager:start(?START_MNESIA_FOR_RESTORE),
	?INFO("begin process restore from file:~s", [BackupDBFile]),
	case db_api:size(t_role_base) > 0 of
		true -> 
			?INFO("~ts~n", ["The dest db has datas!!!"]);
		_ -> 
			[#t_server_info{version = Version}] = db_api:dirty_read(t_server_info, 1),
			%% 备份文件名的前缀必须为版本号
			case lists:prefix(Version, filename:basename(BackupDBFile)) of
				false -> 
					?INFO("~ts~n", ["The backup db's version is not match the dest db' version!!!"]);
				true -> 
					case mnesia:restore(BackupDBFile, []) of
						{atomic, _} -> 
							?INFO("restore from ~s success", [BackupDBFile]);
						{aborted, Reason} ->
							?INFO("restore from ~s failed, reason:~p", [BackupDBFile, Reason])
					end
			end
	end.


check_restore_db(BackupDBFile) ->
	case filelib:is_file(BackupDBFile) of
		false -> 
			{error, util_str:format_string("backup file:~s not exists!", [BackupDBFile])};
		_ ->
			case util_server:is_game_server_running() of
				false -> 
					true;
				true -> 
					{error, "game server is in running!"};
				{error, Reason} -> 
					{error, Reason}
			end
	end.


