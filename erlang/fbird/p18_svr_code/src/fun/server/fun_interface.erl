%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% name : interface module
%% author : Andy lee
%% date : 15/7/23 
%% Company : fbird
%% Desc : 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-module(fun_interface).
-include("common.hrl").


-export([s_add_monster/6,s_add_monster/7,s_add_monster/8,s_add_monster/9,s_add_monster_ex/8,s_add_monster_by_mon/6,s_add_monster_by_mon_pos/6,s_del_monster/1,s_kill_monster/1,s_kill_all_monster/0,s_add_partrol_point/2]).
-export([s_add_scene_item/4,s_add_scene_item/9,s_del_item/1,s_kill_item/1,s_get_scene_item/1,s_to_next_step/0,s_add_monster_list_by_pos/7]).
-export([s_get_monster_die/1,s_get_monster_die/2,s_set_parm/2,s_get_parm/1,s_mon_say/2,s_notic_bubl/3,s_send_usr_error_report/2,s_send_usr_error_report/3]).
-export([s_move_monster/2,s_monster_cast_skill/3,s_game_win/0,s_game_win/1,s_game_lose/0,s_game_lose/1,s_game_kick_all/0,s_game_over/0,s_game_usr_die/0,s_game_robot_die/2,s_set_copy_timer_len/1]).
-export([s_add_buff_to_monster/2,s_add_buff_to_all_monster/1,s_add_buff_to_all_usr/1,s_del_buff_to_all_usr/1,s_add_buff_to_camp_usr/4,s_del_buff_to_camp_usr/4,s_delay/1,s_delay_exe_fun/2]).
-export([s_add_timer/3,timer_call_back/1,s_find_point/2,s_rand_pick/1,s_get_monster_pos/1,s_get_monster_num/0,s_get_monster_num/1,s_get_monster_num_by_type/1]).
-export([s_task_dungeons_finish/1,s_get_risk_hero_step/1,s_set_scene_time_len/1,s_set_jb_mon/1,s_check_usr_robot_entourage/1]).
-export([s_send_error_report/1,s_send_error_report/2,s_kill_camp_monster/1,s_add_arena_start_time/0,set_usr_penta_kill/3]).
-export([s_get_camp_score/1,s_add_camp_score/2,s_add_usr_score/2,s_get_uids_by_ring/3,s_get_item_num_by_type/1,s_get_uids_by_camp/1,s_add_usr_kill_num/1,s_add_usr_kill_num/2,s_get_usr_war_data/1,process_war_result/3,s_notice_ready_time/1,
		 s_get_camp_war_data/1,s_get_war_reward_config/0,s_get_kill_rank/1,s_war_over/3,s_get_camp_by_oid/1,s_check_buff_by_uid/2,s_add_buff_by_uid/2,s_add_usr_speed/2,s_add_camp_prev/2,s_add_camp_cpl/2,s_change_all_camp/1,
		 s_reborn_usr/3,do_reborn_usr/1,s_del_buff_by_uid/2,s_get_turn_camp/1,s_get_warid/0,s_send_war_id/1,s_get_war_random_pos/0,s_get_usr_name/1,s_res_usr_ckill/1,s_add_usr_kill_type/2]).
-export([s_get_usrs/0,s_notice_reborn_time/2]).
-export([s_send_flag_count/2,s_send_flag_status/2,s_leader_die/2,s_small_boss_die/2,s_add_monster/10,s_add_monster/13,s_check_item/1,s_add_tag_point/3,s_usr_area_notice/2,s_get_scene_not_die_num/0]).
-export([s_usr_die_notice/1,s_get_curr_sys_time/0,s_transmit_to_pos/2,s_add_buff_to_camp_usr/2,s_del_buff_to_camp_usr/2,s_get_climb_tower_num/0,s_get_climb_tower_boss_num/0,s_set_climb_tower_boss_num/1]).
-export([s_check_scramble_time/0,s_scramble_add_camp_score/2,s_scramble_get_score/0,s_scramble_close/0,s_get_war_damage_rank/1,put_count_usr_demage/2,s_get_fighting/1,s_get_monster_survive_num/0]).
-export([init_team_copy/0,s_check_light_bath_time/0,s_transmit_to_pos/4,s_send_bslx/0]).

-export([s_pick_monster/2,s_pick_pos/3,s_get_scene_lev/0,s_clear_skill_cd/1]).
-export([s_full_role_hp_and_mp/1,s_is_atker_boss/1]).
-export([s_add_guild_copy_boss/3]).
-export([s_kill_all_monster_right_now/0]).
-export([s_get_pos_by_radius/2, s_quit_copy/0, s_add_buff_to_hero_by_uid/2]).
-export([s_get_copy_scene_time/1, s_usr_delay_reborn/2]).
-export([s_usr_wait_reborn/2,s_wait_reborn_usr/3]).
-export([s_get_usr_prof/1]).
-export([s_set_copy_len/1, s_send_copy_len/2, s_send_copy_progress/1,s_get_scene_lev/1,s_game_lose_single/2]).
-export([s_set_guild_copy_pregress/3,s_get_guild_copy_pregress/1,s_complex_arnea_win/1,s_usr_wait_reborn_new/3]).
-export([s_pick_usr_pos/2]).


s_set_copy_len(TimeLen) -> 
	put(scene_finish_time, util:unixtime() + TimeLen).

s_send_copy_len(Uid, EndTime) -> 
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		#scene_spirit_ex{data=#scene_usr_ex{sid = Sid}} -> 
			Pt=#pt_copy_exist_time{time_len = max(0, EndTime-util:unixtime())},
			?send(Sid, proto:pack(Pt));
		_ -> skip
	end.

s_get_scene_lev() -> mod_scene_lev:scene_get_scene_lev().

s_get_scene_lev(Uid) -> mod_scene_lev:get_curr_scene_lv(Uid).

rand_pick(Monsters,Num) ->
	rand_pick(Monsters,Num,[]).
rand_pick([],_Num,Gets) -> Gets;
rand_pick(_Monsters,0,Gets) -> Gets;
rand_pick(Monsters,Num,Gets) ->
	Monster = lists:nth(util:rand(1, erlang:length(Monsters)), Monsters),
	rand_pick(Monsters -- [Monster],Num - 1,[Monster | Gets]).

s_pick_monster(Boss,Lev) ->
	case Boss of
		true -> 
			case data_dungeons_config:get_dungeons(Lev) of
				#st_dungeons_config{bossId = BossID} -> [BossID];
				_ -> []
			end;
		_ -> 
			case data_dungeons_config:get_dungeons(Lev) of
				#st_dungeons_config{monsterId = Monsters} -> rand_pick(Monsters,util:get_data_para_num(1023));
				_ -> []
			end
	end.

s_pick_pos(_Boss,Lev,Nth) ->
	#st_dungeons_config{dungenScene = Scene} = data_dungeons_config:get_dungeons(Lev),
	#st_scene_config{mcoordinate=PosList} = data_scene_config:get_scene(Scene),
	{X, Z} = lists:nth(Nth, PosList),
	{X, 0, Z}.

s_pick_usr_pos(Lev,Nth) ->
	#st_dungeons_config{dungenScene = Scene} = data_dungeons_config:get_dungeons(Lev),
	#st_scene_config{coordinate=PosList} = data_scene_config:get_scene(Scene),
	{X, Z} = lists:nth(Nth, PosList),
	{X, 0, Z}.

s_send_flag_count(Count1,Count2) ->
	Pt = pt_flag_count_d305:new(),
	Pt1 = Pt#pt_flag_count{flag_count1 = Count1,flag_count2 = Count2,flag_count3 = 0},
	fun_scene_obj:send_all_usr(pt_flag_count_d305:to_binary(Pt1)).

s_send_flag_status(Camp,Status) ->
	Pt = pt_flag_status_d306:new(),
	Pt1 = Pt#pt_flag_status{flag_camp = Camp,flag_status = Status},
	fun_scene_obj:send_all_usr(pt_flag_status_d306:to_binary(Pt1)).

s_add_guild_copy_boss(Uid, Pos, Dir) ->
	#scene_spirit_ex{data=#scene_usr_ex{guild_id = GuildId}} = fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR),
	{BossId, BossMaxHp, BossHp} = fun_guild_boss:get_boss_hp(GuildId, get(scene)),
	s_add_monster(no,BossId,Pos,4,Dir,BossHp),
	?debug("BossHp:~p, BossId:~p", [BossHp, BossId]),
	{ok, BossId, BossMaxHp}.

s_add_monster(ID,Type,Pos,Camp,Dir,CurHp)->
	s_add_monster(ID,Type,Pos,Camp,Dir,CurHp,0).	
s_add_monster(ID,Type,Pos,Camp,Dir,CurHp,ReflushID)->
	s_add_monster(ID,Type,Pos,Camp,Dir,CurHp,ReflushID,0).
s_add_monster(ID,Type,Pos,Camp,Dir,CurHp,ReflushID,ConItemID)->
	s_add_monster(ID,Type,Pos,Camp,Dir,CurHp,ReflushID,ConItemID,0).
s_add_monster(ID,Type,Pos,Camp,Dir,CurHp,ReflushID,ConItemID,Master)->
	s_add_monster(ID,Type,Pos,Camp,Dir,CurHp,ReflushID,ConItemID,Master,0).
s_add_monster(ID,Type,Pos,Camp,Dir,CurHp,ReflushID,ConItemID,Master,Way)->
	s_add_monster(ID,Type,Pos,Camp,Dir,CurHp,ReflushID,ConItemID,Master,Way,0,0).
s_add_monster(ID,Type,Pos,Camp,Dir,CurHp,ReflushID,ConItemID,Master,Way,Atk,Def)->		
	s_add_monster(ID,Type,Pos,Camp,Dir,CurHp,ReflushID,ConItemID,Master,Way,Atk,Def,undefined).		
s_add_monster(ID,Type,Pos,Camp,Dir,CurHp,ReflushID,ConItemID,Master,Way,Atk,Def,Difficulty)->		
	NID = case ID of
			 no -> fun_scene_obj:get_obj_id();
			 _ -> %%fun_scene_obj:update_obj_id(ID),ID				
				 if
					 ID >= ?INSTANCE_OFF -> no;
					 true -> ID
				 end 	
		  end,
	case NID of
		no -> ?log_error("please check obj id~n"),skip;
		_ ->
			List = get(on_time),
			put(on_time,lists:append(List, [{add_monster,NID + ?OBJ_OFF,Type,Pos,Camp,Dir,CurHp,ReflushID,ConItemID,Master,Atk,Def,Difficulty}])),
			case fun_scene_obj:get_obj(Master, ?SPIRIT_SORT_USR) of
				Usr = #scene_spirit_ex{data=#scene_usr_ex{monster_list=MonsterList}} ->
					if Way == 1->
						   fun_scene_obj:update(fun_scene_obj:put_usr_spc_data(Usr,monster_list, lists:append(MonsterList, [{Way,NID + ?OBJ_OFF}])));
					   true->
						   fun_scene_obj:update(fun_scene_obj:put_usr_spc_data(Usr,monster_list, lists:append(MonsterList, [{0,NID + ?OBJ_OFF}])))
					end;
				_R->skip
			end
	end,	
	NID.
s_add_monster_ex(ID,Type,Pos,Camp,Dir,CurHp,Atk,Def) ->
	s_add_monster(ID,Type,Pos,Camp,Dir,CurHp,0,0,0,0,Atk,Def).
s_add_monster_by_mon(ID,Type,Camp,Dir,CurHp,MonID) ->
	case fun_scene_obj:get_obj(MonID+?OBJ_OFF, ?SPIRIT_SORT_MONSTER) of
		#scene_spirit_ex{pos={X,_Y,Z}} ->
			s_add_monster(ID,Type,{X+1,0,Z+1},Camp,Dir,CurHp);
		_ -> skip	
	end.
s_add_monster_by_mon_pos(ID,Type,Camp,Dir,CurHp,MonID) ->
	case fun_scene_obj:get_obj(MonID+?OBJ_OFF, ?SPIRIT_SORT_MONSTER) of
		#scene_spirit_ex{pos={X,_Y,Z}} ->
			s_add_monster(ID,Type,{X,0,Z},Camp,Dir,CurHp);
		_ -> skip	
	end.
s_add_monster_list_by_pos(IDList,Type,Pos,R,Camp,Dir,CurHp) ->
	Fun=fun(ID) ->
				case ID of
					no -> skip;
					_ ->	
						if
							ID >= ?INSTANCE_OFF -> ?log_error("s_add_monster_list_by_pos error config ID=~p~n",[ID]),skip;
							true ->
								case fun_scene_obj:get_obj(ID+?OBJ_OFF, ?SPIRIT_SORT_MONSTER) of
									#scene_spirit_ex{die=false} -> skip;
									_ ->
										RD = util:rand(0, R*1000),
										RA = util:rand(0, 360),
										VD = tool_vect:get_vect_by_dir(tool_vect:angle2radian(RA)),	
										RPos= tool_vect:add(tool_vect:to_map_point(Pos), tool_vect:ride(tool_vect:normal(VD), RD/1000)),
										case fun_scene_map:check_point(RPos) of	
											{true,_,#map_point{x = CX,y = CY,z = CZ}} ->								
												s_add_monster(ID,Type,{CX,CY,CZ},Camp,Dir,CurHp);
											_ -> ?log_trace("s_add_monster_list_by_pos,check_point false Type,Pos=~p",[{ID,Type,Pos}]),skip										
										end															
								end						 
						end 					
				end
		end,
	lists:foreach(Fun, IDList).	

%% 获取以Pos为圆点半径为Radius的圆内的一个随机点
s_get_pos_by_radius(Pos, Radius) ->
	RD = util:rand(0, Radius*1000),
	RA = util:rand(0, 360),
	VD = tool_vect:get_vect_by_dir(tool_vect:angle2radian(RA)),	
	RPos= tool_vect:add(tool_vect:to_map_point(Pos), tool_vect:ride(tool_vect:normal(VD), RD/1000)),
	tool_vect:to_point(RPos).


s_del_monster(ID)->%%此接口非脚本调用接口
	List = get(on_time),
	put(on_time,lists:append(List, [{del_monster,ID}])).
s_kill_monster(ID) ->
	List = get(on_time),
	put(on_time,lists:append(List, [{kill_monster,ID + ?OBJ_OFF}])).
s_kill_all_monster() ->
	List = get(on_time),
	put(on_time,lists:append(List, [{kill_all_monster}])).
s_kill_camp_monster(Camp) ->
	List = get(on_time),
	put(on_time,lists:append(List, [{kill_camp_monster,Camp}])).	

s_kill_all_monster_right_now() ->
	fun_monster:kill_all_monster().

s_add_scene_item(ID,Type,Dir,Pos) ->
	s_add_scene_item(ID,Type,Dir,Pos,0,0,0,0,0).
s_add_scene_item(ID,Type,Dir,Pos,HP,Camp,Length,High,Width)->
	NID = case ID of
			 no -> fun_scene_obj:get_obj_id();
			 _ ->%%fun_scene_obj:update_obj_id(ID),ID				 
				 if
					 ID >= ?INSTANCE_OFF -> no;
					 true -> ID
				 end 
		  end,
	case NID of
		no -> ?log_error("please check obj id~n"),skip;
		_ ->
			List = get(on_time),
			put(on_time,lists:append(List, [{add_scene_item,NID + ?OBJ_OFF,Type,Dir,Pos,HP,Camp,Length,High,Width}]))
	end,
	NID.
s_del_item(ID)->
	List = get(on_time),
	put(on_time,lists:append(List, [{del_item,ID + ?OBJ_OFF}])).
s_kill_item(ID) ->
	List = get(on_time),
	put(on_time,lists:append(List, [{kill_item,ID + ?OBJ_OFF}])).
s_get_scene_item(ID) ->
	fun_scene_obj:get_obj(ID + ?OBJ_OFF).

s_to_next_step() ->
	List = get(on_time),
	put(on_time,lists:append(List, [{next_step}])).

s_get_monster_die(ID) ->
	fun_scene_obj:get_monster_die(ID + ?OBJ_OFF).

s_get_monster_die(Data,Type) ->
	fun_scene_obj:get_monster_die(Data,Type).

s_set_parm(Name,Data) -> 
	case get("all_parm") of
		undefined -> put("all_parm",[Name]);
		List -> put("all_parm",(List -- [Name]) ++ [Name])
	end,
	put("parm_" ++ Name , Data).

s_get_parm(Name) -> get("parm_" ++ Name).

s_mon_say(MonID,SayID) ->
	UL=fun_scene_obj:get_ul(),
	[s_notic_bubl(Usr#scene_spirit_ex.id,MonID,SayID)|| Usr <- UL].

s_notic_bubl(Uid,TAG,ID)->
	List = get(on_time),
	put(on_time,lists:append(List, [{notic_bubl,Uid,TAG+?OBJ_OFF,ID}])).

s_monster_cast_skill(AtkMonID,SkillID,DefMonID) ->
	List = get(on_time),
	put(on_time,lists:append(List, [{monster_cast_skill,AtkMonID+?OBJ_OFF,SkillID,DefMonID+?OBJ_OFF}])).

s_move_monster(ID, Pos) ->
	List = get(on_time),
	put(on_time,lists:append(List, [{move_monster,ID + ?OBJ_OFF, Pos}])).

s_game_win()->
	s_game_win([]).
s_game_win(Args) ->
	List = get(on_time),
	put(on_time,lists:append(List, [{win, Args}])).

s_game_lose() ->
	List = get(on_time),
	put(on_time,lists:append(List, [{lose,false}])).
s_game_lose(AtkerIsBoss) ->
	List = get(on_time),
	put(on_time,lists:append(List, [{lose,AtkerIsBoss}])).

s_game_lose_single(Uid, Scene) ->
	List = get(on_time),
	put(on_time,lists:append(List, [{lose,Uid,Scene}])).

s_is_atker_boss(Oid) ->
	case fun_scene_obj:get_obj(Oid, ?SPIRIT_SORT_MONSTER) of
		#scene_spirit_ex{data = #scene_monster_ex{type = Type}} ->
			fun_monster:is_boss(Type);
		_ -> false
	end.

s_game_kick_all() ->
	List = get(on_time),
	put(on_time,lists:append(List, [{kick_all}])).

s_quit_copy() ->
	List = get(on_time),
	put(on_time,lists:append(List, [{quit_copy}])).

s_game_over() ->
	List = get(on_time),
	put(on_time,lists:append(List, [{game_over}])).

s_game_usr_die() ->
	List = get(on_time),
	put(on_time,lists:append(List, [{usr_die}])).

s_complex_arnea_win(Time) ->
	List = get(on_time),
	put(on_time,lists:append(List, [{complex_arnea_win, Time}])).

s_game_robot_die(AtkOid, Oid) ->
	List = get(on_time),
	put(on_time,lists:append(List, [{robot_die, AtkOid, Oid}])).

s_set_copy_timer_len(TimeLen) ->
	fun_scene:set_copy_timer_len(TimeLen).

s_add_buff_to_monster(ID,BuffType) ->
	List = get(on_time),
	put(on_time,lists:append(List, [{add_buff,ID+?OBJ_OFF,BuffType}])).

s_add_buff_to_all_monster(BuffType) ->
	List = get(on_time),
	put(on_time,lists:append(List, [{add_buff_to_all_monster,BuffType}])).	

s_add_buff_to_all_usr(BuffType) ->
	List = get(on_time),
	put(on_time,lists:append(List, [{add_buff_to_all_usr,BuffType}])).

s_del_buff_to_all_usr(BuffType) ->
	List = get(on_time),
	put(on_time,lists:append(List, [{del_buff_to_all_usr,BuffType}])).

s_add_buff_to_camp_usr(BuffType,Camp) ->
	List = get(on_time),
	put(on_time,lists:append(List, [{add_buff_to_camp_usr,BuffType,Camp}])).

s_add_buff_to_camp_usr(BuffType,Camp,UnionBuffNum,MonType) ->
	List = get(on_time),
	put(on_time,lists:append(List, [{add_buff_to_camp_usr,BuffType,Camp,UnionBuffNum,MonType}])).

s_del_buff_to_camp_usr(BuffType,Camp) ->
	List = get(on_time),
	put(on_time,lists:append(List, [{del_buff_to_camp_usr,BuffType,Camp}])).

s_del_buff_to_camp_usr(BuffType,Camp,UnionBuffNum,MonType) ->
	List = get(on_time),
	put(on_time,lists:append(List, [{del_buff_to_camp_usr,BuffType,Camp,UnionBuffNum,MonType}])).
s_add_partrol_point(ID,Points) ->
	 List = get(on_time),
	put(on_time,lists:append(List, [{add_partrol_point,ID + ?OBJ_OFF,Points}])).

s_delay(TimeLen) ->
	List = get(on_time),
	DelayTime = util:longunixtime() + TimeLen*1000,
	put(on_time, lists:append(List, [{delay, DelayTime}])).

%%FunInfo => {FunName, argnum}
s_delay_exe_fun(TimeLen,FunName) -> 
	case lists:member({FunName, 0}, ?MODULE:module_info(exports)) of
		true ->
			erlang:start_timer(TimeLen*1000, self(), {?MODULE, FunName});	
		_ -> skip	
	end.

s_add_timer(Name,TimeLen,Data) ->
	erlang:start_timer(TimeLen, self(), {?MODULE, timer_call_back,{Name,Data}}).
timer_call_back({Name,Data}) ->
	%%添加场景触发脚本 satan 2016.1.30
	fun_scene:run_scene_script(onTimer,[Name,Data]).

s_find_point(Pos,Dis) ->
	RD = util:rand(0, Dis*1000),
	RA = util:rand(0, 360),
	VD = tool_vect:get_vect_by_dir(tool_vect:angle2radian(RA)),	
	NewPos= tool_vect:add(tool_vect:to_map_point(Pos), tool_vect:ride(tool_vect:normal(VD), RD/1000)),
	tool_vect:to_point(NewPos).
s_rand_pick(List) ->
	Fun = fun({_Key,Val},CurAllVal) -> CurAllVal + Val end,
	AllVal = lists:foldl(Fun, 0, List),
	Rand = util:rand(0, AllVal - 1),
	pick_data(List,Rand).
pick_data([],_RandVal) -> no;
pick_data([{Key,Val} | Next],RandVal) -> 
	if
		RandVal < Val -> Key;
		true -> pick_data(Next,RandVal - Val)
	end.
s_get_monster_pos(ID) ->
	case fun_scene_obj:get_obj(ID + ?OBJ_OFF,?SPIRIT_SORT_MONSTER) of
		#scene_spirit_ex{pos = Pos} -> Pos;
		_ -> no
	end.

s_get_monster_num() -> erlang:length(fun_scene_obj:get_ml()).

s_get_monster_survive_num() -> 
	Fun = fun(#scene_spirit_ex{die=Die})->
				  case Die of 
					  false ->true;
					  _->false 
				  end 
		  end,	
	erlang:length(lists:filter(Fun,fun_scene_obj:get_ml())).
	
s_get_monster_num(TypeList) ->
	ML = fun_scene_obj:get_ml(),
	Fun = fun(#scene_spirit_ex{data=#scene_monster_ex{type = ThisType}}) ->
				  case lists:member(ThisType, TypeList) of
					  true -> true;
					  _ -> false
				  end
		  end,
	erlang:length(lists:filter(Fun, ML)).

s_get_monster_num_by_type(Type) ->
	ML = fun_scene_obj:get_ml(),
	Fun = fun(Data) ->
				  case Data of
					  #scene_spirit_ex{die=false,data=#scene_monster_ex{type=Type}} -> true;					
					  _ -> false
				  end
		  end,
	erlang:length(lists:filter(Fun, ML)).
	
s_task_dungeons_finish(_DelayTime) -> 
	UL=fun_scene_obj:get_ul(),
	Fun=fun(Usr) ->
			case Usr of
				#scene_spirit_ex{id=Uid,sort=?SPIRIT_SORT_USR} ->
					fun_scene:send_count_event(Uid, task_dungeons_finish, 0, get(scene), 1);
				_ -> skip
			end					
		end,
	lists:foreach(Fun, UL).
%% 	List = get(on_time),
%% 	put(on_time,lists:append(List, [{task_dungeons_finish,DelayTime}])).
	
s_add_arena_start_time() ->
	List = get(on_time),
	put(on_time,lists:append(List, [{arena_start_time,3}])).

s_get_usrs()->
	case fun_scene_obj:get_ul()of  
		Usrs  when  erlang:is_list(Usrs)->
			Fun=fun(#scene_spirit_ex{id=Id})-> Id end,
			lists:map(Fun, Usrs);
		_->[]
	end.

s_set_scene_time_len(TimeLen) ->
	Now=util:unixtime(),
	put(scene_finish_time,Now+TimeLen),
	List = get(on_time),
	put(on_time,lists:append(List, [{send_scene_finish_time}])).	

s_set_jb_mon(Num) ->
	List = get(on_time),
	put(on_time,lists:append(List, [{set_jb_mon,Num}])).

s_get_risk_hero_step(_Uid)->
	case  get(hero_challege_step)  of  
		{Step,_,_,_}->
			Step;
		_R->skip
	end.

s_send_bslx() ->
	Pt = pt_bslx_d311:new(),
	fun_scene_obj:send_all_usr(pt_bslx_d311:to_binary(Pt)).
	
s_send_usr_error_report(Uid,Code)->
	List = get(on_time),
	put(on_time,lists:append(List, [{s_send_usr_error_report,Uid,Code}])).

s_send_usr_error_report(Uid,Code,Data)->
	List = get(on_time),
	put(on_time,lists:append(List, [{s_send_usr_error_report,Uid,Code,Data}])).


s_send_error_report(Code) ->
	List = get(on_time),
	put(on_time,lists:append(List, [{send_error_report,Code}])).
s_send_error_report(Code,Data) ->
	List = get(on_time),
	put(on_time,lists:append(List, [{send_error_report,Code,Data}])).

s_check_usr_robot_entourage(Oid) when erlang:is_integer(Oid) ->
	case fun_scene_obj:get_obj(Oid) of
		no -> false;
		Obj -> s_check_usr_robot_entourage(Obj)
	end;
s_check_usr_robot_entourage(#scene_spirit_ex{sort = ?SPIRIT_SORT_USR}) -> true;
s_check_usr_robot_entourage(#scene_spirit_ex{sort = ?SPIRIT_SORT_ROBOT}) -> true;
s_check_usr_robot_entourage(#scene_spirit_ex{sort = ?SPIRIT_SORT_ENTOURAGE}) -> true;
s_check_usr_robot_entourage(_) -> false.
	
%%程序自己使用
set_usr_penta_kill(AtkOid,DefOid,DemageList) ->
	List = get(on_time),
	put(on_time,lists:append(List, [{set_usr_penta_kill,AtkOid,DefOid,DemageList}])).	






init_war_camp_data(#war_camp_data{}=Data)->
	put(war_camp_data,[Data]).

init_war_usr_data(#war_usr_data{}=Data)->
put(war_usr_data,[Data]).






s_get_camp_score(Camp)->
	case  get(war_camp_data) of 
		Datas when erlang:is_list(Datas)->
			case lists:keyfind(Camp, #war_camp_data.camp, Datas) of
				#war_camp_data{score=Score}->Score;
				_->0
			end;
	    _->0
	end.

s_add_camp_cpl(Camp,Cpl)->
%% 	?debug("!!!!!!!!!!!!!!!!~p",[{Camp,Cpl}]),
	
	case  get(war_camp_data) of  
		Datas when erlang:is_list(Datas)->
			
			NewDatas=case lists:keyfind(Camp, #war_camp_data.camp, Datas) of  
				#war_camp_data{cpl=OldCpl}=Old->
					
					lists:keystore(Camp, #war_camp_data.camp, Datas, Old#war_camp_data{cpl=OldCpl+Cpl});
				_->
					
					Datas++[#war_camp_data{camp=Camp,cpl=Cpl}]
			end,
			
			put(war_camp_data,NewDatas);
		_->
		   init_war_camp_data(#war_camp_data{camp=Camp,cpl=Cpl})
	end.
s_add_camp_prev(Camp,Prev)->
%% 	?debug("!!!!!!!!!!!!!!!!~p",[{Camp,Prev}]),
	case  get(war_camp_data) of  
		Datas when erlang:is_list(Datas)->
			
			NewDatas=case lists:keyfind(Camp, #war_camp_data.camp, Datas) of  
				#war_camp_data{prev=OldPrev}=Old->
					
					lists:keystore(Camp, #war_camp_data.camp, Datas, Old#war_camp_data{prev=OldPrev+Prev});
				_->
					
					Datas++[#war_camp_data{camp=Camp,prev=Prev}]
			end,
			
			put(war_camp_data,NewDatas);
		_->
		   init_war_camp_data(#war_camp_data{camp=Camp,prev=Prev})
	end.

s_add_camp_score(Camp,Score)->
	case  get(war_camp_data) of  
		Datas when erlang:is_list(Datas)->
			
			NewDatas=case lists:keyfind(Camp, #war_camp_data.camp, Datas) of  
				#war_camp_data{score=OldScore}=Old->
					
					lists:keyreplace(Camp, #war_camp_data.camp, Datas, Old#war_camp_data{score=OldScore+Score});
				_->
					
					Datas++[#war_camp_data{camp=Camp,score=Score}]
			end,
			
			put(war_camp_data,NewDatas);
		_->
		   init_war_camp_data(#war_camp_data{camp=Camp,score=Score})
	end,
	send_camp_war_report(Camp).

send_camp_war_report(Camp) ->
	List = get(on_time),
	put(on_time,lists:append(List, [{send_camp_war_report,Camp}])).
	
	
	

s_send_war_id(Uid)->
	List = get(on_time),
	put(on_time,lists:append(List, [{s_send_war_id,Uid}])).

send_person_war_report(Uid)->
	List = get(on_time),
	put(on_time,lists:append(List, [{send_person_war_report,Uid}])).



s_get_war_random_pos()->
	WarId=s_get_warid(),
	case data_war_config:get_data(WarId) of	
		#st_war_config{type= 2,randomBorn=RandomBorn} when  erlang:is_list(RandomBorn) andalso length(RandomBorn)>1-> 
			    Index=util:rand(1, length(RandomBorn)),
				lists:nth(Index, RandomBorn);
		#st_war_config{type= 3,randomBorn=RandomBorn} when  erlang:is_list(RandomBorn) andalso length(RandomBorn)>1-> 
			    Index=util:rand(1, length(RandomBorn)),
				lists:nth(Index, RandomBorn);
		_->{0,0,0}
		end.
s_add_usr_score(Uid,Score)->
case  get(war_usr_data) of  
		Datas when erlang:is_list(Datas)->
			NewDatas=case lists:keyfind(Uid, #war_usr_data.uid, Datas) of  
				#war_usr_data{score=OldScore}=Old->
					lists:keyreplace(Uid, #war_usr_data.uid, Datas, Old#war_usr_data{score=OldScore+Score});
				_->Datas++[#war_usr_data{uid=Uid,score=Score}]
			end,
			put(war_usr_data,NewDatas);
		_->init_war_usr_data(#war_usr_data{uid=Uid,score=Score})
	end,
send_person_war_report(Uid).


s_get_uids_by_ring({X,_Y,Z},MiniR,MaxR)->
	case fun_scene_obj:get_ul() of
        Ul when erlang:is_list(Ul)->
			Fun=fun(#scene_spirit_ex{id=Id,pos={CurrX,_,CurrZ},die=Die},Res)-> 
						Distance=tool_vect:get_distance({X,Z},{CurrX,CurrZ}),
						if  
							Distance<MaxR andalso  Distance>MiniR andalso Die == false->
								Res++[Id];
							true->Res
						end   	end,
			 lists:foldl(Fun, [], Ul);
		_->[]
    end.

s_get_item_num_by_type(Type)->
case fun_scene_obj:get_il() of  
	Il when  erlang:is_list(Il)->
		Fun=fun(#scene_spirit_ex{data=#scene_item_ex{type=CurrType}},Res)-> 
						if  
							CurrType==Type->
								Res+1;
							true->Res
						end   	end,
			 lists:foldl(Fun, 0, Il);
	_->0
end.

s_get_uids_by_camp(Camp)->
	case fun_scene_obj:get_ul() of
        Ul when erlang:is_list(Ul)->
			Fun=fun(#scene_spirit_ex{id=Id,camp=CurrCamp},Res)-> 
						if  
							CurrCamp==Camp ->
								Res++[Id];
							true->Res
						end   	end,
			 lists:foldl(Fun, [], Ul);
		_->[]
    end.
s_res_usr_ckill(Uid)->
	case get(war_usr_data) of  
		Datas when erlang:is_list(Datas)->
			case lists:keyfind(Uid, #war_usr_data.uid, Datas) of  
				#war_usr_data{}=Old->
					 put(war_usr_data,lists:keystore(Uid, #war_usr_data.uid, Datas, Old#war_usr_data{kadd=0}));
				_->skip
			end;
		_->skip
	end.

s_add_usr_kill_type(Uid,monster)->
case  get(war_usr_data) of  
		Datas when erlang:is_list(Datas)->
			NewDatas=case lists:keyfind(Uid, #war_usr_data.uid, Datas) of  
				#war_usr_data{km=OldKill}=Old->
			
					lists:keyreplace(Uid, #war_usr_data.uid, Datas, Old#war_usr_data{km=OldKill+1});
				_->Datas++[#war_usr_data{uid=Uid,km=1}]
			end,
			put(war_usr_data,NewDatas);
		_->init_war_usr_data(#war_usr_data{uid=Uid,km=1})
	end;
s_add_usr_kill_type(Uid,campter)->
case  get(war_usr_data) of  
		Datas when erlang:is_list(Datas)->
			NewDatas=case lists:keyfind(Uid, #war_usr_data.uid, Datas) of  
				#war_usr_data{kc=OldKill}=Old->
					lists:keyreplace(Uid, #war_usr_data.uid, Datas, Old#war_usr_data{kc=OldKill+1});
				_->Datas++[#war_usr_data{uid=Uid,kc=1}]
			end,
			put(war_usr_data,NewDatas);
		_->init_war_usr_data(#war_usr_data{uid=Uid,kc=1})
	end;
s_add_usr_kill_type(Uid,usr)->
case  get(war_usr_data) of  
		Datas when erlang:is_list(Datas)->
			NewDatas=case lists:keyfind(Uid, #war_usr_data.uid, Datas) of  
				#war_usr_data{ku=OldKill}=Old->
					lists:keyreplace(Uid, #war_usr_data.uid, Datas, Old#war_usr_data{ku=OldKill+1});
				_->Datas++[#war_usr_data{uid=Uid,ku=1}]
			end,
			put(war_usr_data,NewDatas);
		_->init_war_usr_data(#war_usr_data{uid=Uid,ku=1})
	end;
s_add_usr_kill_type(_,_)->ok.


s_add_usr_kill_num(Uid) -> s_add_usr_kill_num(Uid,true).
s_add_usr_kill_num(Uid,Send)->
	case  get(war_usr_data) of  
		Datas when erlang:is_list(Datas)->
			NewDatas=case lists:keyfind(Uid, #war_usr_data.uid, Datas) of  
						 #war_usr_data{kills=OldKills,kadd=Kadd,continuekill=Ckill}=Old->
							 {NewAdd,NewCKill}=if  
												   Kadd+1>Ckill->{Kadd+1,Kadd+1};
												   true->{Kadd+1,Ckill}
											   end,
							 lists:keystore(Uid, #war_usr_data.uid, Datas, Old#war_usr_data{kills=OldKills+1,continuekill=NewCKill,kadd=NewAdd});
						 _->Datas++[#war_usr_data{uid=Uid,kills=1,continuekill=1,kadd=1}]
					 end,
			put(war_usr_data,NewDatas);
		_->init_war_usr_data(#war_usr_data{uid=Uid,kills=1,continuekill=1,kadd=1})
	end,
	if
		Send == true ->
			send_person_war_report(Uid);
		true -> skip
	end.


s_get_usr_war_data(Uid)->
	case  get(war_usr_data) of  
		Datas when erlang:is_list(Datas)->
			case lists:keyfind(Uid, #war_usr_data.uid, Datas) of  
				#war_usr_data{}=Old->Old;
				_->#war_usr_data{}
			end;
		_->#war_usr_data{}
	end.

s_usr_wait_reborn_new(Uid, Secs, Type) ->
	#st_scene_config{points = PointList} = data_scene_config:get_scene(get(scene)),
	Pos = hd(PointList),
	s_wait_reborn_usr_new(Uid,Pos,Secs,Type).

s_wait_reborn_usr_new(Uid,Pos,Time,Type) ->
	List = get(on_time),
	put(on_time,lists:append(List, [{s_wait_reborn_usr_new,Uid,Pos,Time,Type}])).

s_usr_wait_reborn(Uid, Secs) ->
	#st_scene_config{points = PointList} = data_scene_config:get_scene(get(scene)),
	Pos = hd(PointList),
	s_wait_reborn_usr(Uid,Pos,Secs).

s_wait_reborn_usr(Uid,Pos,Time) ->
	List = get(on_time),
	put(on_time,lists:append(List, [{s_wait_reborn_usr,Uid,Pos,Time}])).

%% 等待复活，Secs为等待的秒数
s_usr_delay_reborn(Uid, Secs) ->
	#st_scene_config{points = PointList} = data_scene_config:get_scene(get(scene)),
	Pos = hd(PointList),
	s_reborn_usr(Uid,Pos,Secs).

s_reborn_usr(Uid,Pos,Time)->
	List = get(on_time),
	put(on_time,lists:append(List, [{s_reborn_usr,Uid,Pos,Time}])).

do_reborn_usr({Uid,{X,Y,Z}})->
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR)	 of  
		#scene_spirit_ex{die=true}=Old->
			Hp = 100,
			
			Point =tool_vect:to_map_point({X,Y,Z}),
			{NX,NY,NZ} = case fun_scene_map:check_point(Point) of
					   {true,_,YPoint} -> tool_vect:to_point(YPoint);
					   _ -> {X,Y,Z}
				   end,
			fun_scene_obj:update(fun_scene_buff:add_buff(Old#scene_spirit_ex{die=false,pos={NX,NY,NZ},hp=Hp}, 70001, Uid)),
			Pt = #pt_revive{
				revive_uid  = Uid,
				revive_sort = ?REVIVE_SORT_TWO,
				x 			= NX,
				y 			= NY,
				z 			= NZ
			},	
			fun_scene_obj:send_all_usr(proto:pack(Pt), 0),
%% 			?debug("do_reborn_usr,Hp = ~p",[Hp]),
			Bin = fun_property:make_property_pt(Uid, [{?PROPERTY_HP,Hp},{?PROPERTY_HPLIMIT,Hp}]),
			fun_scene_obj:send_all_usr(Bin);
		_R->skip
	end.

s_change_all_camp(Camp)->
	List = get(on_time),
	put(on_time,lists:append(List, [{s_change_all_camp,Camp}])).

s_get_usr_name(Uid)->
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		#scene_spirit_ex{name=Name} ->
			Name;
		_ -> ""
	end.

s_notice_reborn_time(Uid,Time)->
%% ?debug("!!!!!!!!!!"),
	List = get(on_time),
	put(on_time,lists:append(List, [{s_notice_reborn_time,Uid,Time}])).

s_notice_ready_time(Time)->
%% 	?debug("!!!!!!!!!!"),
	List = get(on_time),
	put(on_time,lists:append(List, [{arena_start_time,Time}])).

s_get_camp_war_data(Camp)->
	case  get(war_camp_data) of  
		Datas when erlang:is_list(Datas)->
			_NewDatas=case lists:keyfind(Camp, #war_camp_data.camp, Datas) of  
				#war_camp_data{}=Old->Old;
				_->#war_camp_data{}
			end;
		_->#war_camp_data{}
	end.

s_get_warid()->
	case get(scene) of 
		Scene when  erlang:is_integer(Scene)->
			case data_war_config:select(Scene) of  
				[War] ->War;
				_->0
			end;
		_->0
	end.


s_get_war_reward_config()->
	case get(scene) of 
		Scene when  erlang:is_integer(Scene)->
			case data_war_config:select(Scene) of  
                [War] ->
					case  data_war_config:get_data(War)  of  
						  #st_war_config{win= Win,lose= Lose,base= Base,kill= Kill}->
							  case {Base,Kill}  of  
								{{_BI,_BN},{_KI,_KN}}->{Win,Lose,Base,Kill};
								{{_BI,_BN},_} ->{Win,Lose,Base,{0,0}};
								{_,{_KI,_KN}}->{Win,Lose,{0,0},Kill};
								_->  {Win,Lose,{0,0},{0,0}}
							  end;
                          _R->error
		            end;
                _R->error
		  end;
      _R->error
	 end.

s_get_turn_camp(Camp)->
	case Camp  of  
		11->12;
		_->11
	end.


s_add_usr_speed(Uid,Speed)->
case  get(war_usr_data) of  
		Datas when erlang:is_list(Datas)->
			NewDatas=case lists:keyfind(Uid, #war_usr_data.uid, Datas) of  
				#war_usr_data{speed=_OldSpeed}=Old->lists:keystore(Uid, #war_usr_data.uid, Datas, Old#war_usr_data{speed=Speed});
				_->Datas++[#war_usr_data{uid=Uid,speed=Speed}]
			end,
			put(war_usr_data,NewDatas);
		_->init_war_usr_data(#war_usr_data{uid=Uid,speed=Speed})
	end.


s_get_kill_rank(Uid)->
	case  get(war_usr_data) of  
		 Datas when erlang:is_list(Datas)->
			List=lists:reverse(lists:keysort(#war_usr_data.kills, Datas)),
			Fun=fun(#war_usr_data{uid=CurrUid})->CurrUid end,
			case get_index(lists:map(Fun, List), Uid, 1) of  
				Rank when erlang:is_number(Rank)->Rank;
				_->0
			end;
		 _->0
    end.
get_index([],_Key,_Res)->no;
get_index([H|D],Key,Res)->
	if  
		H==Key->Res;
		true->get_index(D, Key, Res+1)
	end.

	

%% {Cpl,Rrev,Kill,Rank,ContinueKill,Score,Km,Ku,Kc}

s_war_over(Sort,WarID,Datas)->
%% 	?debug("!!!!!!!!!!!!~p",[{Sort,Datas}]),
	List = get(on_time),
	put(on_time,lists:append(List, [{game_over,Sort,WarID,Datas}])).

process_war_result(person,WarID,Datas)->
%% 	?debug("!!!!!!!!!!!!"),
	Fun=fun({Uid,Drops,Items,Kill,Rank,ContinueKill,Score})->
	fun_scene_obj:agent_msg_by_uid(Uid,{war_result,WarID,?EQUALLY,Drops,Items,{Kill,Rank,ContinueKill,Score}})end,
	lists:foreach(Fun, Datas);

process_war_result(team_war_win,WarID,Datas)->
	Fun=fun({Uid,Drops,RankReward,Rank})->
	fun_scene_obj:agent_msg_by_uid(Uid,{team_war_result,WarID,?WIN,Drops,RankReward,Rank}) end,
	lists:foreach(Fun, Datas);

process_war_result(team_war_lose,WarID,Datas)->
	Fun=fun({Uid,Drops,RankReward,Rank})->
	fun_scene_obj:agent_msg_by_uid(Uid,{team_war_result,WarID,?LOSE,Drops,RankReward,Rank}) end,
	lists:foreach(Fun, Datas);

process_war_result(normal_war_win,WarID,Datas)->
	Fun=fun({Uid,Drops})->
	fun_scene_obj:agent_msg_by_uid(Uid,{normal_war_result,WarID,?WIN,Drops}) end,
	lists:foreach(Fun, Datas);

process_war_result(normal_war_lose,WarID,Datas)->
	Fun=fun({Uid,Drops})->
	fun_scene_obj:agent_msg_by_uid(Uid,{normal_war_result,WarID,?LOSE,Drops}) end,
	lists:foreach(Fun, Datas);	

process_war_result(camp,WarID,[{Camp2,Drops2,Items2},{Camp3,Drops3,Items3}])->
%% 	?debug("!!!!!!!!!!!!data=~p",[[{Camp2,Drops2,Items2},{Camp3,Drops3,Items3}]]),
	Camp2s=s_get_uids_by_camp(Camp2),
%% 	?debug("!!!!!!!!!!!!,Camp2s=~p",[Camp2s]),
	#war_camp_data{cpl=Cpl2,prev=Rrev2}=s_get_camp_war_data(Camp2),
	Camp3s=s_get_uids_by_camp(Camp3),
%% 	?debug("!!!!!!!!!!!!,Camp3s=~p",[Camp3s]),
	#war_camp_data{cpl=Cpl3,prev=Rrev3}=s_get_camp_war_data(Camp3),
	Fun2=fun(Uid)-> 
				 	#war_usr_data{kills=Kill,km=Km,ku=Ku,kc=Kc}=s_get_usr_war_data(Uid),
				fun_scene_obj:agent_msg_by_uid(Uid,{war_result,WarID,?WIN,Drops2,Items2,{Cpl2,Rrev2,Km,Ku,Kc,Kill}})
				end,
	lists:foreach(Fun2, Camp2s),
	Fun3=fun(Uid)-> 
				#war_usr_data{kills=Kill,km=Km,ku=Ku,kc=Kc}=s_get_usr_war_data(Uid),
				fun_scene_obj:agent_msg_by_uid(Uid,{war_result,WarID,?LOSE,Drops3,Items3,{Cpl3,Rrev3,Km,Ku,Kc,Kill}})
				end,
	lists:foreach(Fun3, Camp3s).

s_get_camp_by_oid(Oid)->
case fun_scene_obj:get_obj(Oid)  of  
	#scene_spirit_ex{camp=Camp}->Camp;
	_->0
end.
s_check_buff_by_uid(Uid,BuffType)->
case fun_scene_obj:get_obj(Uid,?SPIRIT_SORT_USR)  of  
	#scene_spirit_ex{buffs=Buffs}->
		case lists:keyfind(BuffType, #scene_buff.type, Buffs) of  
			 false->false;
			 _->true
		end;
	_->0
end.
s_add_tag_point(Uid,del,_Point)->
	List = get(on_time),
	put(on_time,lists:append(List, [{s_add_tag_point,Uid,{0,0,0}}]));
s_add_tag_point(Uid,add,Point)->
	List = get(on_time),
	put(on_time,lists:append(List, [{s_add_tag_point,Uid,Point}])).
s_add_buff_by_uid(Uid,BuffType)->
	List = get(on_time),
	put(on_time,lists:append(List, [{s_add_buff_by_uid,Uid,BuffType}])).
s_add_buff_to_hero_by_uid(Uid,BuffType)->
	List = get(on_time),
	put(on_time,lists:append(List, [{s_add_buff_to_hero_by_uid,Uid,BuffType}])).

s_del_buff_by_uid(Uid,BuffType)->	
	List = get(on_time),
	put(on_time,lists:append(List, [{s_del_buff_by_uid,Uid,BuffType}])).

s_leader_die(Uid,AtkOid) ->
	case fun_scene_obj:get_obj(Uid) of
		#scene_spirit_ex{camp=Camp,data=#scene_usr_ex{camp_leader=1}} ->		
			DefCamp=0,
			?debug("Camp=~p,DefCamp=~p",[Camp,DefCamp]),
			AtkName=case fun_scene_obj:get_obj(AtkOid) of
						#scene_spirit_ex{name=Name} -> Name;	
						_ -> ""
					end,			
			if
				DefCamp == Camp ->
					fun_scene:broadcast_to_scene(speaker_msg,[util:to_list(334),util:to_list(AtkName)]);	
				true ->
					fun_scene:broadcast_to_scene(speaker_msg,[util:to_list(317),util:to_list(AtkName)])
			end;	
		_ -> skip
	end.

s_small_boss_die(Type,DefCamp) ->
	case data_monster:get_monster(Type) of
		#st_monster_config{name=Name} ->
			AtkCamp=get_opposite_camp(DefCamp),
			fun_scene:broadcast_to_scene(camp_speaker_msg,{AtkCamp,[util:to_list(319),util:to_list(Name)]}),
			fun_scene:broadcast_to_scene(camp_speaker_msg,{DefCamp,[util:to_list(318),util:to_list(Name)]});	
		_ -> skip
	end.
get_opposite_camp(Camp) ->
	if
		Camp == ?CAMP_UNION -> ?CAMP_TRIBE;
		true -> ?CAMP_UNION
	end.
	
s_get_scene_not_die_num()->
	case fun_scene_obj:get_ul()of  
		Usrs  when  erlang:is_list(Usrs)->
			length(lists:map(fun(#scene_spirit_ex{id=Id,die=?FALSE})-> Id end, Usrs));
		_->0
	end.

	
s_check_item(ID)->
case  fun_scene_obj:get_obj(ID + ?OBJ_OFF, ?SPIRIT_SORT_ITEM)  of  
      #scene_spirit_ex{}->true;
	  _->false
end.

s_usr_area_notice(Uid,Area)->
	List = get(on_time),
	put(on_time,lists:append(List, [{s_usr_area_notice,Uid,Area}])).

s_usr_die_notice(_Uid) ->
	fun_interface:s_game_lose().
	% List = get(on_time),
	% put(on_time,lists:append(List, [{s_usr_die_notice,Uid}])).	
%%添加争夺战阵营积分
s_scramble_add_camp_score(Camp,Score)->
	if Camp == 2 orelse Camp ==3 ->
			case s_check_scramble_time() of
				true->
					NewScoreList = 
						case get(scramble_camp_score) of
							?UNDEFINED->
								[{Camp,Score}];
							List->
								case lists:keyfind(Camp, 1, List) of
									{_,OldScore}->
										lists:keyreplace(Camp, 1, List, {Camp,Score+OldScore});
									_->
										lists:append(List, [{Camp,Score}])
								end
						end,
					put(scramble_camp_score,NewScoreList),
						Fun = fun({OldCamp,OldScore},{Two,Three})->
									  if OldCamp == 2->
											 {Two+OldScore,Three};
										 true->
											 {Two,Three+OldScore}
									  end
							  end,
					NewScore = lists:foldl(Fun,{0,0},NewScoreList),
					?debug("---------NewScore=~p,NewScoreList=~p",[NewScore,NewScoreList]),
					{TwoScore,ThreeScore} = NewScore,
					Pt = pt_scramble_info_d182:new(),
					Pt1 = Pt#pt_scramble_info{camp_two_score = TwoScore,camp_three_score = ThreeScore},
					Fun1=fun(Usr) ->
								case Usr of
									#scene_spirit_ex{sort=?SPIRIT_SORT_USR,data=#scene_usr_ex{sid=Sid}} ->
										?send(Sid,pt_scramble_info_d182:to_binary(Pt1));
									_ -> skip
								end					
						end,
					lists:foreach(Fun1, fun_scene_obj:get_ul());
				_->skip
			end;
		true->skip
	end.
s_scramble_get_score()->
	case get(scramble_camp_score) of
		?UNDEFINED->[];
		List->List
	end.
%%检查国王战场争夺战时间
s_check_scramble_time()->
	case data_event:get_data(1) of
		#st_event_confg{opentime=[OpenTimeH,OpenTimeM],endtime=[EndTimeH,EndTimeM]}->
			{_Year,_Month,_Day,Hour, Minite,_Second}  = util:get_unixtime_date(),
			(Hour > OpenTimeH orelse  (Hour == OpenTimeH andalso Minite >= OpenTimeM)) andalso ((Hour == EndTimeH andalso Minite =< EndTimeM) orelse(Hour < EndTimeH) );
		_->false
	end.
s_scramble_close()-> skip.
						   
s_get_curr_sys_time() ->
	Now=util:unixtime(),
	{_,{H,M,_S}}=util:unix_to_localtime(Now),
	{H,M}.	
					
s_transmit_to_pos(Uid,Pos) ->
	List = get(on_time),
	put(on_time,lists:append(List, [{s_transmit_to_pos,Uid,Pos}])).
s_transmit_to_pos(Uid,Pos,Seq,State) ->
	List = get(on_time),
	put(on_time,lists:append(List, [{s_transmit_to_pos,Uid,Pos,Seq,State}])).
s_get_war_damage_rank(Uid)-> 
	DemageList=case get(war_boss_demage) of
				   undefined -> [];
				   List when is_list(List) -> List;
				   _ -> ?log_error("add_war_damage_data error"),[]	
			   end,	
	FunSort=fun({_,D1},{_,D2}) -> D1 =< D2 end,
	NewDemageList=lists:reverse(lists:sort(FunSort, DemageList)),	
	get_rank(Uid,NewDemageList,0).

get_rank(_Uid,[],Rank) -> Rank;
get_rank(Uid,[{Oid,_}|Next],Rank) ->
	if
		Uid == Oid -> Rank+1;
		true -> get_rank(Uid,Next,Rank+1)
	end.


	
put_count_usr_demage(Uid,SceneType)->
	if SceneType == 101023->
		   case s_check_scramble_time() of
			   true->
				   case get(count_usr_demage_scramble) of
					   ?UNDEFINED->
						   put(count_usr_demage_scramble,[Uid]);
					   UsrList->
						   case lists:member(Uid, UsrList) of
							   true->skip;
							   _->
								   Lists = lists:append(UsrList, [Uid]),
								   put(count_usr_demage_scramble,Lists)
						   end
				   end;
			   _->skip
		   end;
	   true->skip
	end.

s_get_fighting(Oid)->
	case fun_scene_obj:get_obj(Oid) of
		#scene_spirit_ex{sort = ?SPIRIT_SORT_USR, data=#scene_usr_ex{fighting=Fighting}} -> 
			Fighting;
		#scene_spirit_ex{sort = ?SPIRIT_SORT_ENTOURAGE, data=#scene_entourage_ex{owner_id=OwnerId}} -> 
			case fun_scene_obj:get_obj(OwnerId) of
				#scene_spirit_ex{sort = ?SPIRIT_SORT_ROBOT, data=#scene_robot_ex{fighting=Fighting}} ->
					Fighting;
				#scene_spirit_ex{sort = ?SPIRIT_SORT_USR, data=#scene_usr_ex{fighting=Fighting}} ->
					Fighting;
				_ -> 0
			end;
		#scene_spirit_ex{sort = ?SPIRIT_SORT_ROBOT, data=#scene_robot_ex{fighting=Fighting}} -> 
			Fighting;
			
		_->0
	end.

s_get_climb_tower_num() -> get(climb_tower_layer).

s_get_climb_tower_boss_num() -> get(climb_tower_boss_num).
s_set_climb_tower_boss_num(Uid) ->
	List = get(on_time),
	put(on_time,lists:append(List, [{set_climb_tower_add_boss_num,Uid}])).	

init_team_copy()->
	case get(scene_info) of
		{guild_team,_,_,WaveNumber}->
			case get(guild_team_copy) of
				?UNDEFINED ->
					put(guild_team_copy,WaveNumber);
				_->skip
			end;
		_->skip
	end.

%%检查沐浴圣光双倍开始时间
s_check_light_bath_time()->
	{_Year,_Month,_Day,Hour, Minite,_Second}  = util:get_unixtime_date(),
	StartTime =  util:get_data_para_num(921) ,
	EndTime = util:get_data_para_num(922) ,
	StartHour = StartTime div 100,
	StartMinte = StartTime rem 100,
	EndHour = EndTime div 100,
	EndMinte = EndTime rem 100,
	((Hour >= StartHour) andalso (Minite >= StartMinte)) andalso ((Hour < EndHour) orelse ((Hour == EndHour) andalso (Minite =< EndMinte))).

s_clear_skill_cd(Uid) ->
	List = get(on_time),
	put(on_time,lists:append(List, [{clear_skill_cd,Uid}])).	

s_full_role_hp_and_mp(Uid) ->
	List = get(on_time),
	put(on_time,lists:append(List, [{full_role_hp_and_mp,Uid}])).	


%% 返回秒数
s_get_copy_scene_time(_Scene) -> 60.

%% 返回场景内玩家职业
s_get_usr_prof(Uid) ->
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		Obj = #scene_spirit_ex{} -> fun_scene_obj:get_usr_spc_data(Obj, prof);
		_ -> 0
	end.

%% 公会副本进度
s_send_copy_progress(Progress) ->
	fun_scene:set_copy_progress(Progress).

s_set_guild_copy_pregress(Wave, Progress, _ScenePid) ->
	case get(key) of
		{guild_copy,GuildId,Scene} ->
			mod_msg:handle_to_agnetmng(fun_guild_copy_progress, {set_guild_copy_progress, Wave, Progress, GuildId, Scene});
		_ -> skip
	end.

s_get_guild_copy_pregress(_ScenePid) ->
	case get(key) of
		{guild_copy,GuildId,Scene} ->
			fun_guild_copy_progress:get_guildcopy_progress(GuildId,Scene);
		_ -> {0,{}}
	end.