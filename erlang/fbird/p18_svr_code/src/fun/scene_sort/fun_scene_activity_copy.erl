%% @doc 活动副本场景模块
-module (fun_scene_activity_copy).
-include("common.hrl").
-export([on_create/1,on_stop/1]). 
-export([doMsg/1,do_on_time/1,onTimer/3]).
-export([
	on_user_enter/1, on_monster_die/1, do_send_data/1, do_copy_finish/1,
	round_begin/1, on_all_hero_die/1
]).


on_create(_Scene) ->
	erlang:put(sys_object,?INSTANCE_OFF),
	%%添加场景触发脚本 satan 2016.1.30
	fun_scene:run_scene_script(onCreate,[]),

	put(cur_round, 1), 	%% 当前是第几轮
	put(kill_num, 0), 	%% 当前已击杀的数量
	put(reward_gain, []), %% 已获得的奖励
	ok.

on_stop(_Scene) -> 
	ok.

do_on_time(_Cmd) -> 
	continue.

doMsg(_Msg) -> 
	continue.

onTimer(Obj,_Now,_Scene) -> 
	Obj.
%% =============================================================================
get_copy_id() -> 
	get(scene_info).

increase_kill_num() ->
	put(kill_num, get(kill_num) + 1).

add_reward_num() ->
	#st_activity_copy{monsterReward = Rewards} = data_activity_copy:get_copy(get_copy_id()),
	Rewards2 = util_list:add_and_merge_list(get(reward_gain), Rewards, 1, 2),
	put(reward_gain, Rewards2).


get_max_round(CopyId) ->
	#st_activity_copy{monster = {_, MaxRound, _, _}} = data_activity_copy:get_copy(CopyId),
	MaxRound.

get_copy_type(CopyId) ->
	#st_activity_copy{type = CopyType} = data_activity_copy:get_copy(CopyId),
	CopyType.

get_ensured_rewards(CopyId) ->
	#st_activity_copy{ensureReward = Rewards} = data_activity_copy:get_copy(CopyId),
	Rewards.

setup_timeout(Uid) ->
	#st_scene_config{life_time = LifeTime} = data_scene_config:get_scene(get(scene)),
	put(scene_end, LifeTime + util_time:unixtime()),
	mod_scene_api:send_scene_end(Uid),
	scene_big_loop:add_callback(LifeTime, ?MODULE, do_copy_finish, ?COPY_LOSE).


save_copy_boss_max_hp() ->
	[#scene_spirit_ex{final_property = Property} | _] = fun_scene_obj:get_ml(),
	put(boss_max_hp, Property#battle_property.hpLimit).


send_copy_id_to_client(Uid) ->
	case fun_scene_obj:get_obj(Uid) of
		#scene_spirit_ex{data = #scene_usr_ex{sid = Sid}} -> 
			Pt = #pt_scene_copy_id{copy_id = get_copy_id()},
			?send(Sid, proto:pack(Pt));
		_ -> skip
	end.


on_user_enter(Uid) ->
	case erlang:get(uid) of
		undefined -> 
			setup_timeout(Uid),
			send_copy_id_to_client(Uid),
			put(uid, Uid),
			round_begin(get(cur_round)),
			case get_copy_type(get_copy_id()) of
				?ACT_COPY_WARRIOR -> 
					save_copy_boss_max_hp();
				_ -> skip
			end,
			do_send_data(undefined),
			ok;
		_ -> %% 重连进来
			todo
	end,
	ok.


on_monster_die(_MonsterId) ->
	increase_kill_num(),
	add_reward_num(),
	scene_big_loop:add_callback(1, ?MODULE, do_send_data, undefined),
	case fun_scene:is_all_monster_die() of
		true -> round_end();
		_ -> skip
	end,
	ok.


on_all_hero_die(_Uid) ->
	scene_big_loop:add_callback(1, ?MODULE, do_copy_finish, ?COPY_LOSE).


round_begin(Round) ->
	#st_activity_copy{
		monster = {Monsters, _, Num, PosList},
		monsterAdd = AddAttrs
	} = data_activity_copy:get_copy(get_copy_id()),
	AddAttrs2 = [{AttrId, Val * (Round - 1)} || {AttrId, Val} <- AddAttrs],
	Fun = fun(_) -> 
		Monster = util_list:rand(Monsters),
		{X, Y, Z} = util_list:rand(PosList),
		Pos = {X + util_list:rand([2, 1, 0, -1, 2]), Y, Z + util_list:rand([2, 1, 0, -1, 2])},
		mod_scene_monster:create_monster(Monster, Pos, AddAttrs2),
		Monster
	end,
	MonsterTypes = [Fun(S) || S <- lists:seq(1, Num)],
	util_scene:send_defender_zhenfa(get(uid), MonsterTypes),
	ok.

round_end() -> 
	Round = get(cur_round),
	case Round >= get_max_round(get_copy_id()) of
		true -> 
			scene_big_loop:add_callback(1, ?MODULE, do_copy_finish, ?COPY_WIN);
		_ -> 
			put(cur_round, Round + 1),
			scene_big_loop:add_callback(1, ?MODULE, round_begin, get(cur_round))
	end,
	ok.


do_send_data(_) ->
	Rewards = case get_copy_type(get_copy_id()) of
		?ACT_COPY_WARRIOR -> 
			scene_big_loop:add_callback(3, ?MODULE, do_send_data, undefined),
			calc_reward_by_damage();
		_ -> 
			get(reward_gain)
	end,
	Pt = #pt_act_copy_scene_data{
		kill_num = get_kill_num(),
		rewards = fun_item_api:make_item_pt_list(Rewards)
	},
	case fun_scene_obj:get_obj(get(uid)) of
		#scene_spirit_ex{data = #scene_usr_ex{sid = Sid}} -> 
			?send(Sid, proto:pack(Pt));
		_ -> skip
	end.

do_copy_finish(Result) -> 
	Uid = get(uid),
	case get(is_end) of
		undefined -> 
			put(is_end, true),
			#scene_spirit_ex{
				data = #scene_usr_ex{sid = Sid, hid = AgentPid}
			} = fun_scene_obj:get_obj(Uid),
			CopyId = get_copy_id(),
			EnsureReward = get_ensured_rewards(CopyId),
			OtherReward = get(reward_gain),
			AddItems = util_list:add_and_merge_list(OtherReward, EnsureReward, 1, 2),
			fun_copy_common:send_act_copy_result_to_client(Sid, Result, OtherReward, EnsureReward),
			Msg = {copy_result, Result, CopyId, AddItems, get_kill_num()},
			util_misc:msg_handle_cast(AgentPid, fun_activity_copy, Msg);
		_ -> skip
	end.


calc_reward_by_damage() ->
	Times = get_kill_num(),
	#st_activity_copy{monsterReward = Rewards} = data_activity_copy:get_copy(get_copy_id()),
	[{T, N*Times} || {T, N} <- Rewards].


get_kill_num() ->
	case get_copy_type(get_copy_id()) of
		?ACT_COPY_WARRIOR -> 
			case fun_scene_obj:get_ml() of
				[#scene_spirit_ex{hp = CurHp} | _] -> 
					MaxHp = get(boss_max_hp),
					100 - util:ceil(100 * CurHp / MaxHp);
				_ -> %% 这种情况就算boss死亡了
					100
			end;
		_ -> 
			get(kill_num)
	end.

