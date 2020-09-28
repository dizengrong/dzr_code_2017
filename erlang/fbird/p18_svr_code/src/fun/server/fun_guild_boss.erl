%% @doc 公会副本boss相关功能
-module (fun_guild_boss).
-include("common.hrl").
% -export([refresh_data/0]).
% -export([make_boss_list/1]).
% -export([is_boss_can_attack/2, is_boss_killed/2]).
% -export([pass_guild_copy_update/3]).
% -export([get_boss_hp/2]).

% -define(BOSS_STATE_NOT_KILL,0).
% -define(BOSS_STATE_KILLED,1).

% %% boss_list结构:[{data_guild_copy表id, boss满血, 已伤害的血量}]
% get_data(GuildId) ->
% 	case db:dirty_get(guild_boss_hp, GuildId, #guild_boss_hp.guild_id) of
% 		[]    -> 
% 			#guild_boss_hp{
% 				guild_id  = GuildId,
% 				boss_list = get_init_boss_list()
% 			};
% 		[Rec] -> 
% 			BossList = Rec#guild_boss_hp.boss_list,
% 			Rec#guild_boss_hp{boss_list = util:string_to_term(util:to_list(BossList))}
% 	end.
% set_data(Rec) ->
% 	Rec2 = Rec#guild_boss_hp{boss_list = util:term_to_string(Rec#guild_boss_hp.boss_list)},
% 	case Rec#guild_boss_hp.id of
% 		0 -> db:insert(Rec2);
% 		_ -> db:dirty_put(Rec2)
% 	end.

% get_init_boss_list() ->
% 	InitId = 1,
% 	[{InitId, get_init_boss_hp(InitId), 0}].

% %% 每周刷新怪物血量
% refresh_data() ->
% 	[refresh_data(GuildId) || #guild_boss_hp{guild_id = GuildId} <- db:dirty_match(guild_boss_hp, #guild_boss_hp{_ = '_'})],
% 	ok.
% refresh_data(GuildId) ->
% 	Rec = get_data(GuildId),
% 	BossList = [{Id, get_init_boss_hp(Id), 0} || {Id, _, _} <- Rec#guild_boss_hp.boss_list],
% 	set_data(Rec#guild_boss_hp{boss_list = BossList}).

% get_init_boss_hp(Id) -> 
% 	#st_data_guild_copy{boss_id = BossId, sceneid = _SceneType} = data_guild_copy:get_data(Id),
% 	% Difficulty = fun_scene_on_time:get_difficulty(SceneType),
% 	Battle     = fun_property:get_monster_property(BossId, 1, 1, 1),
% 	Battle#battle_property.hpLimit.

% make_boss_list(GuildId) ->
% 	Rec = get_data(GuildId),
% 	[make_boss_list_help(BossData) || BossData <- Rec#guild_boss_hp.boss_list].

% make_boss_list_help({Id, BossMaxHp, DamageHp}) ->
% 	Pt = pt_public_class:guild_copy_list_new(),
% 	#st_data_guild_copy{boss_id = BossId, sceneid = SceneType} = data_guild_copy:get_data(Id),
% 	Pt#pt_public_guild_copy_list{
% 		scene_type = SceneType,
% 		boss_id    = BossId,
% 		boss_hp    = BossMaxHp,
% 		damage_hp  = DamageHp,
% 		kill_state = ?_IF(DamageHp >= BossMaxHp, ?BOSS_STATE_KILLED, ?BOSS_STATE_NOT_KILL)
% 	}.	

% is_boss_can_attack(GuildId, SceneType) ->
% 	List = make_boss_list(GuildId),
% 	case lists:keyfind(SceneType, #pt_public_guild_copy_list.scene_type, List) of
% 		#pt_public_guild_copy_list{damage_hp = DamageHp, boss_hp = BossMaxHp} when DamageHp < BossMaxHp ->
% 			true;
% 		_ -> {error, "error_guild_boss_is_killed"}
% 	end.

% is_boss_killed(GuildId, BossId)	->
% 	List = make_boss_list(GuildId),
% 	case lists:keyfind(BossId, #pt_public_guild_copy_list.boss_id, List) of
% 		#pt_public_guild_copy_list{kill_state = ?BOSS_STATE_KILLED} -> true;
% 		_ -> false
% 	end.


% %%副本结算的时候更新boss血量跟是否击杀
% pass_guild_copy_update(Uid,Scene,Damage) ->
% 	case fun_guild:get_guild_baseinfo(Uid) of
% 		{ok, GuildId, _} ->
% 			% todo:send_damage_info_to_client()
% 			update_boss_hp(GuildId,Uid,Scene,Damage);
% 		_ -> skip
% 	end.
% % mod_msg:handle_to_agent(AgentHid, fun_copy_common, {copy_result,?COPY_WIN,Scene,Exp,Coin,TotalDamage,[]}),
% update_boss_hp(GuildId, Uid, Scene, Damage) ->
% 	[GuildCopyId] = data_guild_copy:select(Scene),
% 	Rec = get_data(GuildId),
% 	Bosslist = Rec#guild_boss_hp.boss_list,
% 	case lists:keyfind(GuildCopyId, 1, Bosslist) of
% 		false -> skip;
% 		{_, BossMaxHp, DamageHp} ->
% 			DamageHp2 = DamageHp + Damage,
% 			Tuple     = {GuildCopyId, BossMaxHp, DamageHp2},
% 			Bosslist2 = lists:keystore(GuildCopyId, 1, Bosslist, Tuple),
% 			set_data(Rec#guild_boss_hp{boss_list = Bosslist2}),
% 			fun_guild_damage:add_usr_damage(Uid, Damage),
% 			check_and_open_new_copy(GuildId, GuildCopyId),
% 			fun_copy_common:send_guild_copy_result(Uid, Scene, BossMaxHp, DamageHp2, Damage)
% 	end.

% %% 获取boss的当前血量:{BossId, BossMaxHp, BossHp}
% get_boss_hp(GuildId, Scene) ->
% 	Rec = get_data(GuildId),
% 	Bosslist = Rec#guild_boss_hp.boss_list,
% 	[GuildCopyId] = data_guild_copy:select(Scene),
% 	#st_data_guild_copy{boss_id = BossId} = data_guild_copy:get_data(GuildCopyId),
% 	{_, BossMaxHp, DamageHp} = lists:keyfind(GuildCopyId, 1, Bosslist),
% 	{BossId, BossMaxHp, BossMaxHp - DamageHp}.

% check_and_open_new_copy(GuildId, GuildCopyId) ->
% 	Rec = get_data(GuildId),
% 	Rec = get_data(GuildId),
% 	Bosslist = Rec#guild_boss_hp.boss_list,
% 	case lists:keyfind(GuildCopyId, 1, Bosslist) of 
% 		{_, BossMaxHp, DamageHp} when DamageHp >= BossMaxHp ->
% 			NewCopyId = GuildCopyId + 1,
% 			case data_guild_copy:get_data(NewCopyId) of
% 				#st_data_guild_copy{} ->
% 					case lists:keyfind(NewCopyId, 1, Bosslist) of
% 						false -> 
% 							Bosslist2 = [{NewCopyId, get_init_boss_hp(NewCopyId), 0} | Bosslist],
% 							set_data(Rec#guild_boss_hp{boss_list = Bosslist2});
% 						_ -> skip
% 					end;
% 				_ -> skip
% 			end;
% 		_ -> skip
% 	end.


