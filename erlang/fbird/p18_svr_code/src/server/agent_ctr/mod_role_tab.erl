%% @doc 操作玩家数据表的模块，这里应该只对玩家需要频繁获取的数据做游戏内缓存
%% 注意：读取数据一定要通过这里封装的lookup/2接口去读取，因为有做数据读取的“引用计数”
-module (mod_role_tab).
-include("common.hrl").
-export ([init/1, save/1, save/2, table_name/1]).
-export ([lookup/2, insert/2, delete/2]).
-export ([get_resoure/2, add_resource/3, login_get_init_resources/1]).


%% 表的类型
%% 对于TAB_TYPE_N类型的表，缓存会存对应表的所有数据的key的列表:{Tab, KeyList}
%% 且每条记录会以这种形式存储:{{Tab, Key}, [Rec]}
%% 但是不管是哪种类型的表，都会保存返回值格式一致
-define (TAB_TYPE_1, 1).	%% 一个玩家只有一条数据
-define (TAB_TYPE_N, 2).	%% 一个玩家会有多条数据


%% 需要缓存成ets表数据的数据表
-define (ALL_CACHE_TABLE, [
	item,
	% t_pet,
	% talent,
	% pearl,
	% usr_sailing,
	% usr_legendary_level,
	% usr_god_costume,
	% usr_entourage_challenge,
	% usr_melleboss,
	% arena_info_new,
	% t_compose,
	t_guild_technology,
	t_skill,
	t_activity_copy,
	t_role_expedition,
	% t_gem,
	t_clothes,
	t_recharge_extra_rewards,
	t_time_reward,
	t_draw,
	t_role_store,
	t_role_turntable,
	t_role_draw_record,
	t_entourage_list,
	t_offline_reward,
	t_main_task,
	t_daily_task,
	t_usr_misc
]).


%% 表的uid字段位置
tab_uid_index_field(t_guild_technology) -> #t_guild_technology.uid;
tab_uid_index_field(t_role_expedition) -> #t_role_expedition.uid;
tab_uid_index_field(t_activity_copy) -> #t_activity_copy.uid;
tab_uid_index_field(item) -> #item.uid;
% tab_uid_index_field(t_pet) -> #t_pet.uid;
% tab_uid_index_field(talent) -> #talent.uid;
% tab_uid_index_field(pearl) -> #pearl.uid;
% tab_uid_index_field(usr_sailing) -> #usr_sailing.uid;
% tab_uid_index_field(usr_legendary_level) -> #usr_legendary_level.uid;
% tab_uid_index_field(usr_god_costume) -> #usr_god_costume.uid;
% tab_uid_index_field(arena_info_new) -> #arena_info_new.uid;
% tab_uid_index_field(t_compose) -> #t_compose.uid;
tab_uid_index_field(t_skill) -> #t_skill.uid;
% tab_uid_index_field(t_gem) -> #t_gem.uid;
% tab_uid_index_field(usr_entourage_challenge) -> #usr_entourage_challenge.uid;
% tab_uid_index_field(usr_melleboss) -> #usr_melleboss.uid;
tab_uid_index_field(t_clothes) -> #t_clothes.uid;
tab_uid_index_field(t_recharge_extra_rewards) -> #t_recharge_extra_rewards.uid;
tab_uid_index_field(t_time_reward) -> #t_time_reward.uid;
tab_uid_index_field(t_draw) -> #t_draw.uid;
tab_uid_index_field(t_role_store) -> #t_role_store.uid;
tab_uid_index_field(t_role_turntable) -> #t_role_turntable.uid;
tab_uid_index_field(t_role_draw_record) -> #t_role_draw_record.uid;
tab_uid_index_field(t_entourage_list) -> #t_entourage_list.uid;
tab_uid_index_field(t_offline_reward) -> #t_offline_reward.uid;
tab_uid_index_field(t_main_task) -> #t_main_task.uid;
tab_uid_index_field(t_daily_task) -> #t_daily_task.uid;
tab_uid_index_field(t_usr_misc) -> #t_usr_misc.uid.



%% 表的类型
tab_type(item) -> ?TAB_TYPE_N;
tab_type(_) -> ?TAB_TYPE_1.

%% 当表为TAB_TYPE_N类型时，record的唯一索引字段（相对于这个玩家而言）
record_unique_field(item) -> #item.id.


table_name(Uid) -> 
	Uid2 = integer_to_list(Uid),
	util:list_to_atom2(Uid2). 


%% 玩家表对应的数据更新的脏表，保存着所有的有更新的数据的key
dirty_table(Uid) -> 
	util:list_to_atom2(lists:concat([dirty, "_", Uid])). 


init(Uid) -> 
	Opts         = [named_table, set, public, {keypos, 1}],
	RoleEts      = table_name(Uid),
	RoleEtsDirty = dirty_table(Uid),
	case mod_ets_service:create_ets(RoleEts, RoleEtsDirty, Opts) of
		{ok, new} -> %% 新创建，则要重新加载数据
			try
				case ?DEBUG_MODE of
					true -> 
						{CostTime, _} = timer:tc(fun() -> load_from_mnesia(Uid, RoleEts) end),
						?INFO("role load data cost:~p", [CostTime]);
					_ -> 
						load_from_mnesia(Uid, RoleEts)
				end,
				ok
			catch
				E:R ->
					?EXCEPTION_LOG(E, R, load_from_mnesia, Uid),
					mod_ets_service:force_recycle(RoleEts, RoleEtsDirty),
					init_fail
			end;
		_ -> 
			ok
	end.


%% 封装玩家缓存表的读取
r_dirty_read(Tab, Uid, UidIndex) -> 
	case UidIndex of
		2 -> db_api:dirty_read(Tab, Uid);
		_ -> db_api:dirty_index_read(Tab, Uid, UidIndex)
	end.


load_from_mnesia(Uid, RoleEts) ->
	load_resource_from_mnesia_2_ets(Uid, RoleEts),
	[load_from_mnesia(Uid, RoleEts, Tab) || Tab <- ?ALL_CACHE_TABLE],
	ok.
load_from_mnesia(Uid, RoleEts, Tab) ->
	List = r_dirty_read(Tab, Uid, tab_uid_index_field(Tab)),
	case tab_type(Tab) of
		?TAB_TYPE_1 -> 
			ets:insert(RoleEts, List);
		?TAB_TYPE_N ->
			KeyField = record_unique_field(Tab),
			Fun = fun(Rec) ->
				Key = element(KeyField, Rec),
				ets:insert(RoleEts, {{Tab, Key}, [Rec]}),
				Key
			end,
			Keys = [Fun(Rec) || Rec <- List],
			ets:insert(RoleEts, {Tab, Keys})
	end.


lookup(Uid, Tab) ->
	RoleEts = table_name(Uid),
	case ets:info(RoleEts) of
		undefined ->
			lookup_from_mnesia(Tab, Uid); 
		_ ->
			case catch lookup_from_ets(RoleEts, Tab) of
				{'EXIT', Reason} -> %% 表可能被回收了
					?ERROR("Read role ets tab failed, reason:~p", [Reason]),
					lookup_from_mnesia(Tab, Uid); 
				Ret -> 	
					%% 因为存在mod_ets_service进程回收表的情况，也可能在这里表被刚好回收了
					catch mod_ets_service:update_counter_ref(RoleEts),
					Ret
			end
	end.


lookup_from_mnesia(Tab, Uid) ->
	case Tab of
		{Tab2 = equip_part, PartKey} -> 
			case lists:keyfind(PartKey, record_unique_field(Tab2), db_api:dirty_index_read(Tab2, Uid, tab_uid_index_field(Tab2))) of
				false -> [];
				Rec -> [Rec]
			end;
		{Tab2, Key} -> 
			db_api:dirty_read(Tab2, Key);
		_ ->
			List = r_dirty_read(Tab, Uid, tab_uid_index_field(Tab)),
			case tab_type(Tab) of
				?TAB_TYPE_1 -> 
					List;
				?TAB_TYPE_N -> 
					%% 对于一对多的表，为了保持从缓存和mnesia中读取的返回值是一致的
					%% 所以这里返回的也是key的列表，不过付出的代价却是相当于是玩家在线时读取的两倍
					%% 从业务逻辑来讲这个是可以接受的，很少会出现
					KeyField = record_unique_field(Tab),
					[element(KeyField, Rec) || Rec <- List]
			end
	end.


lookup_from_ets(RoleEts, Tab) ->
	case Tab of
		{Tab2, _Key} -> ok;
		_ -> Tab2 = Tab
	end,
	case tab_type(Tab2) of
		?TAB_TYPE_1 -> 
			ets:lookup(RoleEts, Tab2);
		?TAB_TYPE_N ->
			case ets:lookup(RoleEts, Tab) of
				[] -> [];
				[{_, List}] -> List
			end
	end.


insert(Uid, Rec) ->
	Tab = element(1, Rec),
	RoleEts = table_name(Uid),
	case ets:info(RoleEts) of
		undefined -> 
			insert_rec_to_db(Rec);
		_ ->
			case tab_type(Tab) of
				?TAB_TYPE_1 -> 
					ets:insert(RoleEts, Rec),
					add_dirty_key(Uid, {Tab}),
					[Rec];
				?TAB_TYPE_N -> 
					KeyList = lookup_from_ets(RoleEts, Tab),
					KeyField = record_unique_field(Tab),
					Key = element(KeyField, Rec),
					{AddDirtyKey, NewRec, Key2} = case lists:member(Key, KeyList) of
						true -> 
							{true, Rec, Key};
						_ ->
							[Rec2] = insert_rec_to_db(Rec),
							{false, Rec2, element(KeyField, Rec2)}
					end,
					ets:insert(RoleEts, {{Tab, Key2}, [NewRec]}),
					case lists:member(Key2, KeyList) of
						false -> 
							ets:insert(RoleEts, {Tab, [Key2 | KeyList]});
						_ -> 
							skip
					end,
					AddDirtyKey andalso add_dirty_key(Uid, {{Tab, Key2}}),
					[NewRec]
			end
	end.


insert_rec_to_db(Rec) ->
	insert_rec_to_db2(Rec).

%% 这里加了一个判定，是因为对item表操作不能再使用老的db模块的接口了，用了的话就会报错，便于发现问题
insert_rec_to_db2(Rec) when is_record(Rec, item) ->
	case element(2, Rec) of
		0 -> 
			Rec2 = setelement(2, Rec, db_uid:new_id(element(1, Rec))),
			db_api:dirty_write(Rec2),
			[Rec2];
		undefined -> 
			Rec2 = setelement(2, Rec, db_uid:new_id(element(1, Rec))),
			db_api:dirty_write(Rec2),
			[Rec2];
		_ -> 
			db_api:dirty_write(Rec),
			[Rec]
	end;
insert_rec_to_db2(Rec) ->
	case element(2, Rec) of
		0 -> 
			db:insert(Rec);
		undefined -> 
			db:insert(Rec);
		_ -> 
			db_api:dirty_write(Rec), 
			[Rec]
	end.


add_dirty_key(Uid, Tuple) ->
	ets:insert(dirty_table(Uid), Tuple).


delete(Uid, Rec) ->
	Tab = element(1, Rec),
	RoleEts = table_name(Uid),
	case ets:info(RoleEts) of
		undefined -> 
			db_api:dirty_delete(Tab, element(2, Rec));
		_ -> 
			case tab_type(Tab) of
				?TAB_TYPE_1 ->
					ets:delete(RoleEts, Tab);
				?TAB_TYPE_N ->
					KeyList  = lookup_from_ets(RoleEts, Tab),
					KeyField = record_unique_field(Tab),
					Key      = element(KeyField, Rec),
					KeyList2 = lists:delete(Key, KeyList),
					ets:delete(RoleEts, {Tab, Key}),
					ets:insert(RoleEts, {Tab, KeyList2})
			end,
			db_api:dirty_delete(Tab, element(2, Rec))
	end.


save(Uid) ->
	save(Uid, false).
save(Uid, Offline) ->
	RoleEts = table_name(Uid),
	case ets:info(RoleEts) of
		undefined -> %% 存在初始化失败时，表就会不存在了
			skip;
		_ -> 
			DirtyEts = dirty_table(Uid),
			save_help(Uid, RoleEts, DirtyEts, ets:first(DirtyEts)),
			ets:delete_all_objects(DirtyEts),
			save_resource(Uid, RoleEts),
			%% 更新表的引用计数，防止出现玩家在线时表也被回收的情况
			%% 也因为这个，mod_ets_service回收表的定时器间隔必须大于玩家定时保存数据的间隔
			mod_ets_service:update_counter_ref(RoleEts, Offline)
	end,
	ok.


save_help(_Uid, _RoleEts, _DirtyEts, '$end_of_table') -> ok;
save_help(Uid, RoleEts, DirtyEts, Key) ->
	case ets:lookup(RoleEts, Key) of
		[] -> %% 可能是在delete/2中被删除了
			save_help(Uid, RoleEts, DirtyEts, ets:next(DirtyEts, Key));
		[Rec] -> 
			case Key of
				{_Tab, _IndexKey} -> 
					{_, [Rec2]} = Rec,
					insert_rec_to_db(Rec2),
					save_help(Uid, RoleEts, DirtyEts, ets:next(DirtyEts, Key));
				_ ->
					insert_rec_to_db(Rec),
					save_help(Uid, RoleEts, DirtyEts, ets:next(DirtyEts, Key))
			end
	end.


%% =============================== resource api ================================
load_resource_from_mnesia_2_ets(Uid, RoleEts) ->
	RoleEts = table_name(Uid),
	case db_api:dirty_read(t_resource, Uid) of
		[Rec] -> ok;
		[] -> 
			Rec = #t_resource{uid = Uid},
			db_api:dirty_write(Rec)
	end,
	ets:insert(RoleEts, Rec),
	[ets:insert(RoleEts, {{t_resource, T}, N}) || {T, N} <- Rec#t_resource.resources],
	ets:insert(RoleEts, {resource_changed_list, []}), %% 记录变化的资源id的列表
	ok.

%% 初始登陆时获取资源，这时资源还没有修改，这样写是因为获取快
login_get_init_resources(Uid) ->
	RoleEts = table_name(Uid),
	[Rec] = ets:lookup(RoleEts, t_resource),
	[
		{?RESOUCE_COPPER_NUM, get_resource_from_rec(?RESOUCE_COPPER_NUM, Rec)},
		{?RESOUCE_COIN_NUM, get_resource_from_rec(?RESOUCE_COIN_NUM, Rec)},
		{?RESOUCE_EXP_NUM, get_resource_from_rec(?RESOUCE_EXP_NUM, Rec)},
		{?RESOUCE_ENTOURAGE_EXP_NUM, get_resource_from_rec(?RESOUCE_ENTOURAGE_EXP_NUM, Rec)},
		{?RESOUCE_ENTOURAGE_SOUL_NUM, get_resource_from_rec(?RESOUCE_ENTOURAGE_SOUL_NUM, Rec)},
		{?RESOUCE_VIP_EXP_NUM, get_resource_from_rec(?RESOUCE_VIP_EXP_NUM, Rec)},
		{?RESOUCE_BINDING_COIN_NUM, get_resource_from_rec(?RESOUCE_BINDING_COIN_NUM, Rec)},
		{?RESOUCE_EXPLOIT_NUM, get_resource_from_rec(?RESOUCE_EXPLOIT_NUM, Rec)},
		{?RESOUCE_FRIENDSHIP_POINT_NUM, get_resource_from_rec(?RESOUCE_FRIENDSHIP_POINT_NUM, Rec)},
		{?RESOUCE_HERO_COIN_NUM, get_resource_from_rec(?RESOUCE_HERO_COIN_NUM, Rec)},
		{?RESOUCE_SHENQI_EXP_NUM, get_resource_from_rec(?RESOUCE_SHENQI_EXP_NUM, Rec)},
		{?RESOUCE_SHENQI_SOUL_NUM, get_resource_from_rec(?RESOUCE_SHENQI_SOUL_NUM, Rec)},
		{?RESOUCE_GUILD_EXP, get_resource_from_rec(?RESOUCE_GUILD_EXP, Rec)},
		{?RESOUCE_FUWEN, get_resource_from_rec(?RESOUCE_FUWEN, Rec)}
	].


get_resource_from_rec(ResType, Rec) ->
	case lists:keyfind(ResType, 1, Rec#t_resource.resources) of 
		false -> 0;
		{_, N} -> N
	end.


get_resoure(Uid, ResType) ->
	RoleEts = table_name(Uid),
	case ets:info(RoleEts) of
		undefined ->
			lookup_resource_from_mnesia(Uid, ResType); 
		_ ->
			case catch ets:lookup(RoleEts, {t_resource, ResType}) of
				{'EXIT', Reason} -> %% 表可能被回收了
					?ERROR("Read role ets tab failed, reason:~p", [Reason]),
					lookup_resource_from_mnesia(Uid, ResType); 
				[] -> 
					catch mod_ets_service:update_counter_ref(RoleEts),
					0;
				[{_, Num}] -> 
					catch mod_ets_service:update_counter_ref(RoleEts),
					Num
			end
	end.


%% 添加资源，返回更新后的值
add_resource(Uid, ResType, Add) -> 
	RoleEts = table_name(Uid),
	case ets:info(RoleEts) of
		undefined ->
			add_resource_to_mnesia(Uid, ResType, Add);
		_ ->
			NewNum = min(?MAX_INT, get_resoure(Uid, ResType) + Add),
			ets:insert(RoleEts, {{t_resource, ResType}, NewNum}),
			[{_, ChangedList}] = ets:lookup(RoleEts, resource_changed_list),
			case lists:member(ResType, ChangedList) of
				false -> 
					ets:insert(RoleEts, {resource_changed_list, [ResType | ChangedList]});
				_ -> skip
			end,
			NewNum
	end.

save_resource(_Uid, RoleEts) ->
	[Rec] = ets:lookup(RoleEts, t_resource),
	[{_, ChangedList}] = ets:lookup(RoleEts, resource_changed_list),
	Rec2 = save_resource_help(ChangedList, RoleEts, Rec),
	%% 先更新缓存的数据
	ets:insert(RoleEts, Rec2),
	db_api:dirty_write(Rec2),
	ets:insert(RoleEts, {resource_changed_list, []}).

save_resource_help([ResType | Rest], RoleEts, Rec) -> 
	case ets:lookup(RoleEts, {t_resource, ResType}) of
		[] -> save_resource_help(Rest, RoleEts, Rec);
		[{_, New}] ->
			Resources = lists:keystore(ResType, 1, Rec#t_resource.resources, {ResType, New}),
			save_resource_help(Rest, RoleEts, Rec#t_resource{resources = Resources})
	end;
save_resource_help([], _RoleEts, Rec) -> Rec. 


lookup_resource_from_mnesia(Uid, ResType) ->
	[Rec] = db_api:dirty_read(t_resource, Uid),
	case lists:keyfind(ResType, 1, Rec#t_resource.resources) of
		false -> 0;
		{_, N} -> N
	end.


add_resource_to_mnesia(Uid, ResType, Add) ->
	[Rec] = db_api:dirty_read(t_resource, Uid),
	New = case lists:keyfind(ResType, 1, Rec#t_resource.resources) of
		false -> Add;
		{_, N} -> N + Add
	end,
	Resources = lists:keystore(ResType, 1, Rec#t_resource.resources, {ResType, New}), 
	db_api:dirty_write(Rec#t_resource{resources = Resources}),
	New.

