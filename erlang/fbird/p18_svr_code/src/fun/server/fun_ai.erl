%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% author : Andy lee
%% date : 15/7/27 
%% Company : fbird
%% Desc : 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-module(fun_ai).
-include("common.hrl").

-export([check_create/3,check_chase/4,check_back/2,check_atk/6,check_impact/4,check_fear/1,check_sneered/1,check_impact_monster/2]).
-export([get_create_need_time/1,chase/6,back/6,atk/2,impact/6]).
-export([atk_tag/4,atk_tag_dir/4,fear/5,sneered/5,find_rand_point/3,ai_find_dir/3,ai_find_dir/5,check_obj_can_demage/1,get_new_point/2]).

-define(DEFAULT_FREE_RANG,3).
-define(CHECK_FREE,2).
-define(ESCAPE_DISTANCE,3).

get_create_need_time(Type) ->
	case data_monster:get_monster(Type) of
		#st_monster_config{bornTime=BornTime} -> BornTime;
		_ -> 1500	 
	end.

%%感知范围内
ai_find_feel(#scene_spirit_ex{id = AtkOid, camp = Camp, pos = {Rx,_,Rz}}, CollRelation, SkillAi)->
	List = fun_new_ai:get_orign_target_list(),
	Fun = fun(#scene_spirit_ex{id = EnemyId, camp = MCamp, die=Die}) -> 
		if
			Die == true -> false;
			true ->
				case fun_scene_collect_obj:match_collect_obj_relation(CollRelation, {AtkOid, EnemyId, Camp, MCamp, get(scene)}) of
					true -> true;
					_ -> false
				end
		end
	end,
	FilterList = lists:filter(Fun, List),
	if
		length(FilterList) > 0 ->
			NewList = fun_scene_collect_obj:collect_obj_help(FilterList, all, SkillAi),
			Fun1 = fun(#scene_spirit_ex{id=Oid,pos={X,_,Z}},{OldDis,OldId}) ->
				Dis = tool_vect:lenght(tool_vect:to_map_point({X - Rx, 0, Z - Rz})),
				if
					OldDis == 0 -> {Dis,Oid};
					true ->
						if
							OldDis > Dis -> {Dis,Oid};
							true -> {OldDis,OldId}
						end
				end
			end,
			case lists:foldl(Fun1,{0,0},NewList) of
				{0,0} -> 0;
				{_D,ObjId} -> ObjId
			end;
		true -> 0
	end.

%%视线范围内
% ai_find_view(Id)->
% %% 	?debug("ai_find_view,Id=~p~n",[Id]),
% 	Scene = get(scene),
% 	case fun_scene_obj:get_obj(Id,?SPIRIT_SORT_MONSTER) of
% 		#scene_spirit_ex{pos={Mx,My,Mz},dir=Dir,camp=Camp,data=#scene_monster_ex{type=Type}} ->
% 			case data_monster:get_monster(Type) of
% 				#st_monster_config{view=View,view_range=View_Range} ->
% 					case fun_scene_map:collect_obj( {sector,Id,{Mx,My,Mz},Dir,[View,0,View_Range,0,0,3,3] }, Camp, Scene) of
% 						[] -> no;
% 						List ->
% %% 							?debug("@@@@@@@@@@@@@@@@@@@ai_find_view collect_obj list=~p~n",[List]),
% 							Fun=fun(Obj,{OldDis,OldId}) ->
% 										  case Obj of
% 											  #scene_spirit_ex{id=Oid,pos={X,_,Z}} ->
% 												  Dis = tool_vect:lenght(tool_vect:to_map_point({X-Mx, 0, Z-Mz})),
% 												  if
% 													  OldDis == 0 -> {Dis,Oid};
% 													  true ->
% 														  if
% 															  OldDis > Dis -> {Dis,Oid};
% 															  true -> {OldDis,OldId}
% 														  end
% 												  end;
% 											  _ ->  {OldDis,OldId}
% 										  end
% 								  end,
% 							case lists:foldl(Fun,{0,0}, List) of
% 								{0,0} -> no;
% 								{_D,ObjId} -> ObjId
% 							end
% 					end;
% 				_ -> no
% 			end;
% 		_ -> no
% 	end.

ai_find_dir(Range,PM,PT,Moving,MoveDir) ->	
	case ai_find_dir(Range,PM,PT) of
		{Dir,ToPoint} ->
			Do = case Moving of
				true ->
					case MoveDir of
						no -> true;
						_ -> 
							DirOff = util:abs(Dir - MoveDir),
							if
								DirOff < 15 -> false;
								true -> true
							end
					end;
				_ -> true
			end,
			case Do of
				false -> no;
				_ -> {walk,Dir,ToPoint}
			end;
		_ -> no	
	end.

ai_find_dir(Range,Pm,Pt) ->
	DirVect = tool_vect:dec(tool_vect:to_map_point(Pt),tool_vect:to_map_point(Pm)),
	Dir = tool_vect:get_dir_angle(DirVect),
	LenPow = tool_vect:lenght_power(DirVect),
	if
		LenPow < 0.001 -> false;
		true ->
			case ai_check_dir(tool_vect:to_map_point(Pm),tool_vect:to_map_point(Pt),Range) of
				{ok,CrossPoint} -> 
					{Dir,tool_vect:to_point(CrossPoint)};
				_R -> 
					Dirs = [Dir + 45,Dir + 90,Dir - 45,Dir - 90,Dir + 135,Dir - 135,Dir + 180],
					case ai_new_check_dirs(tool_vect:to_map_point(Pm),Dirs) of
						{ok,ThisDir,CrossPoint} -> 
							{ThisDir,tool_vect:to_point(CrossPoint)};
						_R1 -> 
							no
					end
			end
	end.

ai_check_dir(Pm,Pt,Range) ->
	DirVect = tool_vect:dec(Pt,Pm),
	NormalDir = tool_vect:normal(DirVect),
	case fun_scene_map:check_dir(Pm,tool_vect:dec(Pt, tool_vect:ride(NormalDir, Range))) of
		{find,Len,CrossPoint} -> 
			if
				Len > 0.1 -> {ok,CrossPoint};
				true -> fail
			end;
		_R -> 
			fail
	end.

ai_new_check_dirs(_Pm,[]) -> no;
ai_new_check_dirs(Pm,[ThisDir | Nexts]) ->
	case ai_new_check_dir(Pm,ThisDir) of
		{ok,CrossPoint} -> {ok,ThisDir,CrossPoint};
		_R ->
			ai_new_check_dirs(Pm,Nexts)
	end.
	
ai_new_check_dir(Pm,Dir) ->
	case fun_scene_map:check_dir(Pm,tool_vect:get_vect_by_dir(Dir) , 10) of
		{find,Len,CrossPoint} -> 
			if
				Len > 0.1 -> {ok,CrossPoint};
				true -> fail
			end;
		_R ->
			fail
	end.

find_rand_point({X,Y,Z},RX,RZ) ->
	X1=util:ceil(X), Z1=util:ceil(Z),
	NX=util:rand(X1-RX,X1+RX),	NZ=util:rand(Z1-RZ,Z1+RZ),
	{NX,Y,NZ}.

check_fear(ID) ->
	case fun_scene_obj:get_obj(ID) of
		#scene_spirit_ex{buffs=Buffs} ->
			case fun_scene_buff:is_fear(Buffs) of
				true -> true;
				_ -> false	
			end;
		_ -> false
	end.

check_sneered(ID) ->
	case fun_scene_obj:get_obj(ID) of
		#scene_spirit_ex{buffs=Buffs} ->
			case fun_scene_buff:is_sneered(Buffs) of
				true -> true;
				_ -> false	
			end;
		_ -> false
	end.	

%% check_obj_can_demage(#scene_spirit_ex{die=true}) -> false;
check_obj_can_demage(_Obj) -> true.

check_impact_monster(ID,{X,Y,Z}) -> check_impact_monster(ID,{X,Y,Z},all).
check_impact_monster(ID,{X,_Y,Z},_Dir) ->
	case mod_scene_monster:has_other_monster_in_pos(ID, X, Z) of
		false -> no;
		{true, FindMonsterOid} -> fun_scene_obj:get_obj(FindMonsterOid,?SPIRIT_SORT_MONSTER)
	end.

%% 时间过去就free
check_create(Id,Type,CreateTime) -> 
	Now = util:longunixtime(),
	NeedTime = fun_ai:get_create_need_time(Type),
	if
		CreateTime  + NeedTime < Now -> check_create_help(Id,Type);
		true -> continue
	end.

check_create_help(ID,Type) ->
	case fun_scene_obj:get_obj(ID,?SPIRIT_SORT_MONSTER) of
		Object = #scene_spirit_ex{die = false, pos = Pos} ->
			case fun_ai:check_impact_monster(ID,Pos) of
				no -> 
					case atk(ID, Type) of
						{atk, SkillType} ->
							#st_skillperformance_config{targetType=SkillTargetType,skill_ai=SkillAi} = data_skillperformance:get_skillperformance(SkillType),
							CollRelation = fun_scene_skill:get_relation_by_skill(SkillTargetType),
							case ai_find_feel(Object, CollRelation, SkillAi) of
								0 -> continue;
								Oid -> {chase,Oid}
							end;
						_ -> continue
					end;
				_ -> impact
			end;
		_ -> continue
	end.	

%%先测试回归 %%回归先删除
%%再测试恐惧
%%继续测试嘲讽
check_chase(ID,_Type,{Mx,My,Mz},Target) ->
	case check_chase_help(ID,Target) of
		{true, Buffs} ->
			% CheckBack=case data_monster:get_monster(Type) of
			% 			  #st_monster_config{returnRange=Ret_Range} ->
			% 				  Dis = tool_vect:lenght(tool_vect:to_map_point({Mx-Bx, 0, Mz-Bz})),
			% 				  if
			% 					  Dis > Ret_Range -> back;%%最高级回归
			% 					  true -> go
			% 				  end;
			% 			  _ -> go
			% 		  end,
			case check_fear(ID) of%%优先恐惧
				true -> fear;
				_ ->
					Check = case check_sneered(ID) of%%其次嘲讽
						true ->
							Sneereds = fun_scene_buff:get_sneered_buff(Buffs),
							NewTag = if  
								length(Sneereds) > 0 ->
									#scene_buff{buff_adder=Adder}=lists:nth(1, Sneereds),Adder;
								true -> Target
							end,
							if
								Target =/= NewTag -> {chase,NewTag};
								true -> continue
							end;
						_ -> continue
					end,
					case Check of
						continue ->
							case check_impact_monster(ID,{Mx,My,Mz}) of	
								no -> continue;
								_ -> impact
							end;
						_ -> Check
					end
			end;
		{chase, Oid} ->
			{chase, Oid};
		_ -> continue
	end.

check_chase_help(ID,Target) ->
	case fun_scene_obj:get_obj(ID,?SPIRIT_SORT_MONSTER) of
		Object = #scene_spirit_ex{buffs=Buffs, die = false, data = #scene_monster_ex{type = Type}} ->
			case fun_scene_obj:get_obj(Target) of
				#scene_spirit_ex{die=false} ->
					{true, Buffs};
				_ ->
					case atk(ID, Type) of
						{atk, SkillType} ->
							#st_skillperformance_config{targetType=SkillTargetType,skill_ai=SkillAi} = data_skillperformance:get_skillperformance(SkillType),
							CollRelation = fun_scene_skill:get_relation_by_skill(SkillTargetType),
							case ai_find_feel(Object, CollRelation, SkillAi) of
								0 -> continue;
								Oid -> {chase,Oid}
							end;
						_ -> continue
					end
			end;
		_ -> continue
	end.

%% 回到出生点附近
check_back({Mx,_My,Mz},{Bx,_By,Bz}) ->
	Dis = tool_vect:lenght(tool_vect:to_map_point({Mx-Bx, 0, Mz-Bz})),
	if
		Dis  < 2 -> free;
		true -> continue
	end.

check_atk(ID,Type,{Mx,My,Mz},Moving,MoveDir,Target) ->
	case fun_scene_obj:get_obj(ID) of
		Object=#scene_spirit_ex{buffs=Buffs} ->
			case check_fear(ID) of
				true -> fear;
				_ ->
					Check = case check_sneered(ID) of%%其次嘲讽
						true ->
							Sneereds=fun_scene_buff:get_sneered_buff(Buffs),
							NewTag = if  
								length(Sneereds) > 0 -> #scene_buff{buff_adder=Adder}=lists:nth(1, Sneereds),Adder;
								true -> Target
							end,
							if 
								Target =/= NewTag -> {chase,NewTag};
								true -> continue
							end;
						_ -> continue
					end,
					case Check of
						continue ->
							case check_impact_monster(ID,{Mx,My,Mz}) of
								no -> 
									case atk(ID, Type) of
										{atk, SkillType} ->
											#st_skillperformance_config{targetType=SkillTargetType,skill_ai=SkillAi,castRange=Range} = data_skillperformance:get_skillperformance(SkillType),
											case fun_scene_obj:get_obj(Target) of
												#scene_spirit_ex{pos={X,Y,Z},sort=?SPIRIT_SORT_ENTOURAGE,die=false} ->
													Dis = tool_vect:lenght(tool_vect:to_map_point({X-Mx, 0, Z-Mz})),
													if
														Dis > Range -> fun_ai:ai_find_dir(Range - 0.5,{Mx,My,Mz},{X,Y,Z},Moving,MoveDir);
														true -> atk
													end;
												#scene_spirit_ex{pos={X,Y,Z},die=false,data=#scene_monster_ex{type=TagType}} ->
													Dis = tool_vect:lenght(tool_vect:to_map_point({X-Mx, 0, Z-Mz})),
													#st_monster_config{monster_r=TagMr}=data_monster:get_monster(TagType),
													if
														Dis > Range+TagMr -> fun_ai:ai_find_dir(Range - 0.5,{Mx,My,Mz},{X,Y,Z},Moving,MoveDir);
														true -> atk
													end;
												_ ->
													CollRelation = fun_scene_skill:get_relation_by_skill(SkillTargetType),
													{chase,ai_find_feel(Object, CollRelation, SkillAi)}
											end;
										_ -> continue
									end;
								_ -> 
									{chase,Target}
							end;
						_ -> Check
					end
			end;
		_ -> {chase,Target}
	end.

%%发现重合的处理每次都需要时间处理
%%没有重合的时候开追击
check_impact(ID,{Mx,My,Mz},Target,Last_time) ->
	Now = util:unixtime(),
	NeedTime = 1,
	if
		Last_time + NeedTime =< Now -> 
			case fun_scene_obj:get_obj(Target) of
				#scene_spirit_ex{} ->
					case check_impact_monster(ID,{Mx,My,Mz}) of	
						no -> {chase,Target};
						_ -> process
					end;
				_ -> {chase,Target}
			end;
		true -> continue
	end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
chase(Id,Type,{Mx,My,Mz},Moving,MoveDir,Target) ->
	case atk(Id, Type) of
		{atk, SkillType} ->
			#st_skillperformance_config{targetType=SkillTargetType,castRange=Range,skill_ai=SkillAi} = data_skillperformance:get_skillperformance(SkillType),
			case fun_scene_obj:get_obj(Target) of
				#scene_spirit_ex{pos={X,Y,Z},sort = ?SPIRIT_SORT_ENTOURAGE,die=false} ->
					Dis = tool_vect:lenght(tool_vect:to_map_point({X-Mx, 0, Z-Mz})),
					if
						Dis > Range -> ai_find_dir(Range - 0.5,{Mx,My,Mz},{X,Y,Z},Moving,MoveDir);
						true -> atk
					end;
				#scene_spirit_ex{pos={X,Y,Z},die=false,data=#scene_monster_ex{type=TagType}} ->
					Dis = tool_vect:lenght(tool_vect:to_map_point({X-Mx, 0, Z-Mz})),
					case data_monster:get_monster(TagType) of
						#st_monster_config{monster_r=TagMr} ->
							if
								Dis > Range+TagMr -> ai_find_dir(Range - 0.5,{Mx,My,Mz},{X,Y,Z},Moving,MoveDir);
								true -> atk
							end;
						_ -> ?log_error("monster_config_error TagType=~p~n",[TagType]),no
					end;
				_ ->
					CollRelation = fun_scene_skill:get_relation_by_skill(SkillTargetType),
					{chase,ai_find_feel(fun_scene_obj:get_obj(Id), CollRelation, SkillAi)}
			end;
		_ -> %% maybe in cding
			no
	end.

back(_ID,Type,{Mx,My,Mz},_Moving,_MoveDir,BornPos) ->
	case data_monster:get_monster(Type) of
		#st_monster_config{} ->
			DirVect = tool_vect:dec(tool_vect:to_map_point(BornPos),tool_vect:to_map_point({Mx,My,Mz})),
			Dir = tool_vect:get_dir_angle(DirVect),
			{walk,Dir,BornPos};
		_ -> no
	end.

atk(ID,Type)->
	case data_monster:get_monster(Type) of
		#st_monster_config{skill=Skill_List,normal_skill=Normal_Skill} ->
			case fun_new_ai:check_can_cast_skill(ID, Skill_List ++ [Normal_Skill]) of
				{true, SkillId} -> {atk,SkillId};
				_ -> no
			end;
		_ -> no
	end.
atk_tag(Skill,{Mx,_My,Mz},Target,Data)->
	case fun_scene_obj:get_obj(Target) of
		#scene_spirit_ex{pos={Tx,Ty,Tz}} ->
			Dir = tool_vect:get_dir_angle(tool_vect:to_map_point({Tx-Mx, 0, Tz-Mz})),
			{atk,Skill,Target,Dir,{Tx,Ty,Tz},Data};
		_ -> Data
	end.
atk_tag_dir(Skill,Dir,Target,Data)->
	case fun_scene_obj:get_obj(Target) of
		#scene_spirit_ex{pos={Tx,Ty,Tz}} ->
			{atk,Skill,Target,Dir,{Tx,Ty,Tz},Data};
		_ -> Data
	end.

impact(ID,Type,{Mx,My,Mz},Moving,MoveDir,Last_time)->
%% 	?debug("{ID,Type,{Mx,My,Mz},Moving,MoveDir}=~p~n",[{ID,Type,{Mx,My,Mz},Moving,MoveDir}]),
	Now = scene:get_scene_long_now(),
	NeedTime = 1000,
	if
		Last_time + NeedTime =< Now ->
			case check_impact_monster(ID,{Mx,My,Mz}) of
				no -> chase;
				Impact=#scene_spirit_ex{pos=IPos} ->
					case data_monster:get_monster(Type) of
						#st_monster_config{normal_skill=Skill} ->
							#st_skillperformance_config{castRange = Range} = data_skillperformance:get_skillperformance(Skill),
							case ai_find_dir(Range - 0.5,{Mx,My,Mz},IPos) of
								{Dir,ToPoint} ->
									Do = case Moving of
										true ->
											case MoveDir of
												no -> true;
												_ -> 
													DirOff = util:abs(Dir - MoveDir),
													if
														DirOff < 15 -> false;
														true -> true
													end
											end;
										_ -> true
									end,
									case Do of
										false -> no;
										_ -> {walk,Dir,ToPoint}
									end;
								_ ->
									case get_new_point({Mx,My,Mz},Impact) of
										{{Mx,My,Mz},_}->
											no;
										{NIPos,NIDir}->
											{walk,NIDir,NIPos}
									end
							end;
						_ -> no
					end
			end;
		true -> no
	end.

fear(_,_,_,true,_)-> no;
fear(ID,_Type,{Mx,My,Mz},_Moving,_Last_time) ->
	case check_fear(ID) of
		true ->
			RandPos=find_rand_point({Mx,My,Mz},1,1),
			case ai_find_dir(1,{Mx,My,Mz},RandPos) of
				{Dir,ToPoint} -> {walk,Dir,ToPoint};
				_ -> no	
			end;
		_ -> free
	end.

sneered(_,_,true,_,_)-> no;
sneered(ID,_Type,_Moving,Target,Hatred_list)->
	case fun_scene_obj:get_obj(ID,?SPIRIT_SORT_MONSTER) of
		#scene_spirit_ex{buffs=Buffs} ->
			case check_sneered(ID) of
				true ->
					Sneereds=fun_scene_buff:get_sneered_buff(Buffs),
					NewTarget=if  
							length(Sneereds) > 0 ->
								#scene_buff{buff_adder=Adder}=lists:nth(1, Sneereds),Adder;
							true -> Target
						end,
					{chase,NewTarget,Hatred_list};
				_ -> free
			end;
		_ -> no
	end.

get_new_point({X,Y,Z},#scene_spirit_ex{pos={Ix,Iy,Iz}})->
	lib_c_map_module:find_turn_dir_point(X,Y,Z,Ix,Iy,Iz).

% get_turn_point(Point,Dir,Dis)->
%    	VD = tool_vect:get_vect_by_dir(tool_vect:angle2radian(Dir)),
% 	#map_point{x=DX,y=DY,z=DZ}=tool_vect:add(tool_vect:to_map_point(Point), tool_vect:ride(tool_vect:normal(VD), Dis)),	
% 	{DX,DY,DZ}.