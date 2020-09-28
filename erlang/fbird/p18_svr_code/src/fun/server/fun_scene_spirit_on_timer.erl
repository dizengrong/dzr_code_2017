%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% author : Andy lee
%% date : 15/7/24 
%% Company : fbird
%% Desc : from  fun_scene:onTimer()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-module(fun_scene_spirit_on_timer).
-include("common.hrl").
-export([onTimer/3]).

-define(MOVETIME,200).

%% pick_move_data([]) -> {null,0};
%% pick_move_data([Data | Next]) -> {Data,Next};
%% pick_move_data(_) -> {null,0}.

process_pt(Usr = #scene_spirit_ex{sort = ?SPIRIT_SORT_USR},{Uid,Pt = #pt_scene_move{}}) ->
	PointList1 = Pt#pt_scene_move.point_list,
	PointList = [{PointData#pt_public_point3.x,PointData#pt_public_point3.y,PointData#pt_public_point3.z}  || PointData <- PointList1],
	% ?debug("Pt = ~p",[Pt]),
	scene:is_single_copy() orelse fun_scene_obj:send_cell_all_usr(Usr,proto:pack(Pt), Uid),
	Len = erlang:length(PointList),
	if
		Len >= 1 ->
			{[ClientPos] , MoveData}=lists:split(1, PointList),
			case fun_scene:move_player(Usr, {ClientPos,MoveData}) of  
				{ok, NewUsr} -> NewUsr;				
				_R -> Usr#scene_spirit_ex{dir = Pt#pt_scene_move.dir}
			end;
		true -> Usr#scene_spirit_ex{dir = Pt#pt_scene_move.dir}
	end;
%% 挂机项目的英雄走路优化，客户端说到哪里就到哪里，不做一步一步的移动处理了
process_pt(Entourage = #scene_spirit_ex{sort = ?SPIRIT_SORT_ENTOURAGE},{Uid,Pt = #pt_scene_move{}}) ->
	PointList1 = Pt#pt_scene_move.point_list,
	case PointList1 of
		[] -> Entourage#scene_spirit_ex{dir = Pt#pt_scene_move.dir};
		_  -> 
			scene:is_single_copy() orelse fun_scene_obj:send_cell_all_usr(Entourage,proto:pack(Pt), Uid),
			#pt_public_point3{x = ToX, y = ToY, z = ToZ} = lists:last(PointList1),
			case fun_scene_map:check_point(tool_vect:to_map_point({ToX, ToY, ToZ})) of 
				{true,_,#map_point{x=CrossX,y=CrossY,z=CrossZ}} -> 
					Dir = Pt#pt_scene_move.dir,
					Entourage#scene_spirit_ex{pos={CrossX,CrossY,CrossZ},dir=Dir,demage_data = 0,skill_data=0};
				_ -> 
					Entourage
			end
	end;
process_pt(Obj,_) -> Obj.

process_last_pt(Usr = #scene_spirit_ex{data = #scene_usr_ex{last_pt=0}}) -> Usr;
process_last_pt(Usr = #scene_spirit_ex{data = UsrData = #scene_usr_ex{last_pt=Last}}) -> 
	NUsr = process_pt(Usr,Last),
	NUsr#scene_spirit_ex{data = UsrData#scene_usr_ex{last_pt=0}};
process_last_pt(Entourage = #scene_spirit_ex{data = #scene_entourage_ex{last_pt=0}}) -> Entourage;
process_last_pt(Entourage = #scene_spirit_ex{data = EntourageData = #scene_entourage_ex{last_pt=Last}}) -> 
	NEntourage = process_pt(Entourage,Last),
	NEntourage#scene_spirit_ex{data = EntourageData#scene_entourage_ex{last_pt=0}};
process_last_pt(Obj) -> Obj.

onTimer(Spirit,Now,Scene) ->
	NewSpirit =
		if
			Spirit#scene_spirit_ex.die == true -> Spirit;
			true ->
				SpiritPt = process_last_pt(Spirit),
				SpiritCD = fun_scene_cd:update_skill_cd(SpiritPt,Now),
				SpiritBuff = fun_scene_buff:process_buff_skill(SpiritCD,Now),
				{Continue0,SpiritAleret} = if
					Spirit#scene_spirit_ex.skill_aleret_data == 0 -> {true,SpiritBuff};
					true -> {false,process_skill_aleret(SpiritBuff,Now)}
				end,
				{Continue1,SpiritDemage} = if
					Continue0 == false -> {false,SpiritAleret};
					Spirit#scene_spirit_ex.demage_data == 0 -> {true,SpiritAleret};
					true -> {false,process_demage(SpiritAleret,Now)}
				end,
				{Continue2,SpiritSkill1} = if
					Continue1 == false -> {false,SpiritDemage};
					Spirit#scene_spirit_ex.skill_data == 0 -> {true,SpiritDemage};
					true -> {false,process_skill(SpiritDemage,Now)}
				end,
				SpiritSkill = case fun_scene_map:process_cell(SpiritSkill1) of
					{ok,NewMapCell} -> 
						SpiritSkill1#scene_spirit_ex{map_cell = NewMapCell};
					_R -> 
						SpiritSkill1
				end,
				% case Spirit#scene_spirit_ex.sort == ?SPIRIT_SORT_MONSTER of
				% 	true ->
				% 		?DBG(Continue2),
				% 		?DBG(Spirit#scene_spirit_ex.move_data);
				% 	_ -> skip
				% end,
				if
					Continue2 == true ->
						SpiritMove = if
							Spirit#scene_spirit_ex.move_data == 0 -> SpiritSkill;
							true -> process_move(SpiritSkill,Now,Scene)
						end,
						if
							SpiritMove#scene_spirit_ex.sort == ?SPIRIT_SORT_MONSTER orelse SpiritMove#scene_spirit_ex.sort == ?SPIRIT_SORT_ROBOT -> 
								Bt = fun_scene_obj:is_obj_yz(SpiritMove),
								Jz = fun_scene_obj:is_obj_jz(SpiritMove),
								if
									Bt == true -> SpiritMove;
									Jz == true -> SpiritMove;
									true -> 
										IsStun=fun_scene_buff:is_stun(SpiritMove#scene_spirit_ex.buffs),
										IsSleep=fun_scene_buff:is_sleep(SpiritMove#scene_spirit_ex.buffs),
										IsBanish=fun_scene_buff:is_banish(SpiritMove#scene_spirit_ex.buffs),
										if
											IsStun == true -> SpiritMove;
											IsSleep == true -> SpiritMove;
											IsBanish == true -> SpiritMove; 
											true ->	process_ai(SpiritMove,Now)	
										end								
								end;										
							SpiritMove#scene_spirit_ex.sort == ?SPIRIT_SORT_ENTOURAGE andalso SpiritMove#scene_spirit_ex.data#scene_entourage_ex.is_robot == true ->
								Bt = fun_scene_obj:is_obj_yz(SpiritMove),
								Jz = fun_scene_obj:is_obj_jz(SpiritMove),
								if
									Bt == true -> SpiritMove;
									Jz == true -> SpiritMove;
									true -> 
										IsStun=fun_scene_buff:is_stun(SpiritMove#scene_spirit_ex.buffs),
										IsSleep=fun_scene_buff:is_sleep(SpiritMove#scene_spirit_ex.buffs),
										IsBanish=fun_scene_buff:is_banish(SpiritMove#scene_spirit_ex.buffs),
										if
											IsStun == true -> SpiritMove;
											IsSleep == true -> SpiritMove;
											IsBanish == true -> SpiritMove; 
											true ->	process_ai(SpiritMove,Now)	
										end								
								end;								
							true -> SpiritMove
						end;
					true -> SpiritSkill
				end
		end,
	process_on_time(NewSpirit,Now,Scene).

process_skill_aleret(Spirit = #scene_spirit_ex{skill_aleret_data = SkillAleretData},Now) ->
%% 	?debug("process_skill_aleret,SkillAleretData = ~p",[SkillAleretData]),
	case SkillAleretData of
		#skill_aleret_data{start_time = StartTime,all_time = AllTime,point = Pos,skill_data = Data} ->
			if
				Now > StartTime + AllTime -> 
					case Data of
						{OTargetID,OTargetPos,{OSkill,OLev}} ->
							NewSpirit = fun_scene_skill:skill_by_aleret(Spirit,OTargetID,OTargetPos,{OSkill,OLev},Pos),
							NewSpirit#scene_spirit_ex{skill_aleret_data = 0};
						_ -> Spirit#scene_spirit_ex{skill_aleret_data = 0}
					end;
				true -> Spirit
			end;
		_->Spirit
	end.			
  
process_demage(Spirit = #scene_spirit_ex{demage_data = DemageData},Now) ->
	case DemageData of
		#demage_data{start_time = StartTime, jz_time = JzTime,move_start = MoveStart,move_speed = MoveSpeed,move_data = MoveData} -> 
			case MoveData of
				#move_data{} -> 
					if
						Now > StartTime + MoveStart ->
							case process_move_data(Now,Spirit#scene_spirit_ex.pos,Spirit#scene_spirit_ex.dir,fun_scene_obj:get_pace_speed(Spirit),MoveSpeed,MoveData) of
								{ToPos,ToDiR,NextData} -> 
									Spirit#scene_spirit_ex{pos = ToPos,dir = ToDiR,demage_data = DemageData#demage_data{move_data = NextData}};
								_ -> Spirit#scene_spirit_ex{demage_data = 0}
							end;
						true -> Spirit
					end;
				_ -> 
					if
						Now > StartTime + JzTime -> Spirit#scene_spirit_ex{demage_data = 0};
						true -> Spirit
					end
			end;
		_ -> Spirit#scene_spirit_ex{demage_data = 0}
	end.
process_skill(Spirit = #scene_spirit_ex{skill_data = SkillData},Now) ->
	case SkillData of
		#skill_data{start_time = StartTime,yz_start = YzStart, yz_time = YzTime,bt_start = BtStart, bt_time = BtTime,wd_start = WdStart, wd_time = WdTime,move_speed = MoveSpeed,move_data = MoveData} ->
			case MoveData of
				#move_data{} -> 
					case process_move_data(Now,Spirit#scene_spirit_ex.pos,Spirit#scene_spirit_ex.dir,fun_scene_obj:get_pace_speed(Spirit),MoveSpeed,MoveData) of
						{ToPos,ToDiR,NextData} -> Spirit#scene_spirit_ex{pos = ToPos,dir = ToDiR,skill_data = SkillData#skill_data{move_data = NextData}};
						_ -> Spirit#scene_spirit_ex{skill_data = 0}
					end;
				_ -> 
					if
						Now > StartTime + YzStart + YzTime andalso Now > StartTime + BtStart + BtTime andalso Now > StartTime + WdStart + WdTime  -> Spirit#scene_spirit_ex{skill_data = 0};
						true -> Spirit
					end
			end;
		_ -> Spirit#scene_spirit_ex{skill_data = 0}
	end.
process_move(Spirit = #scene_spirit_ex{sort=?SPIRIT_SORT_USR,move_data = MoveData},Now,_Scene) ->
	case MoveData of
		#move_data{} -> 
			case process_move_data(Now,Spirit#scene_spirit_ex.pos,Spirit#scene_spirit_ex.dir,fun_scene_obj:get_pace_speed(Spirit),fun_scene_obj:get_move_speed(Spirit),MoveData) of
				{ToPos,ToDiR,NextData} ->
%% 					move_action(Spirit,Scene),
					TransPos=fun_scene_item_event:fun_move_event_handler(Spirit#scene_spirit_ex.id,Spirit#scene_spirit_ex.sort,Spirit#scene_spirit_ex.pos),
					case TransPos of
						no -> Spirit#scene_spirit_ex{pos = ToPos,dir = ToDiR,move_data = NextData};
						_ -> Spirit#scene_spirit_ex{pos = TransPos,move_data = 0}
					end;
				_ -> Spirit#scene_spirit_ex{move_data = 0}
			end;
		_ -> Spirit#scene_spirit_ex{move_data = 0}
	end;
process_move(Spirit = #scene_spirit_ex{move_data = MoveData},Now,_Scene) ->
	case MoveData of
		#move_data{} -> 
			case process_move_data(Now,Spirit#scene_spirit_ex.pos,Spirit#scene_spirit_ex.dir,fun_scene_obj:get_pace_speed(Spirit),fun_scene_obj:get_move_speed(Spirit),MoveData) of
				{ToPos,ToDiR,NextData} ->
					fun_scene_item_event:fun_move_event_handler(Spirit#scene_spirit_ex.id,Spirit#scene_spirit_ex.sort,Spirit#scene_spirit_ex.pos),
					Spirit#scene_spirit_ex{pos = ToPos,dir = ToDiR,move_data = NextData};
				_ -> Spirit#scene_spirit_ex{move_data = 0}
			end;
		_ -> Spirit#scene_spirit_ex{move_data = 0}
	end.
process_ai(Robot = #scene_spirit_ex{sort=?SPIRIT_SORT_ROBOT},Now) ->
	if
		Robot#scene_spirit_ex.data#scene_robot_ex.ai_time < Now ->
			RobotAi = fun_scene_obj:put_robot_spc_data(Robot, ai_time, Now),
			Moudle = RobotAi#scene_spirit_ex.data#scene_robot_ex.ai_module,
			case Moudle of
				no -> RobotAi;
				_ ->
					try
						case Moudle:do_ai(RobotAi, RobotAi#scene_spirit_ex.pos, RobotAi#scene_spirit_ex.data#scene_robot_ex.shenqi_skill, RobotAi#scene_spirit_ex.data#scene_robot_ex.ai_data, Now) of
							{ok,_} -> RobotAi;
							AIData ->
								OldData=RobotAi#scene_spirit_ex.data,
								RobotAi#scene_spirit_ex{data = OldData#scene_robot_ex{ai_data = AIData},skill_data = 0}
						end
					catch E:R -> ?log_error("\nai error Moudle=~p,Robot1=~w,E=~p,R=~p\nstacktrace=~p",[Moudle,Robot,E,R,erlang:get_stacktrace()]),RobotAi
					end
			end;
		true -> Robot
	end;
process_ai(Entourage = #scene_spirit_ex{pos=_EnPos,sort=?SPIRIT_SORT_ENTOURAGE},Now) ->
	if				
		Entourage#scene_spirit_ex.data#scene_entourage_ex.ai_time < Now ->
			EntourageAi = fun_scene_obj:put_entourage_spc_data(Entourage, ai_time, Now),
			Moudle = EntourageAi#scene_spirit_ex.data#scene_entourage_ex.ai_module,
			case Moudle of
				no -> EntourageAi;
				_ ->
					Moving = if
						EntourageAi#scene_spirit_ex.move_data == 0 -> false;
						true -> true
					end,
					try
						case Moudle:do_ai(EntourageAi#scene_spirit_ex.pos, Moving, EntourageAi#scene_spirit_ex.data#scene_entourage_ex.ai_data) of
							{atk,SkillData,TargetID,Dir,TargetPos,AIData} ->
								SkillEntourageDir = EntourageAi#scene_spirit_ex{dir = Dir},
								case fun_scene:robot_entourage_skill(SkillEntourageDir,SkillData,TargetID,TargetPos) of	
									SkillEntourage = #scene_spirit_ex{data=OldData} ->
										SkillEntourage#scene_spirit_ex{move_data=0,data=OldData#scene_entourage_ex{ai_data = AIData},dir = Dir};
									_ -> SkillEntourageDir
								end;
							{move,Pos,AIData} ->
								MoveE = fun_scene:move_robot_entourage(EntourageAi, [Pos]),
								OldData=MoveE#scene_spirit_ex.data,
								MoveE#scene_spirit_ex{data = OldData#scene_entourage_ex{ai_data = AIData}};
							AIData ->
								OldData=EntourageAi#scene_spirit_ex.data,
								EntourageAi#scene_spirit_ex{data = OldData#scene_entourage_ex{ai_data = AIData},skill_data=0}
						end
					catch E:R -> ?log_error("\nai error Moudle=~p,Entourage=~w,E=~p,R=~p\nstacktrace=~p",[Moudle,Entourage,E,R,erlang:get_stacktrace()]),EntourageAi
					end
			
			end;
		true -> Entourage
	end;
%% process_ai(Monster = #scene_spirit_ex{sort=?SPIRIT_SORT_MONSTER,data = #scene_monster_ex{} = OldData},Now) ->
process_ai(Monster = #scene_spirit_ex{sort=?SPIRIT_SORT_MONSTER},Now) ->
	if				
		Monster#scene_spirit_ex.data#scene_monster_ex.ai_time < Now andalso Monster#scene_spirit_ex.data#scene_monster_ex.allow_control == true->
			MonsterAi = fun_scene_obj:put_monster_spc_data(Monster, ai_time, Now),
			Moudle = MonsterAi#scene_spirit_ex.data#scene_monster_ex.ai_module,
			case Moudle of
				no -> MonsterAi;
				_ ->
					Moving = if
						MonsterAi#scene_spirit_ex.move_data == 0 -> false;
						true -> true
					end,
					try
						case Moudle:do_ai(MonsterAi, Moving, MonsterAi#scene_spirit_ex.data#scene_monster_ex.ai_data) of
							{atk,Skill,TargetID,Dir,TargetPos,AIData} ->
								SkillMonsterDir = MonsterAi#scene_spirit_ex{dir = Dir},
								case fun_scene:monster_skill(SkillMonsterDir,Skill,TargetID,Dir,TargetPos) of
									SkillMonster = #scene_spirit_ex{data=OldData} ->
										SkillMonster#scene_spirit_ex{move_data=0,data=OldData#scene_monster_ex{ai_data = AIData},dir = Dir};
									_ -> SkillMonsterDir
								end;
							{move,Pos = {_X,_Y,_Z},AIData}  ->
								M = fun_scene:move_monster(MonsterAi, [Pos]),
								fun_scene_obj:put_monster_spc_data(M, ai_data, AIData);
							{boss_back,AIData} ->%%恢复BOSS的血量
								OldData=MonsterAi#scene_spirit_ex.data,
								M=MonsterAi#scene_spirit_ex{data=OldData#scene_monster_ex{ai_data = AIData,demage_list=[]}},
								Battle = Monster#scene_spirit_ex.final_property,
								MaxHp = Battle#battle_property.hpLimit,
								M#scene_spirit_ex{hp=MaxHp};
							AIData -> 
								M=fun_scene_obj:put_monster_spc_data(MonsterAi, ai_data, AIData),
								M#scene_spirit_ex{skill_data=0}
						end
					catch E:R -> 
						?EXCEPTION_LOG(E,R,do_ai,Monster),
						MonsterAi
					end
			end;
		true -> Monster
	end.

process_move_data(Now,CurPos,CurDir,PaceSpeed,CurMoveSpeed,MoveData = #move_data{start_time = StartTime,all_time = AllTime,to_pos = ToPos,move_speed = MoveSpeed,next = Next}) -> 
	if
		AllTime < ?MOVETIME orelse Now > (StartTime + AllTime) -> 
			{NextPos,NNext} = fun_scene:pick_move_data(Next),
			case NextPos of
				null ->		
					{reset_y(ToPos),CurDir,0};
				_ ->	
					NextNeedTime = fun_scene:get_move_time(PaceSpeed,CurMoveSpeed,ToPos,NextPos),
					VextDir = tool_vect:to_map_point(tool_vect:dec(tool_vect:to_map_point(NextPos) , tool_vect:to_map_point(ToPos))),
					NMDir = tool_vect:get_dir_angle(VextDir#map_point{y = 0}),
					{reset_y(ToPos),NMDir,#move_data{start_time = StartTime + AllTime,all_time = NextNeedTime,to_pos = tool_vect:to_point(NextPos),move_speed = CurMoveSpeed,next = NNext}}
			end;
		Now < StartTime + ?MOVETIME -> 
			{CurPos,CurDir,MoveData};
		true ->
			Pass = Now - StartTime,
			AddVect = tool_vect:ride(tool_vect:dec(tool_vect:to_map_point(ToPos) , tool_vect:to_map_point(CurPos)),Pass / AllTime),
			AtPos1 = tool_vect:add(tool_vect:to_map_point(CurPos), AddVect),
			AtPos = {AtPos1#map_point.x,AtPos1#map_point.y,AtPos1#map_point.z},
			if
				MoveSpeed == CurMoveSpeed -> 
					{reset_y(AtPos),CurDir,MoveData#move_data{start_time = Now,all_time = AllTime - Pass}};
				true -> 
					NextNeedTime = fun_scene:get_move_time(PaceSpeed,CurMoveSpeed,AtPos,ToPos),
					{reset_y(AtPos),CurDir,MoveData#move_data{start_time = Now,all_time = NextNeedTime,move_speed = CurMoveSpeed}}
			end
	end.

process_on_time(Spirit,Now,Scene) ->
	if
		Spirit#scene_spirit_ex.sort == ?SPIRIT_SORT_MONSTER ->
			if
				Spirit#scene_spirit_ex.data#scene_monster_ex.ontime_off > 0 ->
					NewCheckTime =
						if
							Now - Spirit#scene_spirit_ex.data#scene_monster_ex.ontime_check > Spirit#scene_spirit_ex.data#scene_monster_ex.ontime_off ->
								OntimeMoudle = Spirit#scene_spirit_ex.data#scene_monster_ex.script,
								CurrHp=Spirit#scene_spirit_ex.hp,MaxHp=Spirit#scene_spirit_ex.data#scene_monster_ex.max_hp,
								try
									OntimeMoudle:on_time(Scene,Spirit#scene_spirit_ex.data#scene_monster_ex.type,Spirit#scene_spirit_ex.id - ?OBJ_OFF,CurrHp,MaxHp,Now - Spirit#scene_spirit_ex.data#scene_monster_ex.ontime_start)
								catch
									E1:R1 -> ?log_error("monster ontime script error Scene=~p,E=~p,R=~p,stack=~p",[{Scene,Spirit#scene_spirit_ex.data#scene_monster_ex.type,Spirit#scene_spirit_ex.id},E1,R1,erlang:get_stacktrace()])
								end,
								Now;
							true -> Spirit#scene_spirit_ex.data#scene_monster_ex.ontime_check
						end,
					fun_scene_obj:put_monster_spc_data(Spirit, ontime_check, NewCheckTime);
				true -> Spirit
			end;
		Spirit#scene_spirit_ex.sort == ?SPIRIT_SORT_ITEM ->
			if
				Now - Spirit#scene_spirit_ex.data#scene_item_ex.ontime_check > 1000 ->
					TL=fun_scene_item_event:on_time(Spirit),					
					NewSpirit=fun_scene_obj:put_item_spc_data(Spirit, trigger_list, TL),
					fun_scene_obj:put_item_spc_data(NewSpirit, ontime_check, Now);
				true -> Spirit
			end;
		Spirit#scene_spirit_ex.sort == ?SPIRIT_SORT_USR ->
			PentaKillTime=Spirit#scene_spirit_ex.data#scene_usr_ex.penta_kill_time,
			if
				Now - PentaKillTime > 30000 ->
%% 					?debug("---------------process_on_time,Now=~p,PentaKillTime=~p",[Now,PentaKillTime]),
					NewSpirit=fun_scene_obj:put_usr_spc_data(Spirit,penta_kill,0),
					fun_scene_obj:put_usr_spc_data(NewSpirit,penta_kill_time,Now);
				true -> Spirit				
			end;
		true -> Spirit
	end.

reset_y(Pos) ->
	case fun_scene_map:check_point(tool_vect:to_map_point(Pos)) of
		{true,_,#map_point{x=CX,y=CY,z=CZ}} -> {CX,CY,CZ};
		_ -> Pos									
	end.			

%% move_action(#scene_spirit_ex{id=Uid,sort=?SPIRIT_SORT_USR, pos=Pos},Scene) ->
%% 	fun_scene:updata_task_list(Uid, ?TASK_MOVE_POS,Scene,Pos);
%% move_action(_Obj,_Scene) -> skip.


