%% @doc mnesia数据库合服工具
-module (mt_merge).
-include ("common.hrl").
-compile([export_all]).

-define (ALL_TEMP_TAB, [
	t_role_name_temp,
	t_guild_name_temp,
	t_rename_temp
]).

%% 玩家重名表
-record (t_role_name_temp, {
	name,
	list = []  %% [{ServerId, RoleId}]
}).

%% 公会重名表
-record (t_guild_name_temp, {
	name,
	list = []  %% [{ServerId, GuildId}]
}).


%% 重命名的玩家表
-record (t_rename_temp, {
	uid,
	new_name
}).


%% 包含玩家名的表
-define (CONTAIN_ROLE_NAME_TABS, [
	% {guild_member, #guild_member.uid, #guild_member.name},
	% {mail, #t_mail.reciver_id, #t_mail.reciver_name},
	% {relation, #relation.pid, #relation.name, #relation.relation_uid, #relation.relation_name},
	% {relation_friend, #relation_friend.relation_uid, #relation_friend.relation_name},
	% {relation_enemy, #relation_enemy.relation_uid, #relation_enemy.relation_name},
	% {relation_blacklist, #relation_blacklist.relation_uid, #relation_blacklist.relation_name},
	% {guild_red_packet, #guild_red_packet.uid, #guild_red_packet.name},
	% {guild_damage, #guild_damage.uid, #guild_damage.name},
	% {toplist_fighting, #toplist_fighting.uid, #toplist_fighting.name},
	% {toplist_lev, #toplist_lev.uid, #toplist_lev.name},
	% {toplist_stage, #toplist_stage.uid, #toplist_stage.name},
	% {toplist_arena, #toplist_arena.uid, #toplist_arena.name},
	% {toplist_ride, #toplist_ride.uid, #toplist_ride.name},
	% {toplist_pet, #toplist_pet.uid, #toplist_pet.name},
	% {toplist_entoureage, #toplist_entoureage.uid, #toplist_entoureage.name},
	% {toplist_tower, #toplist_tower.uid, #toplist_tower.name},
	% {toplist_achieve, #toplist_achieve.uid, #toplist_achieve.name},
	% {toplist_dayrecharge, #toplist_dayrecharge.uid, #toplist_dayrecharge.name},
	% {toplist_gem, #toplist_gem.uid, #toplist_gem.name},
	% {toplist_recharge, #toplist_recharge.uid, #toplist_recharge.name},
	% {toplist_consume, #toplist_consume.uid, #toplist_consume.name},
	% {toplist_wing, #toplist_wing.uid, #toplist_wing.name},
	% {toplist_exploit, #toplist_exploit.uid, #toplist_exploit.name},
	% {toplist_ringsoul, #toplist_ringsoul.uid, #toplist_ringsoul.name}
]).


start(ServerIdList) -> 
	put(merge_start_time, util_time:unixtime()),
	log:start(),
	mod_job_manager:init(),
	srv_loglevel:set(?LOG_LV_DEBUG),
	?INFO("Begin merge check..."),
	SrcDir = util_server:make_mnesia_merge_src_dir(),
	case check_befor_merge(ServerIdList, SrcDir) of
		{error, Reason} -> 
			?INFO("~s~n", [Reason]);
		BackupFiles -> 
			case util_server:is_game_server_running() of
				true -> 
				 	?INFO("~s~n", ["Game server is running, please stop it first."]);
				{error, Reason2} -> 
				 	?INFO("~s~n", [Reason2]);
				_ -> 
					start_help(ServerIdList, BackupFiles)
			end
	end,
	init:stop(),
	ok.


check_befor_merge(ServerIdList, SrcDir) ->
	case length(ServerIdList) /= length(lists:usort(ServerIdList)) of
		true -> {error, "server_id list has repeated element"};
		_ -> 
			ServerId = server_config:get_conf(serverid),
			case ServerId =< lists:max(ServerIdList) of
				true -> 
					{error, util_str:format_string(
						"The dest game server id:~p must bigger than merge server id lists!", [ServerId])};
				_ -> 
					{ok, Filenames} = file:list_dir(SrcDir),
					% ?INFO("Filenames:~p", [Filenames]),
					Version = server_config:get_conf(server_version),
					check_befor_merge2(ServerIdList, Version, Filenames, [])
			end
	end.


check_befor_merge2([ServerId | Rest], Version, Filenames, Acc) -> 
	case find_backup_file(ServerId, Version, Filenames) of
		{ok, Filename} -> 
			check_befor_merge2(Rest, Version, Filenames, [{ServerId, Filename} | Acc]);
		_ -> 
			{error, util_str:format_string("Cannot find backup file for server_id:~p", [ServerId])}
	end;
check_befor_merge2([], _Version, _Filenames, Acc) -> lists:reverse(Acc).


find_backup_file(ServerId, Version, [Filename | Rest]) -> 
	Prefix = lists:concat([Version, "_", ServerId, "_"]),
	case lists:prefix(Prefix, Filename) of
		false -> find_backup_file(ServerId, Version, Rest);
		true  -> 
			{ok, Filename}
	end;
find_backup_file(_ServerId, _Version, []) -> 
	false. 


start_help(ServerIdList, BackupFiles) -> 
	NodeName = util_server:get_node_name(?PLAYER_NODE_KEY),
	case net_kernel:start([NodeName]) of
		{ok, _Pid} -> 
			Cookie = server_config:get_conf(cookie),
			erlang:set_cookie(NodeName, Cookie),
			mnesia_manager:start(?START_MNESIA_FOR_MERGE),
			?INFO("starting mnesia, server id list:~w", [ServerIdList]),
			case db_api:size(usr) > 0 of
				true -> 
					?INFO("The dest server database has datas, must be empty!");
				_ -> 
					SrcDir = util_server:make_mnesia_merge_src_dir(),
					_ = [prepare_merge_datas(ServerId, SrcDir, F) || {ServerId, F} <- BackupFiles],
					do_merge(ServerIdList)
			end;
		_ -> 
			?ERROR("start node:~p failed!!!", [NodeName])
	end,
	ok.


prepare_merge_datas(ServerId, SrcDir, BackupFile) ->
	?INFO("prepare merge datas of server:~p, file:~s", [ServerId, BackupFile]),
	FilePath = filename:join([SrcDir, BackupFile]),
	SkipTables = get_merge_skip_tables(),
	case mnesia:restore(FilePath, [{skip_tables, SkipTables}]) of
		{atomic, _} -> 
			?INFO("restore server:~p datas success", [ServerId]),
			?INFO("begin delete role data in server:~p ", [ServerId]),
			remove_discard_roles(),
			?INFO("end delete role data in server:~p ", [ServerId]),
			prepare_merge_datas2(ServerId),
			?INFO("server:~p datas prepare finished", [ServerId]);
		{aborted, Reason} ->
			?INFO("restore server:~p datas failed:~p", [ServerId, Reason]),
			?INFO("Merge interruptted!"),
			init:stop()
	end,
	ok.

%% 合并数据之前先删除死号
remove_discard_roles() -> 
	AllUidList = db_api:dirty_all_keys(usr),
	[remove_discard_roles2(Uid) || Uid <- AllUidList],
	ok.

remove_discard_roles2(Uid) -> 
	case db_api:dirty_index_read(recharge_record, Uid, #recharge_record.uid) of
		[] -> 
			Now = util_time:unixtime(),
			case db_api:dirty_read(usr, Uid) of
				[#usr{lev = Lv, last_login_time = LastLoginTime}] 
				when Lv < 100 andalso 
					 Now - LastLoginTime > 10*?ONE_DAY_SECONDS -> 
					remove_discard_role(Uid);
				_ -> 
					skip
			end;
		_ -> skip
	end,
	ok.

remove_discard_role(Uid) -> 
	db_api:dirty_delete(usr, Uid),
	[db_api:dirty_delete(Tab, Uid) || #tab_config{
										tab_name = Tab, 
										is_role_tab = true
									  } <- mod_tab_config:all_disc_tabs()],

	[db_api:dirty_delete(item, Id) || #item{id = Id} <- db_api:dirty_index_read(item, Uid, #item.uid)],
	ok.


prepare_merge_datas2(ServerId) -> 
	TabList = [create_merge_table(ServerId, Rec) || 
				 Rec = #tab_config{merge_reserve = true} <- mod_tab_config:all_disc_tabs()],
	ok = db_api:wait_for_tables(TabList, 300000),

	[mod_job_manager:add_worker(merge_worker, 
		fun() -> [copy_data_to_merge_table(ServerId, T) || T <- Tabs] end
		) || Tabs <- util_list:divid_list(TabList, 8)],
	mod_job_manager:start_and_wait(merge_worker),

	%% 数据已移动到合并表了，可以删除了
	[mnesia:clear_table(Tab) || Tab <- TabList],
	ok.


copy_data_to_merge_table(ServerId, Tab) ->
	MergeTab = merge_tab_name(ServerId, Tab),
	Fun = fun(Rec) -> db_api:dirty_write(MergeTab, Rec) end,
	db_api:dirty_map(Fun, Tab),
	ok.


create_merge_table(ServerId, TabRec = #tab_config{tab_name=Tab}) ->
	Tab2 = merge_tab_name(ServerId, Tab),
	{_, Define} = mnesia_manager:ram_tab_define(TabRec),
    {atomic, _} = mnesia:create_table(Tab2, [{record_name, Tab} | Define]),
	Tab.


merge_tab_name(ServerId, Tab) -> 
	util:list_to_atom2(lists:concat([Tab, "_", ServerId])).


get_merge_skip_tables() -> 
	[Tab || #tab_config{tab_name = Tab, merge_reserve = false} <- mod_tab_config:all_disc_tabs()].


get_merge_tables() -> 
	[Tab || #tab_config{tab_name = Tab, merge_reserve = true} <- mod_tab_config:all_disc_tabs()].

get_merge_tables(Type) -> 
	[Tab || #tab_config{tab_name = Tab, type = Type2, 
						merge_reserve = true} <- mod_tab_config:all_disc_tabs(), Type2 == Type].


create_temp_tab() -> 
	_ = [create_temp_tab(Tab) || Tab <- ?ALL_TEMP_TAB].

create_temp_tab(Tab = t_role_name_temp) ->
	Define = #tab_config{tab_name = Tab, attrs = record_info(fields, t_role_name_temp)},
	{_, Define2} = mnesia_manager:ram_tab_define(Define),
    {atomic, _} = mnesia:create_table(Tab, Define2),
	ok.


do_merge(ServerIdList) -> 
	?INFO("All merge datas prepareed ok, do merge"),
	
	create_temp_tab(),
	?INFO("begin process name"),
	do_process_name(ServerIdList),
	?INFO("end of process name~n"),

	?INFO("begin merge all data"),
	do_merge_all_data(ServerIdList),
	?INFO("end of merge all data~n"),

	?INFO("begin rename user name"),
	do_rename_all_data(),
	?INFO("end of rename user name~n"),

	?INFO("begin remove rank title"),
	do_remove_rank_title(),
	?INFO("end of remove rank title~n"),

	% ?INFO("begin generate new entourage id"),
	% do_generate_new_entourage_id(),
	% ?INFO("end of generate new entourage id~n"),

	?INFO("begin remove all temp tables"),
	do_remove_all_temp_tables(ServerIdList),
	?INFO("end of begin remove all temp tables~n"),

	mnesia:dump_log(),
	mnesia:stop(),
	?INFO("End of merge, cost time:~ps", [util_time:unixtime() - get(merge_start_time)]),
	ok.


%% 改名
do_process_name(ServerIdList) -> 
	do_process_role_name(ServerIdList),
	do_process_guild_name(ServerIdList),
	ok.


do_process_role_name(ServerIdList) ->
	Fun = fun(#usr{name = Name, id = RoleId}, ServerId) -> 
		case db_api:dirty_read(t_role_name_temp, Name) of
			[] -> 
				db_api:dirty_write(#t_role_name_temp{name = Name, list = [{ServerId, RoleId}]});
			[Rec = #t_role_name_temp{list = List}] -> 
				db_api:dirty_write(Rec#t_role_name_temp{list = [{ServerId, RoleId} | List]})
		end,
		ServerId
	end,
	[db_api:dirty_foldl(Fun, Id, merge_tab_name(Id, usr)) || Id <- ServerIdList],
	Fun2 = fun(Rec = #t_role_name_temp{list = List}, Acc) ->
		case length(List) > 1 of
			true -> [Rec | Acc];
			_ -> Acc
		end
	end,
	[build_temp_role_name(Rec) || Rec <- db_api:dirty_foldl(Fun2, [], t_role_name_temp)],
	ok.


build_temp_role_name(#t_role_name_temp{name = Name, list = List}) -> 
	Fun = fun(ServerId, RoleId) ->
		Suffix = list_to_binary(util_str:format_string(".S~p", [ServerId])),
		NewName = <<Name/binary, Suffix/binary>>,
		Tab = merge_tab_name(ServerId, usr),
		[Rec] = db_api:dirty_read(Tab, RoleId),
		db_api:dirty_write(Tab, Rec#usr{name = NewName}),
		db_api:dirty_write(#t_rename_temp{uid = RoleId, new_name = NewName})
	end,
	[Fun(ServerId, RoleId) || {ServerId, RoleId} <- List],
	ok.


do_process_guild_name(ServerIdList) -> 
	Fun = fun(#guild{name = Name, id = GuildId}, ServerId) -> 
		case db_api:dirty_read(t_guild_name_temp, Name) of
			[] -> 
				db_api:dirty_write(#t_guild_name_temp{name = Name, list = [{ServerId, GuildId}]});
			[Rec = #t_guild_name_temp{list = List}] -> 
				db_api:dirty_write(Rec#t_guild_name_temp{list = [{ServerId, GuildId} | List]})
		end,
		ServerId
	end,
	[db_api:dirty_foldl(Fun, Id, merge_tab_name(Id, guild)) || Id <- ServerIdList],
	Fun2 = fun(Rec = #t_guild_name_temp{list = List}, Acc) ->
		case length(List) > 1 of
			true -> [Rec | Acc];
			_ -> Acc
		end
	end,
	[build_temp_guild_name(Rec) || Rec <- db_api:dirty_foldl(Fun2, [], t_guild_name_temp)],
	ok.


build_temp_guild_name(#t_guild_name_temp{name = Name, list = List}) -> 
	Fun = fun(ServerId, GuildId) ->
		Suffix = list_to_binary(util_str:format_string(".S~p", [ServerId])),
		NewName = <<Name/binary, Suffix/binary>>,
		Tab = merge_tab_name(ServerId, guild),
		[Rec] = db_api:dirty_read(Tab, GuildId),
		db_api:dirty_write(Tab, Rec#guild{name = NewName})
	end,
	[Fun(ServerId, GuildId) || {ServerId, GuildId} <- List],
	ok.


do_merge_all_data(ServerIdList) -> 
	%% todo:尽量只使用set类型的表，不要创建bag类型的表，如果有的话需要在这里加上处理
	SetTabs = get_merge_tables(ordered_set) ++ get_merge_tables(set),
	SetTabs2 = util_list:divid_list(SetTabs, 8),
	[mod_job_manager:add_worker(merge_set, fun() -> do_merge_set_table(ServerIdList, Tabs) end) || Tabs <- SetTabs2],
	mod_job_manager:start_and_wait(merge_set),
	ok.


do_merge_set_table(ServerIdList, Tabs) ->
	AllNewDiscTabs = mod_tab_config:new_all_disc_tabs(),
	Fun = fun(ServerId, Tab) ->
		MergeTab = merge_tab_name(ServerId, Tab),
		AllKey = db_api:dirty_all_keys(MergeTab),
		case lists:keymember(Tab, #tab_config.tab_name, AllNewDiscTabs) of
			true -> 
				[db_api:dirty_write(hd(db_api:dirty_read(MergeTab, Key))) || Key <- AllKey];
			_ ->
				[db:insert(hd(db_api:dirty_read(MergeTab, Key))) || Key <- AllKey]
		end
	end,
	[Fun(ServerId, Tab) || Tab <- Tabs, ServerId <- ServerIdList],
	ok.


%% 重命名所有与名字有关的表
do_rename_all_data() ->
	List = util_list:divid_list(?CONTAIN_ROLE_NAME_TABS, 8),
	[mod_job_manager:add_worker(rename_role, fun() -> do_rename_role(Tabs) end) || Tabs <- List],
	mod_job_manager:start_and_wait(rename_role),

	do_rename_guild(),
	ok.


do_rename_role({Tab, UidIndex, NameIndex}) ->
	Fun = fun(Key) ->
		[Rec] = db_api:dirty_read(Tab, Key),
		Uid = element(UidIndex, Rec),
		case db_api:dirty_read(t_rename_temp, Uid) of
			[] -> skip;
			[#t_rename_temp{new_name = NewName}] ->
				db_api:dirty_write(setelement(NameIndex, Rec, NewName))  
		end
	end,
	[Fun(Key) || Key <- db_api:dirty_all_keys(Tab)];
do_rename_role({Tab, UidIndex1, NameIndex1, UidIndex2, NameIndex2}) -> 
	Fun = fun(Key, UidIndex, NameIndex) ->
		[Rec] = db_api:dirty_read(Tab, Key),
		Uid = element(UidIndex, Rec),
		case db_api:dirty_read(t_rename_temp, Uid) of
			[] -> skip;
			[#t_rename_temp{new_name = NewName}] ->
				db_api:dirty_write(setelement(NameIndex, Rec, NewName))  
		end
	end,
	[Fun(Key, UidIndex1, NameIndex1) || Key <- db_api:dirty_all_keys(Tab)],
	[Fun(Key, UidIndex2, NameIndex2) || Key <- db_api:dirty_all_keys(Tab)].


do_rename_guild() -> 
	%% 公会名暂时只有guild才有，其他表没有
	ok.


do_remove_rank_title() ->
	Fun = fun(Key) ->
		[Rec = #t_title{}] = db_api:dirty_read(t_title, Key),
		Titles = [E || E = {Type, _Lv, _EndTime} <- Rec#t_title.titles, not data_rank_reward:is_rank_title(Type)],
		case length(Titles) /= length(Rec#t_title.titles) of
			true -> skip;
			_ -> 
				Rec2 = Rec#t_title{
					titles = Titles,
					used = ?_IF(data_rank_reward:is_rank_title(Rec#t_title.used), 0, Rec#t_title.used)
				},
				db_api:dirty_write(Rec2)
		end
	end,
	_ = [Fun(Key) || Key <- db_api:dirty_all_keys(t_title)].




do_remove_all_temp_tables(ServerIdList) -> 
	Tabs = get_merge_tables(),
	[mod_job_manager:add_worker(merge_del_tmp, 
		fun() -> _ = [mnesia:delete_table(merge_tab_name(ServerId, Tab)) || Tab <- Tabs] end) 
	 || ServerId <- ServerIdList],
	mod_job_manager:start_and_wait(merge_del_tmp),
	[mnesia:delete_table(Tab) || Tab <- ?ALL_TEMP_TAB],
	ok.


% do_generate_new_entourage_id() ->
% 	Fun = fun(Key) ->
% 		[Rec] = db_api:dirty_read(t_entourage, Key),
% 		List = [E#entourage{id = db_uid:new_id(t_entourage)} || E <- Rec#t_entourage.entourage_list],
% 		db_api:dirty_write(Rec#t_entourage{entourage_list = List})
% 	end,
% 	[Fun(Key) || Key <- db_api:dirty_all_keys(t_entourage)],
% 	ok.
