-module (fun_scene_main).
-include("common.hrl").
-export([on_create/1,on_stop/1]). 
-export([doMsg/1,do_on_time/1,onTimer/3,do_overtime/1]).
-export([handle/1, on_user_enter/1, on_monster_die/1, stage_lose/1, send_result_to_client/1]). 

-define (TIME_LEN, 180).

-define(MAIN_SCENE_MONSTER_WAVE, 	2). %%关卡小怪波数

-define(NO_CHANGE, 	 0). %%不需要切场景
-define(NEED_CHANGE, 1). %%需要切场景

on_create(_Scene) ->
	erlang:put(sys_object,?INSTANCE_OFF),
	{Stage, _} = get(scene_info),
	put(cur_stage, Stage),
	put(battle_stop, true),
	%%添加场景触发脚本 satan 2016.1.30
	fun_scene:run_scene_script(onCreate,[]).

on_stop(_Scene) -> 
	ok.

on_user_enter(Uid) ->
	put(cur_kill_num, 0),
	put(temp_step, 1),
	case get(uid) of
		undefined ->
			put(uid, Uid);
		_ ->
			%% 重连进来
			mod_scene_api:send_scene_end(Uid),
			skip
	end,
	Pt = #pt_main_scene_status{status = 1},
	fun_scene_obj:send_all_usr(proto:pack(Pt)),
	ok.

do_on_time(_Cmd) -> 
	continue.

do_overtime({Uid, Stage}) ->
	case Stage == get(cur_stage) of
		true -> stage_lose(Uid);
		_ -> skip
	end.

handle({move_pos, Uid, Stage}) -> 
	case get(cur_stage) of
		undefined -> %% 不在关卡里
			skip;
		_ ->
			case get(main_scene_timer) of
				undefined ->
					put(scene_end, ?TIME_LEN + util_time:unixtime()),
					mod_scene_api:send_scene_end(Uid),
					TimerRef = erlang:start_timer(?TIME_LEN * 1000, self(), {?MODULE, do_overtime, {Uid, get(cur_stage)}}),
					put(main_scene_timer, TimerRef);
				_ -> skip
			end,
			case get(battle_stop) of
				true -> 
					CurStage = get(cur_stage),
					#st_dungeons_config{dungenScene = OldScene} = data_dungeons_config:get_dungeons(CurStage),
					#st_dungeons_config{dungenScene = NewScene} = data_dungeons_config:get_dungeons(Stage),
					case OldScene == NewScene of
						true -> 
							put(battle_stop, false),
							RoadPoint = util_scene:get_stage_move_pos(get(scene), (get(temp_step) + util_scene:get_stage_index(CurStage))),
							MonsterPoint = util_scene:get_stage_monster_pos(get(scene), (get(temp_step) + util_scene:get_stage_index(CurStage))),
							send_road_point_to_client(Uid, RoadPoint, MonsterPoint);
						_ -> 
							#scene_spirit_ex{data=#scene_usr_ex{hid=AgentHid}} = fun_scene_obj:get_obj(Uid),
							util_misc:msg_handle_cast(AgentHid, mod_scene_api, enter_stage)
					end;
				_ ->
					?WARNING("uid ~p in stage want continue battle, but not in stop status", [Uid])
			end
	end;

handle({atk_boss, Uid, Stage}) ->
	CurStage = get(cur_stage),
	case CurStage == Stage of
		false ->
			?WARNING("uid ~p not in his max stage(~p/~p), cannot atk boss", [Uid, CurStage, Stage]);
		_ ->
			#scene_spirit_ex{dir = Dir1} = fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR),
			Dir = case Dir1 >= 180 of
				true -> Dir1 - 180;
				_ -> Dir1 + 180
			end,
			case get(temp_step) > ?MAIN_SCENE_MONSTER_WAVE of
				true ->
					put(atk_boss, true),
					create_boss(Stage, Dir);
				_ ->
					create_monster(Stage, Dir)
			end
	end;

handle({scene_lose, Uid}) ->
	case get(battle_stop) of
		false ->
			case get(main_scene_timer) of
				undefined -> skip;
				TimerRef ->
					erase(main_scene_timer),
					erlang:cancel_timer(TimerRef)
			end,
			put(cur_kill_num, 0),
			put(atk_boss, false),
			put(temp_step, 1),
			put(battle_stop, true),
			#scene_spirit_ex{data=#scene_usr_ex{hid = AgentHid}} = fun_scene_obj:get_obj(Uid),
			mod_msg:handle_to_scene(self(), ?MODULE, remove_all_buff),
			send_result_to_client({?LOSE, get(cur_stage), AgentHid});
		_ -> skip
	end;

handle(remove_all_buff) ->
	fun_scene_buff:remove_all_buff();

handle(Msg) -> ?debug("unknow msg, module = ~p, Msg = ~p",[?MODULE, Msg]).

doMsg(_Msg) -> 
	continue.

onTimer(Obj,_Now,_Scene) -> 
	Obj.

create_monster(Stage, Dir) ->
	fun_scene_skill:reset_damage_list(),
	RoadPoint = util_scene:get_stage_move_pos(get(scene), (get(temp_step) + util_scene:get_stage_index(Stage))),
	MonsterPoint = util_scene:get_stage_monster_pos(get(scene), (get(temp_step) + util_scene:get_stage_index(Stage))),
	#st_dungeons_config{monsterId = Monsters} = data_dungeons_config:get_dungeons(Stage),
	PosList = util_scene:get_point(RoadPoint, MonsterPoint),
	MonsterList1 = [mod_scene_monster:create_monster(lists:nth(util:rand(1, length(Monsters)), Monsters), Pos, Dir, data_dungeons_config:get_difficulty(Stage)) || Pos <- PosList],
	put(cur_monster_num, length(PosList)),
	MonsterList = [Type || {_, _, Type} <- MonsterList1],
	send_defender_zhenfa(get(uid), MonsterList),
	ok.

create_boss(Stage, Dir) ->
	fun_scene_skill:reset_damage_list(),
	RoadPoint = util_scene:get_stage_move_pos(get(scene), (get(temp_step) + util_scene:get_stage_index(Stage))),
	MonsterPoint = util_scene:get_stage_monster_pos(get(scene), (get(temp_step) + util_scene:get_stage_index(Stage))),
	#st_dungeons_config{bossId = BossList} = data_dungeons_config:get_dungeons(Stage),
	PosList = util_scene:get_point(RoadPoint, MonsterPoint),
	create_boss_help(Stage, Dir, BossList, PosList),
	send_defender_zhenfa(get(uid), BossList),
	ok.

create_boss_help(_, _, [], _) -> ok;
create_boss_help(Stage, Dir, [Boss | Rest1], [Pos | Rest2]) ->
	mod_scene_monster:create_monster(Boss, Pos, Dir, data_dungeons_config:get_difficulty(Stage)),
	create_boss_help(Stage, Dir, Rest1, Rest2).

send_road_point_to_client(Uid, {X, Y, Z}, {MX, MY, MZ}) ->
	case get(temp_step) > ?MAIN_SCENE_MONSTER_WAVE of
		true -> mod_msg:handle_to_scene(self(), mod_scene_entourage, {add_all_hero_buff, Uid, 8888});
		_ -> skip
	end,
	case fun_scene_obj:get_obj(Uid) of
		#scene_spirit_ex{data = #scene_usr_ex{sid = Sid}} -> 
			Pt = #pt_ret_guide_tag_point{
				wave = get(temp_step),
				x    = X,
				y    = Y,
				z    = Z,
				mx   = MX,
				my   = MY,
				mz   = MZ
			},
			?send(Sid,proto:pack(Pt));
		_ -> skip
	end.

on_monster_die(ID) ->
	Pt = #pt_scene_monster_die{id = ID},
	fun_scene_obj:send_all_usr(proto:pack(Pt)),
	IsBattleStop = get(battle_stop),
	IsAtkBoss = get(atk_boss),
	if
		IsBattleStop == true -> skip;
		IsAtkBoss -> 
			case fun_scene:is_all_monster_die() of
				true -> 
					Uid = get(uid),
					reset_to_next_stage(Uid),
					ok;
				_ -> skip
			end;
		true ->
			CurKillNum = get(cur_kill_num),
			case CurKillNum + 1 >= get(cur_monster_num) of
				true ->
					reset_to_next_point(get(temp_step) + 1);
				_ ->
					put(cur_kill_num, CurKillNum + 1)
			end
	end,
	ok.

reset_to_next_point(PosIndex) ->
	put(cur_kill_num, 0),
	CurStage = get(cur_stage),
	put(temp_step, PosIndex),
	RoadPoint = util_scene:get_stage_move_pos(get(scene), (get(temp_step) + util_scene:get_stage_index(CurStage))),
	MonsterPoint = util_scene:get_stage_monster_pos(get(scene), (get(temp_step) + util_scene:get_stage_index(CurStage))),
	send_road_point_to_client(get(uid), RoadPoint, MonsterPoint),
	ok.

reset_to_next_stage(Uid) ->
	case get(battle_stop) of
		false ->
			case get(main_scene_timer) of
				undefined -> skip;
				TimerRef ->
					erase(main_scene_timer),
					erlang:cancel_timer(TimerRef)
			end,
			put(cur_kill_num, 0),
			put(atk_boss, false),
			put(temp_step, 1),
			#scene_spirit_ex{data=#scene_usr_ex{hid = AgentHid}} = fun_scene_obj:get_obj(Uid),
			Stage = get(cur_stage),
			#st_dungeons_config{nextStage = NextStage} = data_dungeons_config:get_dungeons(Stage),
			put(cur_stage, NextStage),
			put(battle_stop, true),
			mod_msg:handle_to_scene(self(), ?MODULE, remove_all_buff),
			send_result(?WIN, Stage, AgentHid),
			ok;
		_ -> skip
	end.

stage_lose(Uid) ->
	case get(battle_stop) of
		false ->
			case get(main_scene_timer) of
				undefined -> skip;
				TimerRef ->
					erase(main_scene_timer),
					erlang:cancel_timer(TimerRef)
			end,
			put(cur_kill_num, 0),
			put(atk_boss, false),
			put(temp_step, 1),
			put(battle_stop, true),
			#scene_spirit_ex{data=#scene_usr_ex{hid = AgentHid}} = fun_scene_obj:get_obj(Uid),
			mod_msg:handle_to_scene(self(), ?MODULE, remove_all_buff),
			send_result(?LOSE, get(cur_stage), AgentHid),
			ok;
		_ -> skip
	end.

send_result(Result, Stage, AgentHid) ->
	erase(scene_end),
	#st_scene_config{end_delay=RT} = data_scene_config:get_scene(get(scene)),
	if
		RT > 0 ->
			scene_big_loop:add_callback(RT, ?MODULE, send_result_to_client, {Result, Stage, AgentHid});
		true -> %% 至少给1秒的延后删除，这样让对象在删除之前可以正常操作
			scene_big_loop:add_callback(1, ?MODULE, send_result_to_client, {Result, Stage, AgentHid})
	end.

send_result_to_client({Result, Stage, AgentHid}) ->
	CurStage = get(cur_stage),
	case Result of
		?WIN ->
			#st_dungeons_config{common_reward = ItemList} = data_dungeons_config:get_dungeons(Stage);
		_ ->
			ItemList = [],
			mod_scene_monster:kill_all_monster()
	end,
	Change = case Result of
		?WIN ->
			#st_dungeons_config{dungenScene = NextScene} = data_dungeons_config:get_dungeons(CurStage),
			case NextScene == get(scene) of
				true -> ?NO_CHANGE;
				_ -> ?NEED_CHANGE
			end;
		_ -> ?NO_CHANGE
	end,
	{X, Y, Z} = util_scene:get_stage_move_pos(get(scene), util_scene:get_stage_index(CurStage)),
	Pt = #pt_main_scene_result{
		result       = Result,
		scene_change = Change,
		x  			 = X,
		y  			 = Y,
		z  			 = Z,
		rewards      = fun_item_api:make_item_pt_list(ItemList),
		damage_list  = util_pt:make_damage_list_pt(fun_scene_skill:get_scene_damage_list()),
		treat_list   = util_pt:make_damage_list_pt(fun_scene_skill:get_scene_treat_list())
	},
	% ?debug("Pt = ~p",[Pt]),
	fun_scene_skill:reset_damage_list(),
	fun_scene_obj:send_all_usr(proto:pack(Pt)),
	case Result of
		?WIN -> mod_msg:handle_to_agent(AgentHid, mod_scene_lev, {stage_finished, Stage, ItemList});
		_ -> mod_msg:handle_to_agent(AgentHid, mod_scene_lev, {stage_lose})
	end.

send_defender_zhenfa(Uid, Monsters) -> 
	case fun_scene_obj:get_obj(Uid) of
		#scene_spirit_ex{data = #scene_usr_ex{sid = Sid}} ->
			{RaceZhenfa, ProfZhenfa} = fun_entourage_zhenfa:get_monster_zhenfa(Monsters),
			Pt = #pt_defender_zhenfa{
				race_zhenfa = RaceZhenfa,
				prof_zhenfa = ProfZhenfa
			},
			?send(Sid, proto:pack(Pt));
		_ -> skip
	end.