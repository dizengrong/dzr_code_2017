%% @doc 英雄远征场景模块
-module (fun_scene_hero_expedition).
-include("common.hrl").
-export([on_create/1,on_stop/1]). 
-export([doMsg/1,do_on_time/1,onTimer/3]).
-export([
	handle/1, on_user_enter/1, on_all_hero_die/1, do_copy_finish/1, entourage_die/2
]).


on_create(_Scene) ->
	erlang:put(sys_object,?INSTANCE_OFF),
	%%添加场景触发脚本 satan 2016.1.30
	fun_scene:run_scene_script(onCreate,[]),
	put(scene_hero_expedition, true),
	erlang:put(robot_attack_robot, true),
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

on_user_enter(Uid) ->
	case erlang:get(uid) of
		undefined -> 
			put(uid, Uid),
			#scene_spirit_ex{data = #scene_usr_ex{hid = AgentPid}} = fun_scene_obj:get_obj(Uid),
			util_misc:msg_handle_cast(AgentPid, mod_hero_expedition, {entered_scene}),
			ok;
		_ -> %% 重连进来
			todo
	end,
	ok.


on_all_hero_die(ObjId) ->
	Uid = get(uid),
	DefenderId = get(defender_id),
	RefId = get(battle_ref_id),
	case ObjId of
		DefenderId -> 
			scene_big_loop:add_callback(1, ?MODULE, do_copy_finish, {?COPY_WIN, RefId});
		Uid -> 
			scene_big_loop:add_callback(1, ?MODULE, do_copy_finish, {?COPY_LOSE, RefId})
	end.


entourage_die(ObjId, Eid) ->
	Uid = get(uid),
	case ObjId of
		Uid -> 
			#scene_spirit_ex{
				data = #scene_usr_ex{hid = AgentPid}
			} = fun_scene_obj:get_obj(Uid),
			util_misc:msg_handle_cast(AgentPid, mod_hero_expedition, {entourage_die, Eid - ?ETRG_OFF});
		_ -> skip
	end.

setup_timeout(Uid) ->
	#st_scene_config{life_time = LifeTime} = data_scene_config:get_scene(get(scene)),
	put(scene_end, LifeTime + util_time:unixtime()),
	mod_scene_api:send_scene_end(Uid),
	RefId = erlang:make_ref(),
	put(battle_ref_id, RefId),
	scene_big_loop:add_callback(LifeTime, ?MODULE, do_copy_finish, {?COPY_LOSE, RefId}).


handle({add_buff, Uid, Buffs}) -> 
	case get(scene_hero_expedition) of
		true -> 
			mod_scene_entourage:all_hero_add_buff(Uid, Buffs);
		_ -> 
			?ERROR("this should not happend")
	end;

handle({move, Uid, {X, Y, Z}}) -> 
	case get(scene_hero_expedition) of
		true -> 
			case fun_scene_obj:get_obj(Uid) of
				#scene_spirit_ex{data = #scene_usr_ex{sid = Sid}} -> 
					Pt = #pt_ret_guide_tag_point{
						x    = X,
						y    = Y,
						z    = Z
					},
					?send(Sid,proto:pack(Pt));
				_ -> skip
			end;
		_ -> ?ERROR("this should not happend")
	end;

handle({do_close, Uid}) -> 
	case get(scene_hero_expedition) of
		true -> 
			case fun_scene_obj:get_obj(Uid) of
				#scene_spirit_ex{data = #scene_usr_ex{hid = AgentPid}} -> 
					util_misc:msg_handle_cast(AgentPid, mod_hero_expedition, manual_kick_out);
				_ -> skip
			end;
		_ -> skip
	end;

handle({begin_fight, {ChallObjData,ChallEntourageData}, AttrAdd, Rewards}) -> 
	case get(scene_hero_expedition) of
		true -> 
			Uid = get(uid),
			put(win_reward, Rewards),
			setup_timeout(Uid),
			#scene_spirit_ex{pos = UsrPos, dir = Dir} = fun_scene_obj:get_obj(Uid),
			{X, Y, Z} = UsrPos,
			ChallPos = {X + 1, Y, Z + 1},
			ReverseDir = 360 - Dir,
			{ok, ChaId} = fun_scene:robot_enter_scene(ChallObjData,UsrPos,ChallPos,ChallEntourageData,ReverseDir,AttrAdd),
			put(defender_id, ChaId),
			EntourageList = [Entourage#item.type || {Entourage, _, _, _, _} <- ChallEntourageData],
			util_scene:send_defender_zhenfa(Uid, EntourageList),
			ok;
		_ -> ?ERROR("this should not happend")
	end.


do_copy_finish({Result, RefId}) -> 
	case get(battle_ref_id) == RefId of
		true -> 
			erase(battle_ref_id), 
			DefenderId = get(defender_id),
			mod_scene_entourage:kill_all_heros(DefenderId),
			Uid = get(uid),
			case erase(win_reward) of
				undefined -> 
					skip;
				AddItems -> 
					#scene_spirit_ex{
						data = #scene_usr_ex{sid = Sid, hid = AgentPid, battle_entourage = OnBattleHeros}
					} = fun_scene_obj:get_obj(Uid),
					LeftHpRateList = collect_hero_left_hp_rate(OnBattleHeros),
					fun_copy_common:send_expedition_result_to_client(Sid, Result, AddItems),
					Msg = {copy_result, Result, AddItems, LeftHpRateList},
					util_misc:msg_handle_cast(AgentPid, mod_hero_expedition, Msg),
					fun_scene_skill:reset_damage_list()
			end;
		_ -> skip
	end.


collect_hero_left_hp_rate(OnBattleHeros) ->
	collect_hero_left_hp_rate(OnBattleHeros, []).
collect_hero_left_hp_rate([HeroId | Rest], Acc) ->
	Rate = case fun_scene_obj:get_obj(HeroId) of
		#scene_spirit_ex{hp = Hp, base_property = #battle_property{hpLimit = MaxHp}} ->
			util:floor(Hp * 10000 / MaxHp);
		_ -> 
			0
	end,
	collect_hero_left_hp_rate(Rest, [{HeroId - ?ETRG_OFF, Rate} | Acc]);
collect_hero_left_hp_rate([], Acc) -> 
	Acc.
