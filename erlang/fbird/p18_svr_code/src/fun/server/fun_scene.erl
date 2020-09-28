-module(fun_scene).
-include("common.hrl").
   
-export([on_init/0,on_scene_loaded/2,on_scene_reloaded/2,on_close/1,on_usr_login/5,on_usr_logout/2,do_time/2,do_msg/1,add_alive_buff/2,add_say_notify/1]).
-export([pick_move_data/1,get_move_time/4,get_player_config_pace_speed/1,get_mon_config_speed/1,get_mon_config_pace_speed/1,get_entourage_config_pace_speed/1,
		 move_player/2,move_monster/2,move_entourage/2,do_module_script/2,monster_skill/5]).
-export([on_save_pos/1,guild_copy/2,copy_scene_lose_player/0,s_guild_copy/2]).
-export([s_get_hp_mp_by_uid/1,get_copy_timer_len/0,set_copy_timer_len/1,copy_out_decision/2,run_scene_script/2,broadcast_to_scene/2,
		 get_guild_copy_rewards/1,s_get_usr_lev/1,robot_skill/5,robot_move/2,delete_personage_boss/1,
		 robot_entourage_skill/4,move_robot_entourage/2,get_load_succeed/1,send_count_event/5,delete_monster_list/1]).
-export([is_all_monster_die/0,set_copy_progress/1,get_script_module/0,get_copy_progress/0]).
-export([turn_off_scene_loop/0, get_time/0, s_get_usr_legendary_lev/1]).
-export([robot_enter_scene/5, robot_enter_scene/6, usr_skill/7]).

on_init()-> 
	fun_scene_obj:init(),
	fun_scene_map:init(),
	fun_scene_skill:init(),
	fun_interface:init_team_copy(),
	ok.

on_scene_loaded(SceneModel,Scene) -> 
	put(scene_model,SceneModel),
	
	put(on_time,[]),
	
	do_module_script(on_create,[Scene]),
	ok.

on_scene_reloaded(_SceneModel,Scene) ->
	%%put(scene_model,SceneModel),	
	put(on_time,[]),	
	do_module_script(on_create,[Scene,restart]),
	ok.	

on_close(Scene) -> 
	do_module_script(on_stop,[Scene]),
	ok.

%% 场景进程内的当前时间
get_time() -> 
	erlang:get(scene_dict_time).

do_time(Scene,Now) -> 
	put(scene_dict_time, Now),
	case is_scene_loop_open() of
		true -> 
			proc_do_time(Now),

			All = fun_scene_obj:get_all_ids(),
			Fun = fun(ID) ->
				case fun_scene_obj:get_obj(ID) of
					Obj when erlang:is_record(Obj, scene_spirit_ex) ->
						onTimer(Obj,Now,Scene);
					_ -> skip
				end
			end,
			[Fun(ID) || ID <- All],
			fun_scene_arrow:onTimer(Now);
		_ -> skip
	end,
	ok.

turn_off_scene_loop() ->
	erlang:put(stop_scene_loop, true).

is_scene_loop_open() -> 
	erlang:get(stop_scene_loop) /= true.


proc_do_time(Now) ->
	case get(on_time) of
		[] -> [];
		Timer ->
			put(on_time,[]),
			Rest = proc_on_time(Timer, Now),
			Next = get(on_time),
			put(on_time, Rest ++ Next),
			Rest
	end. 

onTimer(Obj,Now,Scene) ->
 	Obj1 = do_module_script(onTimer,[Obj,Now,Scene]),
	Obj2 = fun_scene_spirit_on_timer:onTimer(Obj1, Now, Scene),
	fun_scene_obj:update(Obj2),
	ok.

do_all_on_time(Event) ->
	case do_script_on_time(Event) of		
		continue -> do_on_time(Event);
		_ -> skip
	end.
do_script_on_time(Event)-> do_module_script(do_on_time,[Event]).
do_on_time(Event) -> fun_scene_on_time:do_on_time(Event).

proc_on_time([], _Now) -> [];
proc_on_time([{delay, Time} | Next], Now) ->
	if
		Now >= Time ->
			proc_on_time(Next, Now);
		true ->
			[{delay, Time} | Next]
	end;
proc_on_time([Event = {next_step} | Next], Now) ->
	do_all_on_time(Event),
	OnTime = get(on_time),
	put(on_time,[]),
	proc_on_time(Next ++ OnTime, Now);
proc_on_time([Event | Next], Now) ->
	do_all_on_time(Event),
	proc_on_time(Next, Now);
proc_on_time(Data,_) -> ?log_error("proc_on_time error data=~p",[Data]),[].


get_next_cast_check_time(Oid) ->
	case get({next_cast_check_time, Oid}) of
		undefined -> 0;
		T -> T
	end.

set_next_cast_check_time(Oid, SkillType, LongNow) ->
	case data_skillperformance:get_skillperformance(SkillType) of
		#st_skillperformance_config{time_yz= Yz} ->
			%% 好像是有误杀，不知道是不是前端的计算有问题，给个误差允许
			put({next_cast_check_time, Oid}, Yz + LongNow - 200);
		_ -> skip
	end.

% add_cheat_times(Uid, Sid) ->
% 	Now = util_time:unixtime(),
% 	case get({cheat_times, Uid}) of
% 		undefined -> put({cheat_times, Uid}, {1, Now});
% 		{T, Time} ->
% 			T2 = T + 1,
% 			if 
% 				T2 >= 8 andalso Now =< Time + 60 -> %% 从计数时算起，一分钟内有10次作弊
% 					erase({cheat_times, Uid}),
% 					?error_report(Sid, "kick_out_the_game"),
% 					?discon(Sid, cheat, 1000),
% 					?log_error("~p request cast skill too fast, kick him", [Uid]);
% 				Now > Time + 60 -> %% 一分钟后重置作弊计数
% 					put({cheat_times, Uid}, {1, Now});
% 				true ->
% 					put({cheat_times, Uid}, {T+1, Time})
% 			end
% 	end.

%% {{Usr,AgentHid,Pos,BattleProperty},

%%on_usr_login(Uid,Sid,BackpackIsFull,Fighting,Drop_drums_time,Equip_list,TaskList,UsrSkillList,PetList,TeamInfo,{{Usr,AgentHid,Pos,BattleProperty},_EnterSceneData}) ->
on_usr_login(Uid,Sid,LoginDataSet,#enter_scene_data{usr=Usr,pro=BattleProperty,a_hid=AgentHid,pos=Pos,h_c_data=_H_C_Data,last_buffs=Buffs,curr_members=Curr_Members}=_EnterSceneData,Seq) ->
	BackpackIsFull=LoginDataSet#login_data_set.isfull,Fighting=LoginDataSet#login_data_set.fighting,Drop_drums_time=LoginDataSet#login_data_set.drop_time,
	Equip_list=LoginDataSet#login_data_set.equip_list,TaskList=LoginDataSet#login_data_set.task_list,UsrSkillList=LoginDataSet#login_data_set.skill_list,
	PetList=LoginDataSet#login_data_set.pet_list,TeamInfo=LoginDataSet#login_data_set.team_info,PassiveSkillList=LoginDataSet#login_data_set.passive_skill,
	ReviveTimes=LoginDataSet#login_data_set.revive_times,
	% CopyTimesList=LoginDataSet#login_data_set.copy_times,
	GuildName=LoginDataSet#login_data_set.guild_name,GuildId=LoginDataSet#login_data_set.guild_id,
	Ride=LoginDataSet#login_data_set.ride_info,Military=LoginDataSet#login_data_set.military,VipLev = LoginDataSet#login_data_set.vip_lev,Paragon_level = LoginDataSet#login_data_set.paragon_level,
	ModelClothes = LoginDataSet#login_data_set.model_clothes,CampOffice = LoginDataSet#login_data_set.camp_leader,Title_id = LoginDataSet#login_data_set.title_id,
	RoyalBoxFull = LoginDataSet#login_data_set.isroyalboxfull,InscriptionEffects = LoginDataSet#login_data_set.inscription_effects,TowerLayer= LoginDataSet#login_data_set.tower_layer,
	ClimbTowerBossNum= LoginDataSet#login_data_set.climb_tower_boss_num,BoosDieList = LoginDataSet#login_data_set.boos_die_list,
	put(climb_tower_layer,TowerLayer),
	put(climb_tower_boss_num,ClimbTowerBossNum),
	{TeamID,LeaderID} = case TeamInfo of 
		{GetTeamID,GetLeaderID} -> {GetTeamID,GetLeaderID};
		_ -> {0,0}
	end,	
	NPos = case fun_scene_map:check_point(tool_vect:to_map_point(Pos)) of
		{true,_,YPoint} -> tool_vect:to_point(YPoint);
		_ -> Pos
	end,

	case fun_scene_obj:get_obj(Uid,?SPIRIT_SORT_USR)  of  
		#scene_spirit_ex{data =#scene_usr_ex{curr_members=_ReconnData}= UsrData}=OldUsr->
	        Pte = #pt_scene_info{scene = get(scene),camp = OldUsr#scene_spirit_ex.camp},
	        ?send(Sid,proto:pack(Pte, Seq)),
			NewUsr = fun_scene_obj:update(OldUsr#scene_spirit_ex{off_line=?FALSE,data = UsrData#scene_usr_ex{hid = AgentHid,sid = Sid}}),
			%%我要看到场景中的其他人
			fun_scene_map:process_recon(NewUsr),
			send_reconn_buff(NewUsr);
		_->
	        Pte = #pt_scene_info{scene = get(scene),camp = Usr#usr.camp },
	        ?send(Sid,proto:pack(Pte, Seq)),
			MakeUsr=#scene_spirit_ex{
				id = Usr#usr.id,name = Usr#usr.name,camp=Usr#usr.camp,
				dir = 180,pos=NPos,base_property = BattleProperty,final_property = BattleProperty,
				passive_skill_data=PassiveSkillList,hp=Usr#usr.hp,
					 data=#scene_usr_ex{
					 	inscription_effects=InscriptionEffects,
					 	fighting=Fighting,drop_drums_time = Drop_drums_time,
					 	equip_list=Equip_list,task_list=TaskList,ride=Ride,
					 	military_lev=Military,curr_members=Curr_Members,
						pet_list=PetList,skill_list=UsrSkillList,hid = AgentHid,
						sid = Sid,lev=Usr#usr.lev,prof=Usr#usr.prof,team_id = TeamID,
						guild_name=GuildName,guild_id=GuildId,
						team_leader = LeaderID,
						backpack_is_full = BackpackIsFull,revive_times=ReviveTimes,
						% copy_times=NewCopyTimesList,
						royal_box_full=RoyalBoxFull,
						paragon_level=Paragon_level,model_clothes=ModelClothes,
						vip=VipLev,camp_leader=CampOffice,title_id=Title_id,
						boos_die_list=BoosDieList,
						barrier_id = LoginDataSet#login_data_set.barrier_id,
						relife = LoginDataSet#login_data_set.relife
			}},
		
			AliveHp=fun_property:check_hp(Usr#usr.hp,BattleProperty),
			AliveMp=fun_property:check_mp(Usr#usr.mp,BattleProperty),

			{CurrHp,CurrMp} = 
				case  data_scene_config:get_scene(get(scene)) of
					#st_scene_config{sort=?SCENE_SORT_COPY}->
						MaxHp = BattleProperty#battle_property.hpLimit,
						MaxMp = BattleProperty#battle_property.mpLimit,
						{MaxHp,MaxMp};
					_->
						{AliveHp,AliveMp}
				end,
			#scene_spirit_ex{hp=NewHp,pos=NewPos} = MakeUsr,
			case NewPos of
				{X,_,Z}->
					if
						NewHp == 0 ->
							Pt=#pt_revive{
								revive_uid = Uid,
								revive_sort = ?REVIVE_SORT_THR,
								x = X,
								y = 0,
								z = Z
							},
							fun_scene_obj:send_all_usr(proto:pack(Pt), 0);
						true -> skip
					end;
				_ -> skip
			end,
			fun_scene_obj:agentmng_msg(AgentHid,{update_hp,Uid,CurrHp,get(scene_info)}),
			AddUsr=fun_scene_obj:add_usr(MakeUsr#scene_spirit_ex{hp=CurrHp,mp=CurrMp},MakeUsr#scene_spirit_ex.data),
			send_alive_buff(AddUsr, Buffs),

			SceneUsrIDs = [SceneUsr#scene_spirit_ex.id  || SceneUsr <- fun_scene_obj:get_ul()],
			%%添加场景触发脚本 satan 2016.1.30
			fun_scene:run_scene_script(onUsrEnter,[Uid,Pos,SceneUsrIDs]),			
						  
			% send_count_event(Uid, join_scene, 0, get(scene), 1),
			case data_scene_config:get_scene(get(scene)) of
				#st_scene_config{sort = ?SCENE_SORT_WAR} ->
					case data_war_config:select(get(scene)) of
						[WarId|_]->
							case fun_scene_obj:get_obj(Uid,?SPIRIT_SORT_USR)  of  
								#scene_spirit_ex{data =#scene_usr_ex{hid=AgentHid}}->
									fun_scene_obj:agentmng_msg(AgentHid, {war_activity,Uid, WarId, util:unixtime()});
								_->skip
							end;
%% 							fun_dataCount_update:war_activity(Uid, WarId, util:unixtime());
						_->skip
					end,
					send_count_event(Uid, task_many_activities, 0,0, 1);
				_->skip
			end
	end,
	case get(global) of
		scene -> fun_scene_obj:agent_msg(AgentHid, {upadate_scene_hid,get(scene), {global,self()}});
		_ -> fun_scene_obj:agent_msg(AgentHid, {upadate_scene_hid,get(scene), self()})
	end,
	% fun_scene_obj:on_pet_enter(Uid, PetList),
	add_scene_pet_buff(Usr#usr.id),%%pet add buff
	send_scene_finish_time(Uid),
	fun_scene_event:handle_scene_event(usr_enter_scene, Uid),
	ok.


send_scene_finish_time(Uid) ->
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		#scene_spirit_ex{data=#scene_usr_ex{sid=Sid}} ->
			Now=scene:get_scene_now(),
			case get(scene_finish_time) of
				undefined -> skip;
				Val ->
					if
						Now < Val ->
							Pt=#pt_copy_exist_time{time_len = Val-Now},
							?send(Sid,proto:pack(Pt));
						true -> skip
					end
			end;
		_ -> skip
	end.


do_leave_scene(BattleEntourage,Uid,AgentHid,CurrBuffs)->
	% ?debug("BattleEntourage=~p",[BattleEntourage]),
	if
		length(BattleEntourage) > 0 ->
			Fun = fun(EntourageType) ->
				erlang:erase({last_move_pt, EntourageType}), 
				fun_scene_obj:remove_obj(EntourageType)
			end,
			lists:foreach(Fun, BattleEntourage);
		true -> skip
	end,
	fun_scene_obj:remove_obj(Uid),
	case get(global) of
		scene -> 
			fun_scene_obj:agentmng_msg(AgentHid, {save_buffs,Uid,CurrBuffs}),
			fun_scene_obj:agent_msg(AgentHid,{upadate_scene_hid,0,no});
		_ ->
			fun_scene_obj:agentmng_msg(AgentHid, {save_buffs,Uid,CurrBuffs}),
			fun_scene_obj:agent_msg(AgentHid, {upadate_scene_hid,0,no})
%% 			gen_server:cast({global,agent_mng}, {save_buffs,Uid,CurrBuffs}),
%% 			gen_server:cast(AgentHid, {upadate_scene_hid,0,no})
	end.
	

% del_scene_pet(Uid,PetList)->
% 	Fun=fun({PetID,_PetType}) ->
% 			fun_scene_obj:on_pet_leave(Uid, PetID)
% 		end,
% 	lists:foreach(Fun, PetList).



on_usr_logout(Uid,ActionSort) ->
	erlang:erase({last_move_pt, Uid}),
	?debug("on_usr_logout---ActionSort=~p",[ActionSort]),
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		#scene_spirit_ex{pos = {X,Y,Z},hp = CurHp,mp = CurMp,buffs=CurrBuffs,data = #scene_usr_ex{hid = AgentHid,battle_entourage = BattleEntourage,pet_list=_PetList}}=Usr ->
			fun_scene_event:handle_scene_event(usr_out_scene, Uid),
			% del_scene_pet(Uid,PetList),
			case ActionSort of
				logout ->					
					usr_logout_operate(Uid),
					case data_scene_config:get_scene(get(scene)) of
						#st_scene_config{sort=?SCENE_SORT_COPY,id=ID} when  ID=/=?HERO_CHALLEGE  ->
							do_leave_scene(BattleEntourage, Uid, AgentHid, CurrBuffs),
							if
								CurHp > 0 -> skip;
								true ->
									fun_scene_obj:agentmng_msg(AgentHid, {logout_save, Uid, util:to_list(get(scene)) ++ "," ++ util:to_list(X) ++ "," ++ util:to_list(Y) ++ "," ++ util:to_list(Z),CurHp,CurMp})	
							end;
						#st_scene_config{sort=?SCENE_SORT_WAR}->
							do_leave_scene(BattleEntourage, Uid, AgentHid, CurrBuffs),
							if
								CurHp > 0 -> skip;
								true ->
									fun_scene_obj:agentmng_msg(AgentHid, {logout_save, Uid, util:to_list(get(scene)) ++ "," ++ util:to_list(X) ++ "," ++ util:to_list(Y) ++ "," ++ util:to_list(Z),CurHp,CurMp})	
							end;
						#st_scene_config{sort=Sort} when Sort == ?SCENE_SORT_COPY; Sort == ?SCENE_SORT_WORLDBOSS; Sort == ?SCENE_SORT_LIMITBOSS ->
							
							do_leave_scene(BattleEntourage, Uid, AgentHid, CurrBuffs),
							fun_scene_obj:agentmng_msg(AgentHid, {logout_save, Uid, util:to_list(get(scene)) ++ "," ++ util:to_list(X) ++ "," ++ util:to_list(Y) ++ "," ++ util:to_list(Z),CurHp,CurMp,self()});
						#st_scene_config{sort=?SCENE_SORT_CITY}->
							do_leave_scene(BattleEntourage, Uid, AgentHid, CurrBuffs),
							fun_scene_obj:agentmng_msg(AgentHid, {logout_save, Uid, util:to_list(get(scene)) ++ "," ++ util:to_list(X) ++ "," ++ util:to_list(Y) ++ "," ++ util:to_list(Z)});
						#st_scene_config{sort=Sort}->
							do_leave_scene(BattleEntourage, Uid, AgentHid, CurrBuffs),
							if
								Sort == ?SCENE_SORT_CAMP orelse Sort == ?SCENE_SORT_PEACE orelse Sort == ?SCENE_SORT_SCUFFLE ->
									fun_scene_obj:agentmng_msg(AgentHid, {logout_save, Uid, util:to_list(get(scene)) ++ "," ++ util:to_list(X) ++ "," ++ util:to_list(Y) ++ "," ++ util:to_list(Z),CurHp,CurMp});																			
								true -> skip
							end;
						_ -> skip
					end;
				_ -> %%scene_out
					fun_scene_buff:del_buff_by_chg_map(Usr),
					usr_logout_scene(Uid),
					case  data_scene_config:get_scene(get(scene)) of
						#st_scene_config{sort=?SCENE_SORT_CITY}->
							fun_scene_obj:agentmng_msg(AgentHid,  {logout_save,Uid, util:to_list(get(scene)) ++ "," ++ util:to_list(X) ++ "," ++ util:to_list(Y) ++ "," ++ util:to_list(Z)});
						#st_scene_config{sort=Sort} when Sort == ?SCENE_SORT_COPY; Sort == ?SCENE_SORT_WORLDBOSS; Sort == ?SCENE_SORT_LIMITBOSS ->
							leave_temp_teams(Uid);
						#st_scene_config{sort=?SCENE_SORT_WAR}->
							leave_temp_teams(Uid);
						#st_scene_config{sort=Sort}->
							if
								Sort == ?SCENE_SORT_CAMP orelse Sort == ?SCENE_SORT_PEACE orelse Sort == ?SCENE_SORT_SCUFFLE ->
									fun_scene_obj:agentmng_msg(AgentHid,  {logout_save, Uid,util:to_list(get(scene)) ++ "," ++ util:to_list(X) ++ "," ++ util:to_list(Y) ++ "," ++ util:to_list(Z),CurHp,CurMp});																			
								true -> skip
							end;
						_ -> skip
					end,
					do_leave_scene(BattleEntourage, Uid, AgentHid, CurrBuffs)
			end;
		_ -> skip
	end.
on_save_pos(Uid) ->
	Scene=get(scene),
	case data_scene_config:get_scene(Scene) of
		#st_scene_config{sort = ?SCENE_SORT_WAR} ->skip;
		#st_scene_config{sort = ?SCENE_SORT_NATIONAL_WAR} ->skip;
		_ ->
			case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
				#scene_spirit_ex{pos = {X,Y,Z},data = #scene_usr_ex{hid = AgentHid}} ->	
					fun_scene_obj:agent_msg(AgentHid,  {curr_pos_save, util:to_list(Scene) ++ "," ++ util:to_list(X) ++ "," ++ util:to_list(Y) ++ "," ++ util:to_list(Z)});
				_ ->skip
			end			
	end.

%%宠物添加buff
add_scene_pet_buff(_Uid) ->
	ok.

do_msg({handle_msg,Module,Msg}) -> Module:handle(Msg);
do_msg({revive_in_place, Uid, _Sid}) ->
	?debug("revive_in_place ~p",[Uid]),
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		#scene_spirit_ex{pos=Pos} ->
			fun_interface:do_reborn_usr({Uid, Pos});
		_ -> skip
	end;
do_msg({revive_not_place, _Uid, _Scene}) ->
	fun_scene_copy:do_on_time({lose, true});
do_msg({reconn_time_out,Uid}) ->
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		#scene_spirit_ex{buffs=CurrBuffs,data = #scene_usr_ex{hid = AgentHid,battle_entourage = BattleEntourage}} ->
			
			do_leave_scene(BattleEntourage, Uid, AgentHid, CurrBuffs),
			fun_scene_obj:scenemng_msg({scene_chg_num,get(id),erlang:length(fun_scene_obj:get_ul())});
		_->skip
	end;
do_msg({contiue_hero_challege}) ->
	fun_scene:run_scene_script(onServerEvent,[start_next_tower]);

do_msg({update_team_info, Uid, Members}) ->
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		#scene_spirit_ex{data=Usr_ex}=Usr ->
			fun_scene_obj:update(Usr#scene_spirit_ex{data=Usr_ex#scene_usr_ex{team_info=Members}});
		_ -> skip
	end;	
%% 穿装备等行为影响战斗属性的时候调用这个函
do_msg({chg_battle_property, Uid, BattleProperty}) ->
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		Usr = #scene_spirit_ex{} -> 
%% 			这里应该考虑属性变化，血量改变等
			fun_scene_obj:update(Usr#scene_spirit_ex{final_property = BattleProperty});
		_ -> skip
	end;
do_msg({recv, Sid,Uid, {Name,Seq,Pt}}) ->
%% 	?debug("Pt = ~p",[Pt]),
	process_pt(Name,Seq,Pt,Sid,Uid);

do_msg({add_scene_pet,Uid,PetID,PetType}) -> 
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		#scene_spirit_ex{die = true} -> skip;
		Usr=#scene_spirit_ex{} ->			
			fun_scene_obj:on_pet_enter(Uid, [{PetID,PetType}]),			
			fun_scene_obj:update(fun_scene_obj:put_usr_spc_data(Usr,pet_list,[{PetID,PetType}]));
		_ -> skip
	end;

do_msg({del_scene_pet,Uid,PetID}) -> 
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		#scene_spirit_ex{die = true} -> skip;
		Usr=#scene_spirit_ex{} ->			
			fun_scene_obj:on_pet_leave(Uid, PetID),			
			fun_scene_obj:update(fun_scene_obj:put_usr_spc_data(Usr,pet_list,[]));
		_ -> skip
	end;
do_msg({check_buff, Uid,Data,BuffType}) -> 
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		#scene_spirit_ex{die = true} -> skip;
		#scene_spirit_ex{buffs=Buffs,data=#scene_usr_ex{hid=AgentHid}} ->
			case lists:keyfind(BuffType, #scene_buff.type, Buffs) of
				#scene_buff{}->fun_scene_obj:agent_msg(AgentHid, {check_buff,Uid,Data,BuffType,false});
				_->fun_scene_obj:agent_msg(AgentHid, {check_buff,Uid,Data,BuffType,true})
			end;
		_ -> skip
	end;										  
do_msg({add_buff,Uid,Type}) -> 
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		#scene_spirit_ex{die = true} -> skip;
		Usr = #scene_spirit_ex{} ->
			fun_scene_obj:update(fun_scene_buff:add_buff(Usr, Type, Uid));
		_ -> skip
	end;
do_msg({add_buff,Uid,Type,Power,Time,Adder}) -> 
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		#scene_spirit_ex{die = true} -> skip;
		Usr = #scene_spirit_ex{} ->
			fun_scene_obj:update(fun_scene_buff:add_buff(Usr, Type, Power,Time,Adder));
		_ -> skip
	end;

do_msg({add_buff_list,Uid,BuffList}) ->
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		#scene_spirit_ex{die = true} -> skip;
		Usr = #scene_spirit_ex{} ->
			Fun=fun(Type,RetUsr) ->
					fun_scene_buff:add_buff(RetUsr, Type, Uid)		
				end,
			NewUsr=lists:foldl(Fun, Usr, BuffList),			
			fun_scene_obj:update(NewUsr);
		_ -> skip
	end;

do_msg({del_buff_list,Uid,BuffList}) ->
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		#scene_spirit_ex{die = true} -> skip;
		Usr = #scene_spirit_ex{} ->
			Fun=fun(Type,RetUsr) ->					
					fun_scene_buff:del_buff_by_type(RetUsr, Type)
				end,
			NewUsr=lists:foldl(Fun, Usr, BuffList),			
			fun_scene_obj:update(NewUsr);			
		_ -> skip
	end;

do_msg({add_guild_inspire_buff,Uid,Add_Multiple}) ->
	fun_guild_copy:add_guild_inspire_buff(Uid,Add_Multiple);


do_msg({gm_add_buff,Uid,Type,true}) -> 
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		#scene_spirit_ex{die = true} -> skip;
		Usr = #scene_spirit_ex{} ->
			fun_scene_obj:update(fun_scene_buff:add_buff(Usr, Type, Uid));
		_ -> skip
	end;
do_msg({gm_add_buff,Uid,Type,_}) -> 
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		Usr = #scene_spirit_ex{} ->
			case fun_scene_obj:get_obj(fun_scene_obj:get_usr_spc_data(Usr, target)) of
				#scene_spirit_ex{die = true} -> skip;
				Obj = #scene_spirit_ex{} ->
					fun_scene_obj:update(fun_scene_buff:add_buff(Obj, Type, Uid));
				_ -> skip
			end;
		_ -> skip
	end;
do_msg({gm_add_buff,Uid,Type,Power,Time,true}) -> 
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		#scene_spirit_ex{die = true} -> skip;
		Usr = #scene_spirit_ex{} ->
			fun_scene_obj:update(fun_scene_buff:add_buff(Usr, Type,Power,Time, Uid));
		_ -> skip
	end;
do_msg({gm_add_buff,Uid,Type,Power,Time,_}) -> 
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		Usr = #scene_spirit_ex{} ->
			case fun_scene_obj:get_obj(fun_scene_obj:get_usr_spc_data(Usr, target)) of
				#scene_spirit_ex{die = true} -> skip;
				Obj = #scene_spirit_ex{} ->
					fun_scene_obj:update(fun_scene_buff:add_buff(Obj, Type,Power,Time, Uid));
				_ -> skip
			end;
		_ -> skip
	end;
do_msg({gm_add_buff,Uid,Type,Power,Time,Skill,Lev,true}) -> 
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		#scene_spirit_ex{die = true} -> skip;
		Usr = #scene_spirit_ex{} ->
			fun_scene_obj:update(fun_scene_buff:add_buff(Usr, Type,Power,Time, Uid,{Skill,Lev}));
		_ -> skip
	end;
do_msg({gm_add_buff,Uid,Type,Power,Time,Skill,Lev,_}) -> 
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		Usr = #scene_spirit_ex{} ->
			case fun_scene_obj:get_obj(fun_scene_obj:get_usr_spc_data(Usr, target)) of
				#scene_spirit_ex{die = true} -> skip;
				Obj = #scene_spirit_ex{} ->
					fun_scene_obj:update(fun_scene_buff:add_buff(Obj, Type,Power,Time, Uid,{Skill,Lev}));
				_ -> skip
			end;
		_ -> skip
	end;
 
do_msg({gm_add_monster,Uid,Type}) -> 
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		_Usr = #scene_spirit_ex{pos = Pos,dir = Dir} ->
			case data_monster:get_monster(Type) of
		 		#st_monster_config{} ->
					fun_interface:s_add_monster(no, Type, Pos, ?CAMP_MONSTER_DEFAULT, Dir, 0);
				_ -> 
%% 					?debug("gm add monster no monster,Type = ~p",[Type]),
					skip
			end;
		_ -> skip
	end;
do_msg({delay_add_buff,Oid,Type,Power,Time,Adder,FromSkill}) -> 
	case fun_scene_obj:get_obj(Oid) of
		Obj = #scene_spirit_ex{die=Die} when Die=/=true->
			fun_scene_obj:update(fun_scene_buff:now_add_buff(Obj, Type, Power, Time, Adder, FromSkill));
		_ -> skip
	end;


do_msg({gm_set_passive_skill,Uid,Skill}) -> 
%% 	?debug("gm_set_passive_skill,data = ~p",[{Uid,Skill}]),
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		Usr = #scene_spirit_ex{} ->
			fun_scene_obj:update(Usr#scene_spirit_ex{passive_skill_data = [Skill]});
		_ -> skip
	end;

do_msg({update_hero_skill,Oid,NormalSkills,PassiveSkillList}) ->
	case fun_scene_obj:get_obj(Oid) of
		Obj=#scene_spirit_ex{data = Detail} ->
			Obj2 = Obj#scene_spirit_ex{
				passive_skill_data=PassiveSkillList,
				data = Detail#scene_entourage_ex{skills=NormalSkills}
			},
			fun_scene_obj:update(Obj2);
		_ -> skip
	end;
do_msg({update_fighting,Uid,Fighting}) ->
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		Usr=#scene_spirit_ex{} ->
%% 			?debug("do_msg update_fighting PropData=~p~n",[Fighting]),
			fun_scene_obj:update(fun_scene_obj:put_usr_spc_data(Usr, fighting, Fighting)),
			send_fighting(Uid,Fighting);
		_ -> skip
	end;
do_msg({update_lev,Uid,Lev}) ->
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		Usr=#scene_spirit_ex{} ->
			fun_scene_obj:update(fun_scene_obj:put_usr_spc_data(Usr, lev, Lev)),
			send_usr_lev(Uid,Lev);
		_ -> skip
	end;
do_msg({update_paragon_level,Uid,Lev,Exp})->
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		Usr=#scene_spirit_ex{} ->
			fun_scene_obj:update(fun_scene_obj:put_usr_spc_data(Usr, paragon_level, Lev)),  
			send_paragon_level(Uid,Lev,Exp);
		_ -> skip
	end;
do_msg({update_copy_inspire,Uid,Lev,Type})->
	fun_scene_inspire:update_inspire_lv(Uid,Lev,Type);

do_msg({update_relife,Uid,ReLife})->
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		Usr=#scene_spirit_ex{} ->
			fun_scene_obj:update(fun_scene_obj:put_usr_spc_data(Usr, relife, ReLife));
		_ -> skip
	end;
	
do_msg({update_model_clothes,Uid,Lev})->
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		Usr=#scene_spirit_ex{} ->
			fun_scene_obj:update(fun_scene_obj:put_usr_spc_data(Usr, model_clothes, Lev));
		_ -> skip
	end;


do_msg({update_vip_lev,Uid,Lev,Exp})->
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		Usr=#scene_spirit_ex{} ->
			Object = fun_scene_obj:put_usr_spc_data(Usr,vip,Lev),
			fun_scene_obj:update(Object),
			send_vip_level(Uid,Lev,Exp),
			Pt=#pt_update_scene_usr_data{
				uid = Uid,
				sort = 4,
				idata = Lev
			},
%% 			?debug("update_military,Military=~p~n",[Military]),
			fun_scene_obj:send_cell_all_usr(Usr,proto:pack(Pt),Uid);
		_-> skip	
	end;

do_msg({update_backpack_is_full,Uid,BackpackIsFull})->
%% 	?debug("do_msg update_backpack_is_full BackpackIsFull=~p~n",[BackpackIsFull]),
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		Usr=#scene_spirit_ex{} ->
			fun_scene_obj:update(fun_scene_obj:put_usr_spc_data(Usr, backpack_is_full, BackpackIsFull));
		_ -> skip
	end;
do_msg({sync_property_to_scene, Uid, Key, Val})->
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		Usr=#scene_spirit_ex{} ->
			fun_scene_obj:update(fun_scene_obj:put_usr_spc_data(Usr, Key, Val));
		_ -> skip
	end;

do_msg({update_user_skill,Uid,SkillList}) ->
	% ?debug("~p update_user_skill to: ~p", [Uid,SkillList]),
	fun_scene_cd:update_user_skill(Uid, SkillList);
	
do_msg({update_task_list,Uid,Accpt_Task_List}) ->
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		Usr=#scene_spirit_ex{} ->
%% 			?debug("do_msg accpt_task_list Accpt_Task_List=~p~n",[Accpt_Task_List]),
			fun_scene_obj:update(fun_scene_obj:put_usr_spc_data(Usr, task_list, Accpt_Task_List));	
		_ -> skip
	end;
do_msg({send_all_usr,Uid,Data}) ->
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		#scene_spirit_ex{}=Usr->
			fun_scene_obj:send_cell_all_usr(Usr,Data);
		_ -> skip
	end;
do_msg({updata_drop_drums_time,Uid,Time}) ->
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		Usr=#scene_spirit_ex{} ->
			fun_scene_obj:update(fun_scene_obj:put_usr_spc_data(Usr,drop_drums_time, Time));	
		_ -> skip
	end;
do_msg({update_curr_members,Uid,Team,Members}) ->
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		Usr=#scene_spirit_ex{data = UsrData} ->
			fun_scene_obj:update(Usr#scene_spirit_ex{data = UsrData#scene_usr_ex{curr_members={Team,Members}}});	
		_ -> skip
	end;

do_msg({match_copy_save_pos,Uid}) ->
	on_save_pos(Uid);

do_msg({enter_arena_save_pos,Uid}) ->
	on_save_pos(Uid);

do_msg({add_archeology_enemy, _Uid,Pos,Dir,ArcheologyEnemy}) ->
%% 	?debug("----------Uid,Pos,Dir,ArcheologyEnemy=~p",[{Uid,Pos,Dir,ArcheologyEnemy}]),
    {X,Y,Z} = Pos,
	lists:foreach(fun(Type) ->fun_interface:s_add_monster(no, Type, {X+1,Y+1,Z+1}, 4, Dir-180, 0) end, ArcheologyEnemy);
	

do_msg({get_usr_x_y_z,OSid,Sid,Uid,Oid,SceneType,AgentHid,Seq}) ->
	case fun_scene_obj:get_obj(Oid, ?SPIRIT_SORT_USR) of
		#scene_spirit_ex{pos = Pos} ->
			fun_scene_obj:agent_msg(AgentHid, {usr_x_y_z,OSid,Sid,Uid,Oid,SceneType,Pos,Seq});
%% 					gen_server:cast(AgentHid, {usr_x_y_z,OSid,Sid,Uid,Oid,SceneType,Pos,Seq});
		_-> skip	
	end;

do_msg({kick_all_usr}) -> 
	?debug("kick_all_usr"),
	lists:foreach(fun(#scene_spirit_ex{id=Uid})-> do_msg({kick_usr, Uid}) end, fun_scene_obj:get_ul());
do_msg({kick_usr, Uid}) ->
	%% 挂机游戏直接退出到关卡
	?debug("kick_usr, Uid:~p", [Uid]),
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		#scene_spirit_ex{data = #scene_usr_ex{hid = AgentHid}} ->
			mod_msg:handle_to_agent(AgentHid, mod_scene_lev, copy_out);
		_ -> 
			?ERROR("kick usr ~p but not find obj record, quit maybe wrong", [Uid])
	end;

do_msg({get_scene_pos,Sid,Uid,ArchaeologyType,Seq}) ->
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		#scene_spirit_ex{pos = Pos,dir=Dir,data = #scene_usr_ex{hid = AgentHid}} ->
%% 			?debug("--------get_scene_pos-------"),
				fun_scene_obj:agent_msg(AgentHid,{scene_pos,Sid,Uid,Pos,Dir,ArchaeologyType,Seq});
%% 					gen_server:cast(AgentHid, {scene_pos,Sid,Uid,Pos,Dir,ArchaeologyType,Seq});
		_-> skip	
	end;

do_msg({put_guild_copy_ml_hp,{MLHP}})->
	put(guild_copy_ml_hp,MLHP);
do_msg({update_equip_list,Uid,EquipList})->
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		Usr=#scene_spirit_ex{} ->
			Object = fun_scene_obj:put_usr_spc_data(Usr,equip_list,EquipList),  
			fun_scene_obj:update(Object);
		_->skip
	end;
do_msg({out_fight,_Uid})-> skip;

do_msg({task_add_buff,Uid,BuffId})->
	case fun_scene_obj:get_obj(Uid,?SPIRIT_SORT_USR) of
		Obj=#scene_spirit_ex{} ->
			%%fun_scene_buff:add_buff(Obj, BuffId, Uid);
			fun_scene_obj:update(fun_scene_buff:add_buff(Obj, BuffId, Uid));
		_->skip
	end;
do_msg({dart_add_monster,Uid,MonsterId,_,Pos})->
	case data_monster:get_monster(MonsterId) of
		#st_monster_config{}->
			fun_interface:s_add_monster(no,MonsterId,Pos,?CAMP_MONSTER_DEFAULT,180,0,0,0,Uid);
		_->skip
	end;
do_msg({abandon_dart,Uid})->
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		Usr = #scene_spirit_ex{data=#scene_usr_ex{monster_list=MonsterList}} ->
			fun_scene_obj:update(fun_scene_obj:put_usr_spc_data(Usr,monster_list,lists:keydelete(0, 1, MonsterList))),
			delete_monster_list({Uid,2,MonsterList});
		_->skip
	end;

do_msg({del_move_sand_buff, Uid,BuffId})->
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		Usr=#scene_spirit_ex{} ->
			fun_scene_obj:update(fun_scene_buff:del_buff_by_type(Usr, BuffId));
		_->skip
	end;		
			
do_msg({out_stuck,Uid})->
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		#scene_spirit_ex{data=#scene_usr_ex{sid=Sid,hid=AgentHid}} ->
			SceneId = get(scene),
			case data_scene_config:get_scene(SceneId) of
				#st_scene_config{points = PointList}->
					fun_scene_obj:agentmng_msg(AgentHid, {fly, Sid,Uid,0,{SceneId,hd(PointList)}});
				_->skip
			end;
		_->skip
	end;

do_msg({update_name, Uid, Name})->
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		Usr=#scene_spirit_ex{} ->
			fun_scene_obj:update(Usr#scene_spirit_ex{name=Name}),
			Pt=#pt_update_scene_usr_data{
				uid = Uid,
				sort = 5,
				sdata = Name
			},
			fun_scene_obj:send_cell_all_usr(Usr,proto:pack(Pt),Uid),
			send_name(Uid, Name);
		_->skip
	end;

do_msg({scramble_activity_star,_SceneType})->
	?log_trace("------scramble_activity_star-----"),
	put(scramble_camp_score,[]),
	Moudle = get_script_module(),	
	try
		Moudle:star_event(),
		case get(global) of
			scene ->skip;
			_->
				gen_server:cast({global,agent_mng}, {scramble_activity,true})
		end
	catch _E:_R -> ?log_error("ai error Moudle=~p",[Moudle]),{}
	end;

do_msg({inscription_effects,Uid,PropList})->
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
			Obj = #scene_spirit_ex{data= UsrData } ->
				fun_scene_obj:update(Obj#scene_spirit_ex{data =UsrData#scene_usr_ex{inscription_effects=PropList}});
			_->skip
	end;

do_msg({send_guild_call,Uid,ItemId,Lev})->
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		#scene_spirit_ex{pos=Pos,data=#scene_usr_ex{hid=AgentHid}} ->
			SceneId = get(scene),
			?debug("------send_guild_call-----SceneId=~p-",[SceneId]),
			fun_scene_obj:agentmng_msg(AgentHid,{send_guild_call,Uid,SceneId,Pos,ItemId,Lev});
		_->skip
	end;
do_msg({send_camp_call,Uid,ItemId,Lev})->
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		#scene_spirit_ex{pos=Pos,data=#scene_usr_ex{hid=AgentHid}} ->
			SceneId = get(scene),
			?debug("------send_guild_call-----SceneId=~p-",[SceneId]),
			fun_scene_obj:agentmng_msg(AgentHid,{send_camp_call,Uid,SceneId,Pos,ItemId,Lev});
		_->skip
	end;
do_msg({transmit_to_pos,Uid,Pos,Seq})->
	fun_interface:s_transmit_to_pos(Uid, Pos,Seq,1);

do_msg({drop_item_activity,ActivityDropItem})->
	put(activity_drop_item,ActivityDropItem);

do_msg(Msg) ->
	?WARNING("unhandled msg:",[Msg]).


delete_personage_boss({BoosID})->
	fun_interface:s_del_monster(BoosID).

	
send_fighting(Uid,Fighting)->
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		#scene_spirit_ex{data=#scene_usr_ex{hid=AgentHid}} ->
			fun_scene_obj:agentmng_msg(AgentHid,{updata_fighting,Uid,Fighting});
		_->skip
	end.
%% 	gen_server:cast({global, agent_mng},{updata_fighting,Uid,Fighting}).
send_name(Uid,Name)->
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		#scene_spirit_ex{data=#scene_usr_ex{hid=AgentHid}} ->
			fun_scene_obj:agentmng_msg(AgentHid, {updata_name,Uid,Name});
		_->skip
	end.
%% 	gen_server:cast({global, agent_mng},{updata_name,Uid,Name}).
send_usr_lev(Uid,Lev)->
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		#scene_spirit_ex{data=#scene_usr_ex{hid=AgentHid}} ->
			fun_scene_obj:agentmng_msg(AgentHid, {updata_usr_lev,Uid,Lev});
		_->skip
	end.
%% 	gen_server:cast({global, agent_mng},{updata_usr_lev,Uid,Lev}).

send_paragon_level(Uid,Lev,Exp)->
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		#scene_spirit_ex{data=#scene_usr_ex{hid=AgentHid}} ->
			fun_scene_obj:agentmng_msg(AgentHid,{updata_usr_paragon_level,Uid,Lev,Exp});
		_->skip
	end.
%% 	gen_server:cast({global, agent_mng},{updata_usr_paragon_level,Uid,Lev,Exp}).

send_vip_level(Uid,Lev,Exp)->
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		#scene_spirit_ex{data=#scene_usr_ex{hid=AgentHid}} ->
			fun_scene_obj:agentmng_msg(AgentHid, {updata_usr_vip_level,Uid,Lev,Exp});
		_->skip
	end.


process_pt(pt_req_fly_planes_d320,Seq,Pt,Sid,Uid) ->
	mod_scene_api:process_scene_pt(pt_req_fly_planes_d320,Seq,Pt,Sid,Uid);

process_pt(pt_scene_move_c001,_Seq,Pt,Sid,Uid) ->
	% ?debug("pt_scene_move_c001 Pt = ~p,Sid = ~p,uid=~p,time=~p",[Pt,Sid,Uid,util:unixtime()]),
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		Usr = #scene_spirit_ex{move_data=_MoveData,data = UsrData = #scene_usr_ex{sid = Sid}} -> 
			% ?debug("Pos2~p", [Pt#pt_scene_move.point_list]),
			Oid = Pt#pt_scene_move.oid,
			Dir = Pt#pt_scene_move.dir,
			%% 下面的判断做了一个优化
			%% 客户端存在战斗时发同样的移动协议的问题，所有服务器加个判断来过滤这个
			case get({last_move_pt, Oid}) == Pt#pt_scene_move.point_list of
				true -> 
					% ?debug("oid ~p same pos  move ignored", [Oid]),
					skip;
				_ -> 
					put({last_move_pt, Oid}, Pt#pt_scene_move.point_list),
					EntourageList = Usr#scene_spirit_ex.data#scene_usr_ex.battle_entourage,
					IsEntourages = lists:member(Oid, EntourageList),
					if 
						Oid == Uid -> 
							fun_scene_obj:update(Usr#scene_spirit_ex{dir = Dir, data =UsrData#scene_usr_ex{last_pt= {Uid,Pt}}});
						IsEntourages ->
							% ?debug("Pt = ~p",[Pt]),
							case fun_scene_obj:get_obj(Oid, ?SPIRIT_SORT_ENTOURAGE) of
								Entourage = #scene_spirit_ex{data = EntourageData = #scene_entourage_ex{}} -> 
									fun_scene_obj:update(Entourage#scene_spirit_ex{data =EntourageData#scene_entourage_ex{last_pt= {Uid,Pt}}});
								_ -> skip
							end;
						true -> skip
					end
			end;
		_ -> skip
	end;

process_pt(pt_cast_shenqi_skill_f11a,Seq,_Pt,_Sid,Uid) ->
	fun_shenqi_skill:user_cast_shenqi_skill(Uid, Seq);

process_pt(pt_scene_skill_c005,Seq,Pt,_Sid,Uid) -> 
	% ?debug("get scene_skill Pt = ~p",[Pt]),
	% ?debug("get scene_skill Pt = ~p,Sid = ~p,uid=~p",[Pt,Sid,Uid]),
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		#scene_spirit_ex{} = Usr -> 
			put(is_in_fight, true), %% 主关卡刷怪需要知道是否玩家是在战斗中
			#scene_usr_ex{skill_list = Skill_List} = Usr#scene_spirit_ex.data,
			X=Pt#pt_scene_skill.x,
			Y=Pt#pt_scene_skill.y,
			Z=Pt#pt_scene_skill.z,
			SkillType = Pt#pt_scene_skill.skill,
			TargetID = Pt#pt_scene_skill.target_id,
			TargetPos = {Pt#pt_scene_skill.target_x,Pt#pt_scene_skill.target_y,Pt#pt_scene_skill.target_z},
			
			Pos=case fun_scene_map:check_point( tool_vect:to_map_point({X,Y,Z}) ) of
					{true,_,#map_point{x=CX,y=CY,z=CZ}} -> {CX,CY,CZ};
					_ -> 
						{X,Y,Z}									
				end,			
			Oid = Pt#pt_scene_skill.oid,
			%% 如果这次请求释放技能的时间在上次释放技能的硬直时间内，则判断是前端开了加速了
			LongNow = util_time:longunixtime(),
			EntourageList = Usr#scene_spirit_ex.data#scene_usr_ex.battle_entourage,
			% ?debug("Oid = ~p",[Oid]),
			% ?debug("EntourageList = ~p",[EntourageList]),
			IsEntourages = lists:member(Oid, EntourageList),
			% ?debug("IsEntourages = ~p",[IsEntourages]),
			
			% ?debug("get scene_skill Oid = ~p, EntourageList = ~p",[Oid,EntourageList]),
			if
				Oid == Uid -> 
					CheckTime = get_next_cast_check_time(Uid),
					case CheckTime >= LongNow of
						true ->
							% add_cheat_times(Uid, Sid);
							?log_error("~p request cast skill ~p too fast, is user cheat?", [Uid, SkillType]);
						_ ->
							NUsr = fun_scene_obj:update(Usr#scene_spirit_ex{pos=Pos,dir=Pt#pt_scene_skill.dir}),
							case lists:keyfind(SkillType, 1, Skill_List) of
								{SkillType,SkillLev}->
									usr_skill(NUsr,{SkillType,SkillLev},TargetID,TargetPos,Seq,false,LongNow);
								_-> 
									?log_warning("can not find skill,Uid:~p,SkillType = ~p,Skill_List = ~w",[Uid, SkillType,Skill_List]),
									skip
							end
					end;
				IsEntourages ->
					% ?debug("Oid = ~p",[Oid]),
					% ?debug("Oid:~p, Entourage:~p",[Oid, fun_scene_obj:get_obj(Oid, ?SPIRIT_SORT_ENTOURAGE)]),
					% ?debug("Oid:~p, Uid:~p, E:~p", [Oid, Uid, EntourageList]),
					CheckTime = get_next_cast_check_time(Oid),
					case CheckTime >= LongNow of
						true ->
							% add_cheat_times(Uid, Sid);
							?log_error("~p request cast skill ~p too fast, is user cheat?", [Uid, SkillType]);
						_ ->
							case fun_scene_obj:get_obj(Oid, ?SPIRIT_SORT_ENTOURAGE) of
								Entourage = #scene_spirit_ex{data = #scene_entourage_ex{skills=SkillList}} -> 										
									NEntourage = fun_scene_obj:update(Entourage#scene_spirit_ex{pos=Pos,dir=Pt#pt_scene_skill.dir}),
									%%测试阶段，客户端发过来的就是skilltype
									SkillLev =
										case lists:keyfind(SkillType,1,SkillList) of
											{_,OwnSkillLev}->OwnSkillLev;
											_ -> 0
										end,
									entourage_skill(Usr, NEntourage,{SkillType,SkillLev},TargetID,TargetPos,Seq,LongNow);
								_ -> 
									?debug("Oid:~p, Entourage:~p",[Oid, fun_scene_obj:get_obj(Oid, ?SPIRIT_SORT_ENTOURAGE)]),
									skip
							end
					end;
				true -> 
					?ERROR("Wrong skill caster:~p", [Oid]) 
			end;
		_ -> skip
	end;
process_pt(pt_scene_fly_by_fly_point_c004,Seq,Pt,Sid,Uid) -> 
	?debug("get scene_fly_by_fly_point Pt = ~p,Sid = ~p,uid=~p",[Pt,Sid,Uid]),
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		#scene_spirit_ex{camp=Camp,data=#scene_usr_ex{lev=Lev,hid=AgentHid}} -> 
			FlyPointID = Pt#pt_scene_fly_by_fly_point.fly_point_id,
			?debug("get scene_fly_by_fly_point FlyPointID = ~p",[FlyPointID]),
			case data_fly_point_config:get_fly_point(FlyPointID) of
				#st_fly_point_config{sort = "targetScene",targetScene= TargetScene,targetX= TargetX,targetY= TargetY,targetZ= TargetZ,needLv=NeedLv,camp=NeedCamp} ->
					case check_camp(Camp, NeedCamp) of
						true->
							if Lev >= NeedLv->

								on_save_pos(Uid),
								fun_scene_obj:agentmng_msg(AgentHid, {fly, Sid,Uid,Seq,{TargetScene,{TargetX,TargetY,TargetZ}}});
							   true->skip
							end;
						_->skip
					end;
				_ ->skip
			end;
		_ -> skip
	end;

%%场景物品点击响应
process_pt(pt_scene_item_c019,_Seq,Pt,Sid,Uid) -> 
	?debug("-----get scene_item_action Pt = ~p,Sid = ~p,uid=~p,now=~p",[Pt,Sid,Uid,util:unixtime()]),
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		#scene_spirit_ex{pos={X,_,Z},die=false} -> 
			TargetID=Pt#pt_scene_item.target_id,
			case fun_scene_obj:get_obj(TargetID, ?SPIRIT_SORT_ITEM) of 
				#scene_spirit_ex{pos={IX,IY,IZ},data=#scene_item_ex{type=Type,action=Moudle}} ->
					?debug("--pos--X,Z=~p",[{X,Z}]),
					case data_scene_item:get_data(Type) of
						#st_scene_item_config{touchType=?CLICK_SCENE_ITEM_TOUCH,touchDistance=NeedDis} ->
							Dis=tool_vect:lenght(tool_vect:to_map_point({IX-X,0,IZ-Z})),
							if
								Dis =< NeedDis + 2 -> %%因为自动采集偶尔会因为距离采集不到,加2个单位长是为了处理偶尔出现不同步
									case Moudle of
										no -> skip;
										_ ->
											try
												Moudle:do(Type,TargetID-?OBJ_OFF,{IX,IY,IZ},Uid)
											catch E:R -> ?log_error("scene_item action error Moudle=~p,type=~p,E=~p,R=~p,stack=~p",[Moudle,Type,E,R,erlang:get_stacktrace()])
											end
									end;
								true -> ?log_error("scene_item_c019,too far,{dis,needdis}=~p~n",[{Dis,NeedDis}]),skip
							end;
						_ -> ?log_error("scene_item_c019 error,not find config,Type=~p~n",[Type]),skip
					end;	
				_ -> ?log_error("scene_item_c019 error,not find scene item,id=~p~n",[TargetID]),skip
			end;
		_ -> skip
	end;

process_pt(pt_scene_fly_scene_d134,Seq,Pt,Sid,Uid) -> 
%% 	?debug("get scene_fly_by_fly_point Pt = ~p,Sid = ~p,uid=~p",[Pt,Sid,Uid]),
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		#scene_spirit_ex{data=#scene_usr_ex{hid=AgentHid}} -> 
			TargetScene = Pt#pt_scene_fly_scene.fly_scene_id,
%% 			?debug("get scene_fly_scene_d134 TargetScene = ~p",[TargetScene]),
			case data_scene_config:get_scene(TargetScene) of
				#st_scene_config{sort = ?SCENE_SORT_COPY,points = PointList} -> 
					on_save_pos(Uid),%%准备进入副本就保存当前位
					fun_scene_obj:agentmng_msg(AgentHid,  {fly, Sid,Uid,Seq,{TargetScene,hd(PointList)}});
%% 					gen_server:cast({global, agent_mng}, {fly, Sid,Uid,Seq,{TargetScene,{In_x,0,In_z}}});			
				_ -> skip					
			end;
		_ -> skip
	end;
	
process_pt(_PtModule,_Seq,_Pt,_Sid,_Uid) -> 
	?debug("_PtModule = ~p,_Pt = ~p",[_PtModule,_Pt]),
	ok.

get_scene_model() -> get(scene_model).

get_load_succeed(Uid)->
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		#scene_spirit_ex{data=#scene_usr_ex{sid=Sid,hid=AgentHid}} -> 
			case data_scene_config:get_scene(get(scene)) of
				#st_scene_config{points = PointList} -> 
%% 					?debug("-------pt_scene_load_d144----OutScene=~p",[OutScene]),
					fun_scene_obj:agentmng_msg(AgentHid,  {fly, Sid,Uid,0,{get(scene),hd(PointList)}});
%% 					gen_server:cast({global, agent_mng}, {fly, Sid,Uid,0,{OutScene,{OutX,0,OutZ}}});			
				_ -> skip					
			end;
		_ -> skip
	end.
do_module_script(Fun,Args)->
	Module = get_scene_model(),
	try
		erlang:apply(Module, Fun, Args)
	catch E:R -> ?log("do_module_script error E:~p, R:~p, info = ~p,~n c = ~p",[E,R,{Module, Fun, Args},erlang:get_stacktrace()]),cotinue
	end.

run_scene_script(Fun,Args) ->
	ScriptMoudle = get_script_module(),	
	case ScriptMoudle of
		undefined -> skip;
		_ ->
			try
				erlang:apply(ScriptMoudle, Fun, Args)
			catch E:R -> 
				?EXCEPTION_LOG(E, R, Fun, Args)
			end
	end.

get_script_module() ->
	get(scene_script).

% update_copy_times(Scene,List) ->
% 	case data_dungeons_config:select(Scene) of
% 		[DungeonsID] -> 
% 			case data_dungeonsGroup_config:select(DungeonsID) of
% 				[GroupID] ->
% 					case lists:keyfind(GroupID, 1, List) of
% 						{GroupID,Times,Time} -> 
% 							if
% 								Times =< 0 -> ?log_error("update_copy_times error,{Scene,GroupID,Times}=~p~n",[{Scene,GroupID,Times}]);
% 								true -> skip
% 							end,
% 							lists:keyreplace(GroupID, 1, List, {GroupID,Times-1,Time});
% 						_ -> List	
% 					end;
% 				_ -> List	
% 			end;
% 		_ -> List
% 	end.	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pick_move_data([]) -> {null,0};
pick_move_data([Data | Next]) -> {Data,Next};
pick_move_data(_) -> {null,0}.

%%排除0
get_move_time(PaceSpeed,0,{SX,_SY,SZ},{EX,_EY,EZ}) -> get_move_time(PaceSpeed,60,{SX,_SY,SZ},{EX,_EY,EZ});
get_move_time(PaceSpeed,MoveSpeed,{SX,_SY,SZ},{EX,_EY,EZ}) ->	
	Dis = tool_vect:lenght(tool_vect:to_map_point({EX - SX, 0, EZ - SZ})),
	Speed = PaceSpeed * (MoveSpeed/100),
	util:floor(Dis * 1000 / Speed).

get_player_config_pace_speed(_Prof) -> 4.

get_mon_config_speed(Type) ->
	case data_monster:get_monster_prop(Type) of
		#st_monster_battle{movespd = MoveSpd} -> MoveSpd;
		_ -> 100
	end.
get_mon_config_pace_speed(Type) ->
	case data_monster:get_monster(Type) of
		#st_monster_config{baseMoveSpd = PaceSpeed} -> PaceSpeed;
		_ -> 1
	end.
get_entourage_config_pace_speed(Type) ->
	case data_entourage:get_data(Type) of
		#st_entourage_config{baseMoveSpd=PaceSpeed} -> PaceSpeed;
		_ -> 1
	end.

move_player(Usr=#scene_spirit_ex{sort=?SPIRIT_SORT_USR,die=false}, {{Mx,My,Mz}, MoveData})->
	{Pos,Next} = pick_move_data(MoveData),
%% 	?debug("{Mx,My,Mz}=~p,{Pos,Next} =~p",[{Mx,My,Mz},{Pos,Next}]),
	case Pos of
		null ->			
			Dir = Usr#scene_spirit_ex.dir,				
			{ok, Usr#scene_spirit_ex{pos={Mx,My,Mz},dir = Dir,move_data =0}};
		{X,_,Z} ->
			case fun_scene_map:check_point(tool_vect:to_map_point({Mx,My,Mz})) of 
				{true,_,#map_point{x=CrossX,y=CrossY,z=CrossZ}} ->					
					Curr_mov_speed = fun_scene_obj:get_move_speed(Usr),	
					NextNeedTime = fun_scene:get_move_time(fun_scene_obj:get_pace_speed(Usr),Curr_mov_speed,{Mx,My,Mz},Pos),
					Dir = tool_vect:get_dir_angle(tool_vect:to_map_point({X - Mx,0,Z - Mz})),	
					{ok, Usr#scene_spirit_ex{pos={CrossX,CrossY,CrossZ},dir=Dir,demage_data = 0,skill_data=0,
											 move_data=#move_data{start_time = util:longunixtime(),all_time = NextNeedTime,to_pos = Pos,move_speed = Curr_mov_speed,next = Next}}};
				_ -> 
					error
			end
	end;
move_player(_R1,_R2) -> skip.

move_entourage(Entourage=#scene_spirit_ex{sort=?SPIRIT_SORT_ENTOURAGE,die=false}, {{Mx,My,Mz}, MoveData})->
	{Sx,_,Sz}=Entourage#scene_spirit_ex.pos,
	Dx = util:abs(Mx - Sx),
	Dz = util:abs(Mz - Sz),
	if
		Dx > 2 -> ?debug("run error  fast now = ~p,get = ~p",[Entourage#scene_spirit_ex.pos,{Mx,My,Mz}]);
		Dz > 2 -> ?debug("run error  fast now = ~p,get = ~p",[Entourage#scene_spirit_ex.pos,{Mx,My,Mz}]);
		true -> skip
	end,
	{Pos,Next} = pick_move_data(MoveData),
%% 	?debug("{Mx,My,Mz}=~p,{Pos,Next} =~p",[{Mx,My,Mz},{Pos,Next}]),
	case Pos of
		null ->			
			Dir = Entourage#scene_spirit_ex.dir,				
			{ok, Entourage#scene_spirit_ex{pos={Mx,My,Mz},dir = Dir,move_data =0}};
		{X,_,Z} ->
			case fun_scene_map:check_point(tool_vect:to_map_point({Mx,My,Mz})) of 
				{true,_,#map_point{x=CrossX,y=CrossY,z=CrossZ}} ->							
					Curr_mov_speed = fun_scene_obj:get_move_speed(Entourage),	
					NextNeedTime = fun_scene:get_move_time(fun_scene_obj:get_pace_speed(Entourage),Curr_mov_speed,{Mx,My,Mz},Pos),
					Dir = tool_vect:get_dir_angle(tool_vect:to_map_point({X - Mx,0,Z - Mz})),	
%% 					?debug("set move_data = ~p",[#move_data{start_time = util:longunixtime(),all_time = NextNeedTime,to_pos = Pos,move_speed = Curr_mov_speed,next = Next}]),
					{ok, Entourage#scene_spirit_ex{pos={CrossX,CrossY,CrossZ},dir=Dir,demage_data = 0,skill_data=0,
											 move_data=#move_data{start_time = util:longunixtime(),all_time = NextNeedTime,to_pos = Pos,move_speed = Curr_mov_speed,next = Next}}};
				_ -> 
					% ?log_warning("entourage cant go pos:~w",[Pos]),
					{error,Entourage}
			end
	end;
move_entourage(_R1,_R2) -> 
%% 	?debug("222222 DATA = ~p",[{_R1,_R2}]),
	skip.

move_monster(Monster=#scene_spirit_ex{sort = ?SPIRIT_SORT_MONSTER, pos={MX,MY,MZ}}, Path) when erlang:length(Path) > 0 ->
	TargetSort = util_scene:server_obj_type_2_client_type(?SPIRIT_SORT_MONSTER),
	NPath= lists:append([{MX,MY,MZ}], Path),
	FunPath = fun({PX,PY,PZ}) ->
		#pt_public_point3{
			x = PX,
			y = PY,
			z = PZ
		}
	end,
	NPath1 = lists:map(FunPath, NPath),
	Pt = #pt_scene_move{
		oid        = Monster#scene_spirit_ex.id,
		obj_sort   = TargetSort,
		dir        = Monster#scene_spirit_ex.dir,
		point_list = NPath1
	},
	fun_scene_obj:send_cell_all_usr(Monster,proto:pack(Pt), 0),
	
	{X, Y, Z} = hd(Path),	
	Curr_mov_speed=fun_scene_obj:get_move_speed(Monster),
	NextNeedTime = get_move_time(fun_scene_obj:get_pace_speed(Monster),Curr_mov_speed,Monster#scene_spirit_ex.pos, {X, Y, Z}),
	Dir = tool_vect:get_dir_angle(tool_vect:to_map_point({X - MX,0,Z - MZ})),
	Monster#scene_spirit_ex{demage_data = 0,skill_data = 0, dir = Dir,
							move_data =#move_data{start_time = util:longunixtime(),all_time = NextNeedTime,to_pos = {X, Y, Z},move_speed = Curr_mov_speed,next = []}};

move_monster(_,_) -> skip.

entourage_skill(Usr, Entourage =#scene_spirit_ex{id = Eid},{SkillType,SkillLev},Target,TargetPos,Seq,LongNow) ->
	Sid = Usr#scene_spirit_ex.data#scene_usr_ex.sid,
	if
		Target == 0 -> 
			entourage_skill_help(Usr, Entourage, {SkillType,SkillLev},Target,TargetPos,Seq,LongNow);
		true ->
			case fun_scene_obj:get_obj(Target) of
				#scene_spirit_ex{die = true} ->
					send_fight_error(Eid, Sid, Seq, SkillType, "user_die");
				_ ->
					entourage_skill_help(Usr, Entourage, {SkillType,SkillLev},Target,TargetPos,Seq,LongNow)
			end
	end.

entourage_skill_help(Usr, Entourage =#scene_spirit_ex{id = Eid,die=Die},{SkillType,SkillLev},Target,TargetPos,Seq,LongNow) ->
	Sid = Usr#scene_spirit_ex.data#scene_usr_ex.sid,
	if 
		Die == true -> 
			send_fight_error(Eid, Sid, Seq, SkillType, "user_die");
		true->
			case fun_scene_skill:check_skill_entourage(Eid, SkillType, SkillLev) of
				true ->
					Config = data_skillleveldata:get_skillleveldata(SkillType),
					% ?DBG(Entourage),
					case fun_scene_cd:add_cd(Entourage, SkillType, Config#st_skillleveldata_config.cd) of
						cding -> send_fight_error(Eid, Sid, Seq, SkillType, "error_skill_in_cd");
						NEntourage1 ->
							NEntourage = if
								Target == 0 -> fun_scene_obj:update(fun_scene_obj:put_entourage_spc_data(NEntourage1, target, Target));
								true -> fun_scene_obj:update(NEntourage1)
							end,
							fun_scene_skill:cast_skill(NEntourage, Target, TargetPos, {SkillType,SkillLev},Seq),
							set_next_cast_check_time(Eid, SkillType, LongNow)
					end;
				_ -> 
					?ERROR("hero ~p can't cast skill for buff reason", [Eid])
			end
	end.

check_usr_skill(Usr, SkillType, SkillLev, Target, IsShenqiSkill) ->
	 if
		Target == 0 -> 
			check_usr_skill2(Usr, SkillType, SkillLev, Target, IsShenqiSkill);
		true -> 
			case fun_scene_obj:get_obj(Target) of
				#scene_spirit_ex{die = true} -> 
					{error, "skill_target_die"};
				_ ->
					check_usr_skill2(Usr, SkillType, SkillLev, Target, IsShenqiSkill)
			end
	end.

check_usr_skill2(Usr, SkillType, _SkillLev, Target, _IsShenqiSkill) ->
	#scene_spirit_ex{id = Uid, die = Die, pos = CastPos, sort = Sort} = Usr,
	if 
		Die == true ->
			{error, "user_die"};
		true->
			% ?DBG(CastPos)
			Targets = fun_scene_skill:collect_skill_targets(Uid,CastPos,Usr#scene_spirit_ex.dir,0,CastPos,SkillType),
			case Targets of
				[] -> 
					?DBG(error_fight_no_targets),
					{error, "error_fight_no_targets"};
				_  ->
					case Sort of
						?SPIRIT_SORT_USR ->
							#st_skillleveldata_config{cd = CD2} = data_skillleveldata:get_skillleveldata(SkillType),
							CD3 = util:floor(CD2 *(1-get_inscription_del_cd(Uid,SkillType))),
							case fun_scene_cd:add_cd(Usr, SkillType, CD3) of
								cding -> 
									{error, "error_skill_in_cd"};
								NUsr1 ->	
									NUsr = if
							    		Target == 0 ->  
							   				fun_scene_obj:update(fun_scene_obj:put_usr_spc_data(NUsr1, target, Target));
							    		true -> NUsr1
						    		end,
									{ok, NUsr}
							end;
						_ -> {ok, Usr}
					end
			end
	end.	

usr_skill(Usr =#scene_spirit_ex{id = Uid,sort=?SPIRIT_SORT_USR,data=#scene_usr_ex{sid=Sid,hid=AgentHid}},{SkillType,SkillLev},Target,TargetPos,Seq,IsShenqiSkill,_LongNow) ->
	% ?debug("user ~p cast skill:~p", [Uid, SkillType]),
	case check_usr_skill(Usr, SkillType, SkillLev, Target, IsShenqiSkill) of
		{error, Reason} ->
			send_fight_error(Uid, Sid, Seq, SkillType, Reason),
			{error, not_succ};
		{ok, Usr2} ->
			fun_scene_skill:cast_skill(Usr2, Target, TargetPos, {SkillType,SkillLev}, Seq),
			fun_scene_obj:agent_msg(AgentHid, {in_fight})
	end.

send_fight_error(Oid, Sid, Seq, SkillType, Error) ->
	#st_error_info{id = ErrorId} = data_error_info:get_data(Error),
	Pt = #pt_scene_skill_effect{
		error_code = ErrorId,
		oid        = Oid,
		obj_sort   = ?SPIRIT_CLIENT_TYPE_USR,
		skill      = SkillType
	},
	?send(Sid, proto:pack(Pt, Seq)).

monster_skill(Monster=#scene_spirit_ex{id = Oid, sort=?SPIRIT_SORT_MONSTER,die=Die},Skill,TargetID,_Dir,TargetPos) ->
	if 
		Die == true -> Monster;
		true->
			case fun_scene_skill:check_skill(Oid, Skill, 1) of
				false -> %% 有种情况，在持续性施放buff skill时不能攻击  
					Monster;
				_ ->
					case data_skillmain:get_skillmain(Skill) of
						#st_skillmain_config{ai_skill_cast_condition = AiCondition, ai_skill_cast_param = AiSkillParam} ->
							case data_skillleveldata:get_skillleveldata(Skill)  of	
								Config when is_record(Config,st_skillleveldata_config) ->
									case fun_scene_cd:add_cd(Monster, Skill, Config#st_skillleveldata_config.cd) of
										cding -> Monster;
										NMonster ->
											fun_scene_skill:monster_cast_skill(NMonster,TargetID,TargetPos,{Skill,1},AiCondition,AiSkillParam,0),
											fun_scene_obj:get_obj(NMonster#scene_spirit_ex.id)		
									end;
								_ -> ?debug("monster skill can not find SkillType = ~p",[Skill]),Monster
							end;
						_ -> ?debug("monster skill can not find skill = ~p",[Skill]),Monster
					end
			end
	end;
monster_skill(_,_,_,_,_)-> skip.

robot_skill(Robot=#scene_spirit_ex{sort=?SPIRIT_SORT_ROBOT},{SkillType,SkillLev},Target,_Dir,TargetPos) ->
	case check_usr_skill(Robot, SkillType, SkillLev, Target, true) of
		{error, _Reason} ->
			{error, not_succ};
		{ok, Robot2} ->
			fun_scene_skill:cast_skill(Robot2, Target, TargetPos, {SkillType,SkillLev}, 0)
	end.

robot_entourage_skill(Entourage=#scene_spirit_ex{id = Eid,sort=?SPIRIT_SORT_ENTOURAGE,die=Die},{SkillType,SkillLev},Target,TargetPos) ->
	if 
		Die == true -> Entourage;
		true->
			case fun_scene_skill:check_skill_entourage(Eid, SkillType,SkillLev) of
				true -> 
					case data_skillleveldata:get_skillleveldata(SkillType) of
						Config when is_record(Config,st_skillleveldata_config) ->
							case fun_scene_cd:add_cd(Entourage, SkillType, Config#st_skillleveldata_config.cd) of
								cding -> Entourage;
								NEntourage ->
									fun_scene_skill:cast_skill(NEntourage,Target,TargetPos,{SkillType,SkillLev},0),
									fun_scene_obj:get_obj(NEntourage#scene_spirit_ex.id)
							end;
						_ -> ?debug("Entourage skill can not find SkillType = ~p",[SkillType]),Entourage
					end;
				_ -> 
					?debug("Entourage skill check fail"),Entourage
			end
	end.

send_count_event(Uid,Event,Sort,Data,Num)->
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		#scene_spirit_ex{data=#scene_usr_ex{sid=Sid,hid = AgentHid}}->
			fun_scene_obj:agent_msg(AgentHid,{count_event,Event,{Sort,Data,Num},Uid,Sid});
		_->skip
%% 	updata_off_count(Uid, Sort, Data, Num)
	end.

s_get_hp_mp_by_uid(ID)->
	case fun_scene_obj:get_obj(ID) of
		#scene_spirit_ex{hp=Hp,mp=Mp} -> {Hp,Mp};
		_->{0,0}
	end.

%%副本结束时将伤害副本进度传入出来发送到世界节点
s_guild_copy_usr_damage(Uid,Scene,ItemList,ML)->
	case get(count_usr_demage) of
		?UNDEFINED->
			Copy_progress = get_copy_progress(),
			case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
				#scene_spirit_ex{data=#scene_usr_ex{hid = AgentHid}}->
					fun_scene_obj:agentmng_msg(AgentHid, {guild_copy_damage_progress,Scene,Uid,[{Uid,Scene,0}],Copy_progress,ItemList,ML});
				_->skip
			end;
%% 			gen_server:cast({global, agent_mng},{guild_copy_damage_progress,Scene,Uid,[{Uid,Scene,0}],Copy_progress,ItemList,ML});
		DamageList->
			Copy_progress = get_copy_progress(),
			case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
				#scene_spirit_ex{data=#scene_usr_ex{hid = AgentHid}}->
					fun_scene_obj:agentmng_msg(AgentHid,{guild_copy_damage_progress,Scene,Uid,DamageList,Copy_progress,ItemList,ML});
				_->skip
			end
%% 			gen_server:cast({global, agent_mng},{guild_copy_damage_progress,Scene,Uid,DamageList,Copy_progress,ItemList,ML})
	end.

%%公会副本进出
s_guild_copy(Uid,Scene)->
	ML = fun_scene_obj:get_ml(),
	SoloTypeList = 
	case get(guild_copy_solo_type) of
		?UNDEFINED ->[];
		NewSoloTypeList->NewSoloTypeList
	end,
	MonsterList = lists:filter(fun(Monster)-> lists:member(Monster#scene_spirit_ex.data#scene_monster_ex.type, SoloTypeList) andalso Monster#scene_spirit_ex.hp =/= 0 end, ML),
	case MonsterList of
		[]->guild_copy(Uid,Scene);
		_->
			NewMonsterList = lists:foldl(fun(Monster,Acc)-> Acc++ [{Monster#scene_spirit_ex.data#scene_monster_ex.type,Monster#scene_spirit_ex.hp}] end,[],ML),
			put(guild_copy_failure_monster,NewMonsterList),
			s_guild_copy_usr_damage(Uid, Scene,[],NewMonsterList)
	end.

guild_copy(Uid,Scene)->
	s_guild_copy_succeed(Scene),
	ItemList = get(guild_copy_itemlist),
	s_guild_copy_usr_damage(Uid, Scene,ItemList,[]).

%%公会副本通关成功
s_guild_copy_succeed(_Scene)->
	ML = fun_scene_obj:get_ml(),
	MonsterList = lists:filter(fun(Monster)-> Monster#scene_spirit_ex.hp =/= 0 end, ML),
	case MonsterList of
		[]->
			put(guild_copy_failure_monster,[]);
		_->
			NewMonsterList = lists:foldl(fun(Monster,Acc)-> lists:append(Acc, [{Monster#scene_spirit_ex.data#scene_monster_ex.type,Monster#scene_spirit_ex.hp}])end,[],MonsterList),
			put(guild_copy_failure_monster,NewMonsterList)
	end.

copy_out_decision(Uid,Seq) ->
	%% 现在副本出来一律去关卡副本
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		#scene_spirit_ex{die = Die, data=#scene_usr_ex{barrier_id = BarrierId, sid=Sid, hid=AgentHid}} ->
			case Die of
				true -> 
					#st_scene_config{points = PointList} = data_scene_config:get_scene(get(scene)),
					{Ox, _, Oz} = PointList,
					Pt=#pt_revive{
									 revive_uid = Uid,
									 revive_sort = ?REVIVE_SORT_ONE,
									 x = Ox,
									 y = 0,
									 z = Oz
									},
					?send(Sid,proto:pack(Pt));
				_ -> skip
			end,

			#st_dungeons_config{dungenScene = OutScene} = data_dungeons_config:get_dungeons(BarrierId),
			#st_scene_config{points = PointList1} = data_scene_config:get_scene(OutScene),
			fun_scene_obj:agentmng_msg(AgentHid, {fly, Sid, Uid, Seq, {OutScene,hd(PointList1)}});
		_ -> skip
	end.

leave_temp_teams(Uid)->
	% ?debug("leave_temp_teams,Uid = ~p",[Uid]),
	TempTeams=case get(scene_info) of
				  {match, TeamId, _} ->[TeamId];
				  {war_match,Teams,_}->Teams;
				  _->[]
			  end,
	?debug("leave_temp_teams,TempTeams = ~p",[TempTeams]),
	if  
		length(TempTeams)>0->
			case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
				#scene_spirit_ex{data=#scene_usr_ex{sid=_Sid,hid=AgentHid}} ->
					case get(global) of 
						scene -> 
							?debug("global scene"),
							gen_server:cast({global,global_server}, {quit_temp_team,Uid,TempTeams});
						_ -> 
							% ?debug("leave_temp_teams,to agent mng"),
							fun_scene_obj:agentmng_msg(AgentHid, {quit_temp_team,Uid,TempTeams })
					end;
%% 					gen_server:cast({global, agent_mng}, {quit_temp_team,Uid,TempTeams });
				_R->
					?debug("_R = ~p",[_R]),
					skip
			end;	
       
		true->skip
		
	end.

copy_scene_lose_player() ->
	case get_copy_timer_ref() of
		Ref when erlang:is_reference(Ref) -> erase(copy_timer_ref);
		_ -> skip
	end,
	
	Script_Module=get_script_module(),
	try
		Script_Module:onLose()
	catch E:R -> ?log_error("Script error Modul=~p,E=~p,R=~p,stack=~p",[Script_Module,E,R,erlang:get_stacktrace()])	
	end.

get_copy_timer_len() -> get(copy_timer_wait_time).
set_copy_timer_len(TimeLen) -> put(copy_timer_wait_time,TimeLen).
get_copy_timer_ref() -> get(copy_timer_ref).
% set_copy_timer_ref(TimerRef) -> put(copy_timer_ref,TimerRef).

broadcast_to_scene(reflush_monster_system_msg,Content) ->
	broadcast_to_scene(system_msg,[Content]);
broadcast_to_scene(reflush_monster_tips_msg,TipsCode) -> 
	UL=fun_scene_obj:get_ul(),
	Fun=fun(#scene_spirit_ex{data=#scene_usr_ex{sid=Sid}}) ->
			?error_report(Sid,TipsCode)
		end,
	lists:foreach(Fun, UL);
broadcast_to_scene(system_msg,StringList) ->
	UL=fun_scene_obj:get_ul(), 
	Fun=fun(#scene_spirit_ex{name=CallName,data=#scene_usr_ex{sid=Sid}}) ->
				Pt=#pt_chat{pid = 0,
							   name = "SYSTEM",
							   rec_name = CallName,
							   vip_lev = 0,
							   chanle = ?CHANLE_SYSTEM,
							   content = StringList
							  },
				?send(Sid,proto:pack(Pt))				
		end,
	lists:foreach(Fun, UL);
broadcast_to_scene(speaker_msg,StringList) ->
	UL=fun_scene_obj:get_ul(), 
	Fun=fun(#scene_spirit_ex{name=CallName,data=#scene_usr_ex{sid=Sid}}) ->
				Pt=#pt_chat{pid = 0,
							   name = "SYSTEM",
							   rec_name = CallName,
							   vip_lev = 0,
							   chanle = ?CHANLE_SPEAKER,
							   content = StringList
							  },
				?send(Sid,proto:pack(Pt))				
		end,
	lists:foreach(Fun, UL);
broadcast_to_scene(camp_speaker_msg,{Camp,StringList}) ->
	UL=fun_scene_obj:get_ul(), 
	Fun=fun(Data) ->
				case Data of
					#scene_spirit_ex{name=CallName,camp=Camp,data=#scene_usr_ex{sid=Sid}} ->
						Pt=#pt_chat{pid = 0,
									   name = "SYSTEM",
									   rec_name = CallName,
									   vip_lev = 0,
									   chanle = ?CHANLE_SPEAKER,
									   content = StringList
									  },
						?send(Sid,proto:pack(Pt));				
					_ -> skip
				end				
		end,
	lists:foreach(Fun, UL);	
broadcast_to_scene(_,_) -> ok.

get_guild_copy_rewards(Scene)->
	case data_guild_copy:select(Scene)of
		[DungeonID|_]->
			case data_guild_copy:get_data(DungeonID) of
				#st_data_guild_copy{first_struck=DropcontentId}->
					fun_draw:box(DropcontentId, 0);
				_->[]
			end;
		_->[]
	end.
s_get_usr_lev(Uid)->
	case fun_scene_obj:get_obj(Uid) of
		#scene_spirit_ex{data=#scene_usr_ex{lev=Lev}} -> Lev;
		#scene_spirit_ex{data=#scene_entourage_ex{lev=Lev}} -> Lev;
		#scene_spirit_ex{data=#scene_monster_ex{lev=Lev}} -> Lev;
		_->0
	end.

s_get_usr_legendary_lev(Uid)->
	case fun_scene_obj:get_obj(Uid) of
		#scene_spirit_ex{data=#scene_usr_ex{paragon_level = Lev}} -> Lev;
		#scene_spirit_ex{data=#scene_robot_ex{paragon_level = Lev}} -> Lev;
		_ -> 0
	end.

robot_enter_scene(Obj,Pos1,Pos2,EntourageData,Dir) ->
	robot_enter_scene(Obj,Pos1,Pos2,EntourageData,Dir, undefined).
robot_enter_scene(Obj,Pos1,Pos2,EntourageData,Dir,HeroAttrAdd) ->
	% ?debug("RobotPos=~p~n",[RobotPos]),
	NID = fun_scene_obj:get_obj_id(),
	case NID of
		no -> ?log_error("please check obj id~n"),skip;
		_ ->
			Moudle = util:to_atom("ai_robot"),
			AiData =
				try
					Moudle:init(get(scene),NID,Pos2)
				catch _E:_R -> ?log_error("ai error Moudle=~p",[Moudle]),{}
			end,
			Pos = tool_vect:to_map_point(Pos2),
			NPos = case fun_scene_map:check_point(Pos) of
				{true,_,YPoint} -> tool_vect:to_point(YPoint);
				_ -> no
			end,
			case NPos of
				no -> ?log_warning("add robot in wrong position,Pos=~p", [Pos]);
				_ ->
					RobotData=Obj#scene_spirit_ex.data,
					fun_scene_obj:add_robot(Obj#scene_spirit_ex{id=NID,pos=NPos,sort=?SPIRIT_SORT_ROBOT},RobotData#scene_robot_ex{ai_module=Moudle,ai_data=AiData}),
					PosList = util_scene:get_point(Pos1, Pos2),
					Fun1 = fun({EntourageInfo,Battle0,EntourageSkill,PassiveSkillList,PosIndex}) ->
						EnID = fun_scene_obj:get_obj_id(),
						case EnID of
							no -> ?log_error("please check obj id~n"),skip;
							_ ->
								%%创建佣兵
								NewPos = lists:nth(PosIndex, PosList),
								Scene = get(scene),
								Battle = fun_property:add_attrs_to_property_ex(Battle0, HeroAttrAdd),
								% ?debug("Scene = ~p",[Scene]),
								Hp = case data_scene_config:get_scene(Scene) of
									#st_scene_config{sort = ?DUNGEONS_TYPE_WORLDBOSS} -> 100000000;
									_ -> Battle#battle_property.hpLimit
								end,
								% ?debug("Hp = ~p",[Hp]),
								Spirit = #scene_spirit_ex{id=EnID,dir=Dir,camp=Obj#scene_spirit_ex.camp,speed=60,pos=NewPos,
															hp=Hp,mp=Battle#battle_property.mpLimit,final_property=Battle#battle_property{hpLimit = Hp},
															passive_skill_data = PassiveSkillList},
								Entourage = #scene_entourage_ex{type = EntourageInfo#item.type,
																lev = EntourageInfo#item.lev,
																star = EntourageInfo#item.star,
																skills = EntourageSkill,
																owner_id= NID,is_robot=true},
								% ?debug("EntourageSkill=~p~n",[EntourageSkill]),
								EnFun = fun({SkillType,SkillLev},{Acc1,Acc2}) ->
									case data_skillmain:get_skillmain(SkillType) of
										#st_skillmain_config{skillMode= "NORMALSKILL"} -> {Acc1,[{SkillType,SkillLev} | Acc2]};
										#st_skillmain_config{} -> {[{SkillType,SkillLev} | Acc1], Acc2};
										_ -> {Acc1,Acc2}
									end
								end,
								{Skills,GenSkill}=lists:foldl(EnFun, {[],[]}, EntourageSkill),
								% ?debug("{EL1,EL2,EL3,EL4,EL5}=~p~n",[{EL1,EL2,EL3,EL4,EL5}]),
								EnMoudle = util:to_atom("ai_entourage"),
								EnAiData =
									try
										EnMoudle:init(get(scene),EnID,NewPos)
									catch _EnE:_EnR -> ?log_error("ai error EnMoudle=~p",[EnMoudle]),{}
								end,
								% ?debug("Entourage=~p~n",[Entourage]),
								fun_scene_obj:add_entourage(Spirit, Entourage#scene_entourage_ex{ai_module=EnMoudle,ai_data=EnAiData,skills=Skills,general_skill=GenSkill}),									
								%%修改机器人记录的佣兵						
								case fun_scene_obj:get_obj(NID,?SPIRIT_SORT_ROBOT) of
									NewRobot=#scene_spirit_ex{data=NewRobotData} ->
										EnIDList = NewRobotData#scene_robot_ex.battle_entourage,
										fun_scene_obj:update(NewRobot#scene_spirit_ex{data=NewRobotData#scene_robot_ex{battle_entourage=[EnID|EnIDList]}});	
									_ -> skip
								end
						end
					end,
					lists:foreach(Fun1, EntourageData),
					{ok, NID}
			end
	end.
	
robot_move(Robot=#scene_spirit_ex{sort = ?SPIRIT_SORT_ROBOT,die=false,pos={RX,RY,RZ}}, Path) when erlang:length(Path) > 0 ->
	TargetSort = util_scene:server_obj_type_2_client_type(?SPIRIT_SORT_ROBOT),
	NPath= lists:append([{RX,RY,RZ}], Path),
	FunPath = fun({PX,PY,PZ}) ->
		#pt_public_point3{
			x = PX,
			y = PY,
			z = PZ
		}
	end,
	NPath1 = lists:map(FunPath, NPath),	
	Pt = #pt_scene_move{
		oid = Robot#scene_spirit_ex.id,
		obj_sort = TargetSort,
		dir = Robot#scene_spirit_ex.dir,
		point_list = NPath1
	},
	fun_scene_obj:send_cell_all_usr(Robot,proto:pack(Pt), 0),
	
	{X, Y, Z} = hd(Path),	
	Curr_mov_speed=fun_scene_obj:get_move_speed(Robot),
%% 	?debug("{RX,RY,RZ}=~p~n",[{RX,RY,RZ}]),
%% 	?debug("topos=~p~n",[{X, Y, Z}]),
%% 	?debug("Curr_mov_speed=~p~n",[Curr_mov_speed]),
	NextNeedTime = get_move_time(fun_scene_obj:get_pace_speed(Robot),Curr_mov_speed,Robot#scene_spirit_ex.pos, {X, Y, Z}),
	Dir = tool_vect:get_dir_angle(tool_vect:to_map_point({X - RX,0,Z - RZ})),
	Robot#scene_spirit_ex{demage_data = 0,skill_data = 0, dir = Dir,
							move_data =#move_data{start_time = util:longunixtime(),all_time = NextNeedTime,to_pos = {X, Y, Z},move_speed = Curr_mov_speed,next = []}}.

move_robot_entourage(Entourage=#scene_spirit_ex{sort=?SPIRIT_SORT_ENTOURAGE,die=false,pos={EX,EY,EZ}}, Path) when erlang:length(Path) > 0 ->
	TargetSort = util_scene:server_obj_type_2_client_type(?SPIRIT_SORT_ENTOURAGE),
	NPath= lists:append([{EX,EY,EZ}], Path),
	FunPath = fun({PX,PY,PZ}) ->
		#pt_public_point3{
			x = PX,
			y = PY,
			z = PZ
	}
	end,
	NPath1 = lists:map(FunPath, NPath),
	Pt = #pt_scene_move{
		oid 	 	= Entourage#scene_spirit_ex.id,
		obj_sort 	= TargetSort,
		dir 		= Entourage#scene_spirit_ex.dir,
		point_list  = NPath1
	},
	fun_scene_obj:send_cell_all_usr(Entourage,proto:pack(Pt), 0),
	{X, Y, Z} = hd(Path),	
	Curr_mov_speed=fun_scene_obj:get_move_speed(Entourage),
	NextNeedTime = get_move_time(fun_scene_obj:get_pace_speed(Entourage),Curr_mov_speed,Entourage#scene_spirit_ex.pos, {X, Y, Z}),
	Dir = tool_vect:get_dir_angle(tool_vect:to_map_point({X - EX,0,Z - EZ})),
	Entourage#scene_spirit_ex{demage_data = 0,skill_data = 0, dir = Dir,
							move_data =#move_data{start_time = util:longunixtime(),all_time = NextNeedTime,to_pos = {X, Y, Z},move_speed = Curr_mov_speed,next = []}}.

check_camp(UCamp,Camp)->
	if  Camp == 1->true;
		Camp == UCamp->true;
		true->false
	end.

%%玩家退出游戏操作
usr_logout_operate(Uid)->
	case fun_scene_obj:get_obj(Uid,?SPIRIT_SORT_USR) of
		#scene_spirit_ex{data=#scene_usr_ex{monster_list=MonstaerList}} ->
			delete_monster_list({Uid,2,MonstaerList}); 
%% 			erlang:start_timer(90*1000, self(), {?MODULE, delete_monster_list, {Uid,1,MonstaerList}});
		_R->skip
	end.
usr_logout_scene(Uid)->
	case fun_scene_obj:get_obj(Uid,?SPIRIT_SORT_USR) of
		#scene_spirit_ex{data=#scene_usr_ex{monster_list=MonstaerList}} ->
			delete_monster_list({Uid,2,MonstaerList});
		_->skip
	end.
%%删除怪物
delete_monster_list({Uid,Sort,MonstaerList})->
	case Sort of
		1->
			Fun = fun({Way,MonsterId}) ->
						  if Way == 0->
								  case fun_scene_obj:get_obj(MonsterId,?SPIRIT_SORT_MONSTER) of
									  #scene_spirit_ex{data=#scene_monster_ex{}} ->
										  delete_dart_task(Uid,Sort),
										  fun_interface:s_del_monster(MonsterId);
									  _->skip
								  end;
							 true->skip
						  end
				  end,
			lists:foreach(Fun, MonstaerList);
		_->
			Fun = fun({Way,MonsterId}) ->
						  if Way == 0->
								 case fun_scene_obj:get_obj(MonsterId,?SPIRIT_SORT_MONSTER) of
									 #scene_spirit_ex{data=#scene_monster_ex{}} ->
										 delete_dart_task(Uid,Sort),
										 fun_interface:s_del_monster(MonsterId);
									 _->skip
								 end;
							 true->skip
						  end
				  end,
			lists:foreach(Fun, MonstaerList)
	end.
delete_dart_task(Uid,Sort)->
	case Sort of
		1->ok;
%% 			case db:dirty_get(off_count, Uid, #off_count.uid) of
%% 				[OffCount = #off_count{}|_]->
%% 					db:dirty_put(OffCount#off_count{del_task_id=1});
%% 				_->
%% 					
%% 					db:insert(#off_count{uid=Uid,del_task_id=1})
%% 			end;
		_->
			case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
				#scene_spirit_ex{data = #scene_usr_ex{hid = AgentHid}} ->
					fun_scene_obj:agent_msg(AgentHid, {delete_dart_task,Uid});
%% 					 gen_server:cast(AgentHid, {delete_dart_task,Uid});
				_->skip
			end
	end.

add_alive_buff(Obj,Buffs)->
%%    ?debug("!!!!!!!!!!!!!!!~p",[Buffs]),
	Fun=fun(Buff,Res)-> fun_scene_buff:add_alive_buff(Res, Buff) end,
	lists:foldl(Fun, Obj, Buffs).

send_alive_buff(Obj,Buffs)->
%%  	?log_trace("!!!!!!!!!!!!!!!send_alive_buffs ~p",[Buffs]),
	Fun=fun(Buff)-> fun_scene_buff:send_alive_buff(Obj, Buff) end,
	lists:foreach(Fun, Buffs).

send_reconn_buff(#scene_spirit_ex{buffs=Buffs}=Obj)->
%% 	?log_trace("!!!!!!!!!!!!!!!send_reconn_buffs ~p",[Buffs]),
	Now=util:longunixtime(),
	Fun=fun(#scene_buff{start=Start,lenth=Length}=Old)-> 
				if  
					Length==0->fun_scene_buff:send_alive_buff(Obj, Old#scene_buff{start=Now,lenth=Length});
					true->
						if  
							Start+Length>Now->fun_scene_buff:send_alive_buff(Obj, Old#scene_buff{start=Now,lenth=Start+Length-Now});
							true->skip
						end
				
				end
		end,
	
	lists:foreach(Fun, Buffs).

add_say_notify({_MonID})->
	ok.

set_copy_progress(Progress) ->
	put(copy_progress, Progress).

get_copy_progress() ->
	case get(copy_progress) of
		undefined -> 0;
		P -> P
	end.

%%获取铭文所减的cd
get_inscription_del_cd(Uid,SkillId)->
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		#scene_spirit_ex{data=#scene_usr_ex{inscription_effects=InscriptionEffects}}->
			Fun = fun({SkillMainId,_Skilid,_Id,Lev,_Sort,_BuffType,_NewBaseatt},Acc)->
						  case lists:keyfind(SkillMainId, 1, Acc) of
							  {SkillMainId,Num}->
								  lists:keyreplace(SkillMainId, 1, Acc, {SkillMainId,Num+Lev});
							  _->lists:append(Acc, [{SkillMainId,Lev}])
						  end
				  end,
			NewCDlist = lists:foldl(Fun, [], InscriptionEffects),
			Fun1 = fun({SkillMainId,Num},Acc)->
						  case data_inscription_class:select_data(SkillMainId,Num) of
							  CD when is_number(CD)->
								  Acc ++ [{SkillMainId,CD/100}];
							  _->Acc
						  end
				  end,
			case lists:keyfind(SkillId, 1, lists:foldl(Fun1, [], NewCDlist)) of
				{_,CD}->CD;
				_->0
			end;
		_->0
	end.

is_all_monster_die() ->
	LeftMonsters = fun_scene_obj:get_ml(),
	LeftMonsters == [] orelse is_all_monster_die(LeftMonsters).

is_all_monster_die([]) -> true;
is_all_monster_die([LeftMonsters | Rest]) ->
	case LeftMonsters of
		#scene_spirit_ex{die = false} -> false;
		_ -> is_all_monster_die(Rest)
	end.