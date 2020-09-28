%% @doc mnesia数据库管理
-module (mnesia_manager).
-include ("common.hrl").
-export ([start/1, stop/0]).
-export ([disc_tab_define/1, ram_tab_define/1]).
%% export_all for test 
-compile([export_all]).


start(StartType) ->
	case check_mnesia_schema() of
		{ok, schema_not_exists} ->
			?INFO("schema_not_exists create new schema"),
			mnesia:create_schema([node()]);
		_ -> 
			ok
	end,
	mnesia:start(),
	mnesia:change_table_copy_type(schema, node(), disc_copies),
	?INFO("mnesia started for:~s", [get_db_start_desc(StartType)]),
	init_tables(),
	?INFO("mnesia inited"),
	case StartType of
		?START_MNESIA_FOR_GAMESERVER -> 
			check_and_update_mnesia();
		?START_MNESIA_FOR_CROSSSERVER -> 
			check_and_update_mnesia();
		?START_MNESIA_FOR_MERGE -> 
			check_and_update_mnesia();
		_ -> skip
	end,
	case ?DEBUG_MODE of
		true -> 
			case db_api:dirty_read(t_server_info, 1) of
				[#t_server_info{version = Version}] ->
					update_mnesia_develop:develop_update(Version);
				_ -> skip
			end;
		_ -> skip
	end,
	case StartType of
		?START_MNESIA_FOR_GAMESERVER ->
			case db_api:dirty_read(t_uid, usr) of
				[] -> 
					%% 也许是清过档了，因为用户中心那边的问题，这个服的角色的id不能再重新开始的
					%% 需要从上一次最后的那个id接着计数，因此把这个id给持久化到文件里了
					MaxUserId = util_server:get_user_tab_current_max_id(),
					case MaxUserId > 0 of
						true -> 
							db_uid:set_new_usr_tab_id(MaxUserId);
						_ -> skip
					end;
				_ -> %% 没有清档时就不需要处理的
					skip
			end;
		_ -> skip
	end,
	ok.


stop() ->
	case db_api:dirty_read(t_uid, usr) of
		[#t_uid{curr_id = MaxUserId}] ->
			util_server:set_user_tab_current_max_id(MaxUserId);
		_ -> skip
	end,
	mnesia:stop().


check_mnesia_schema() ->
	Dir = mnesia:system_info(directory),
	case filelib:is_file(filename:join(Dir, "schema.DAT")) of
		true  -> {ok, schema_exists};
		false -> {ok, schema_not_exists}
	end.


init_tables() -> 
	ExistTabs = mnesia:system_info(local_tables),
	AllTables = table_defines(),
    [{atomic, _} = mnesia:create_table(T, Def) || {T, Def} <- AllTables, not lists:member(T, ExistTabs)],
	?INFO("mnesia finished create_table"),

    AllTables2 = [T || {T, _} <- AllTables],
    mnesia:wait_for_tables(AllTables2, infinity),
    ok.


table_defines() -> 
	case util_server:is_cross_node() of
		false -> 
			List1 = mod_tab_config:all_disc_tabs(),
			List2 = mod_tab_config:all_ram_tabs(),
			[ram_tab_define(Rec) || Rec <- List2] ++ [disc_tab_define(Rec) || Rec <- List1];
		true ->
			List1 = mod_tab_config:cross_node_disc_tabs(),
			List2 = mod_tab_config:cross_node_ram_tabs(),
			[ram_tab_define(Rec) || Rec <- List2] ++ [disc_tab_define(Rec) || Rec <- List1]
	end.


disc_tab_define(#tab_config{tab_name=TabName, type=Type, disc_type=DiscType, attrs=AttrList, indexs=Indexes}) ->
	{TabName, [{type, Type}, {DiscType, [node()]}, {attributes, AttrList}, {index, Indexes}]}.


ram_tab_define(#tab_config{tab_name=TabName, type=Type, attrs=AttrList, indexs=Indexes}) ->
	{TabName, [{type, Type}, {ram_copies, [node()]}, {attributes, AttrList}, {index, Indexes}]}.


%% 检测并升级mnesia数据库
check_and_update_mnesia() -> 
	Agent = server_config:get_conf(agent_name),
	NewVersion = server_config:get_conf(server_version),
	case db_api:dirty_read(t_server_info, 1) of
		[] -> 
			?INFO("server version is first set to:~s", [NewVersion]),
			set_server_version(NewVersion);
		[#t_server_info{version = OldVersion}] when NewVersion < OldVersion ->
			?ERROR("NewVersion:~s is small than OldVersion:~s!!!", [NewVersion, OldVersion]),
			init:stop();
		[#t_server_info{version = OldVersion}] when NewVersion == OldVersion -> 
			?INFO("current server version is:~s, no update", [OldVersion]),
			ok;
		[#t_server_info{version = OldVersion}] ->
			?INFO("current server version is:~s, will update to:~s", [OldVersion, NewVersion]),
			%% 在升级之前备份数据库
			{ok, BackupDBFile} = mt_backup:backup(OldVersion),
			?INFO("begin update mnesia..."),
			try
				do_update_mnesia(Agent, OldVersion, NewVersion)
			catch
				E:R ->
					%% 升级出错了，则尝试自动恢复为刚备份的文件
					%% 如果自动恢复失败了，则需要手动处理了
					?EXCEPTION_LOG(E, R, do_update_mnesia, [Agent, OldVersion, NewVersion]),
					case mnesia:restore(BackupDBFile, []) of
						{atomic, _} -> 
							?INFO("update mnesia failed, auto restore from ~s success", [BackupDBFile]);
						{aborted, Reason} ->
							?INFO("update mnesia failed and restore from ~s failed, reason:~p, need manual handle!", [BackupDBFile, Reason])
					end
			end
	end,
	ok.


%% 这里的数据库升级支持跨版本升级的
do_update_mnesia(Agent, OldVersion, NewVersion) ->
	AllVersions = db_version_script:all_version(Agent),
	case lists:member(NewVersion, AllVersions) of
		false -> 
			?ERROR("NewVersion:~p is not in all_version list!!!", [NewVersion]),
			init:stop();
		true -> 
			Fun = fun(V) -> 
				V > OldVersion andalso V =< NewVersion
			end,
			Matched = lists:filter(Fun, AllVersions),
			do_update_mnesia_help(Matched)
	end.


do_update_mnesia_help([V | Rest]) -> 
	Mod = db_version_script:version_script(V),
	?INFO("begin execute version:~p mnesia update script:~p", [V, Mod]),
	Mod:update_db(),
	?INFO("execute mnesia script:~p succ", [Mod]),
	set_server_version(V),
	?INFO("server version changed to~p", [V]),
	do_update_mnesia_help(Rest);
do_update_mnesia_help([]) -> 
	?INFO("all mnesia update script execute finished!"),
	ok.


set_server_version(Version) -> 
	DateTime = util_time:local_time(),
	case db_api:dirty_read(t_server_info, 1) of
		[] ->
			db_api:dirty_write(#t_server_info{version = Version, update_time = DateTime});
		[Rec] -> 
			db_api:dirty_write(Rec#t_server_info{version = Version, update_time = DateTime})
	end.


get_db_start_desc(?START_MNESIA_FOR_GAMESERVER) -> "game_server";
get_db_start_desc(?START_MNESIA_FOR_CROSSSERVER) -> "cross_server";
get_db_start_desc(?START_MNESIA_FOR_RESTORE) -> "restore";
get_db_start_desc(?START_MNESIA_FOR_MERGE) -> "merge";
get_db_start_desc(?START_MNESIA_FOR_BACKUP) -> "backup".


