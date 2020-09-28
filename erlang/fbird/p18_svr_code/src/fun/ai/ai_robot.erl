%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% name :  
%% author : Andy lee
%% date :  2016-3-14
%% Company : fbird.Co.Ltd
%% Desc : 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-module(ai_robot).
-include("common.hrl").
-export([init/3,add_partrol_point/2,do_ai/5]).
-export([handle/1]).

%% -record(robot_ai_data, {id=0,scene=0,x=0,y=0,z=0,status=0,target=0,move_dir=no,move_time=0,create_time=0}).
-define(NEAR_DIS,3).%%距离小于等于3
-define(NORMAL_DIS,5).%%距离小于等于5
-define(FAR_DIS,8).%%距离小于等于8

% get_gener_skill_dis(3) -> 3;
% get_gener_skill_dis(6) -> 3;
% get_gener_skill_dis(9) -> 7;
% get_gener_skill_dis(_) -> 3.


handle({continue_cast_shenqi_skill, Id, Skill_List}) ->
	case get(arena_finish) of
		0 ->
			case fun_scene_obj:get_obj(Id, ?SPIRIT_SORT_ROBOT) of
				#scene_spirit_ex{pos = Pos} = Obj ->
					case Skill_List of
						[{SkillType,SkillLev} | RestSkills]->
							put(is_in_fight, true), %% 主关卡刷怪需要知道是否玩家是在战斗中
							CastPos = Pos,
							case fun_scene:robot_skill(Obj,{SkillType,SkillLev},0,0,CastPos) of
								{error, not_succ} -> skip;
								_ ->
									Msg = {handle_msg, ?MODULE, {continue_cast_shenqi_skill, Id, RestSkills}},
									RestSkills /= [] andalso erlang:send_after(200, self(), Msg)
							end;	
						_ -> 
							?WARNING("user ~p has no shenqi skill loaded",[Id])
					end;
				_ -> ?ERROR("NO user ~p object when cast shenqi skill?", [Id])
			end;
		_ -> ?DEBUG("arena scene battle is stop")
	end.

add_partrol_point(AiData,_Points) -> AiData.

init(Scene,Id,{X,Y,Z}) ->		
	#robot_ai_data{id=Id,status=create,scene=Scene,x=X,y=Y,z=Z,move_dir=0,create_time=util:longunixtime()}.

do_ai(Obj = #scene_spirit_ex{id = Id}, Pos, ShenqiData, AiData = #robot_ai_data{status = Status}, Now) ->
	case Status of
		create -> do_create(Pos, AiData, Now, Id);
		free ->
			case util_scene:scene_type(get(scene)) of
				?SCENE_SORT_ARENA -> process_shenqi(Obj, ShenqiData, Now);
				?SCENE_SORT_HERO_EXPEDITION -> process_shenqi(Obj, ShenqiData, Now);
				_ -> AiData
			end;
		% chase -> do_chase(Pos, Moving, AiData);
		% fear -> do_fear(Pos, Moving, AiData);
		% atk -> do_atk(Pos, AiData);
		_ ->
			% ?log_error("error normal ai s=~p",[Status]),
			AiData
	end.

process_shenqi(#scene_spirit_ex{id = Id}, {ShenqiId, ShenqiStar, _}, Now) ->
	case Now >= get_shenqi_time(Id) + 10000 of
		true ->
			put_shenqi_time(Id, Now),
			case data_shenqi:get_star_skill(ShenqiId, ShenqiStar) of
				[] -> {ok, false};
				SkillList1 ->
					SkillList = [{SkillType, 1} || SkillType <- SkillList1],
					handle({continue_cast_shenqi_skill, Id, SkillList}),
					{ok, true}
			end;
		_ -> {ok, false}
	end.

check_create(CreateTime) ->
	Now = util:longunixtime(),
	Scene = get(scene),
	if
		Scene == ?GGB_BATTLE_SCENE -> free;
		CreateTime  + 3000 < Now -> free;
		true -> continue
	end.

%%create
do_create({Mx,My,Mz},#robot_ai_data{status=create,create_time=CreateTime} = Data, Now, Id) ->
%% 	?debug("ai:create"),
	case check_create(CreateTime) of
		free ->
			put_shenqi_time(Id, Now),
			Data#robot_ai_data{status=free,x=Mx,y=My,z=Mz};
		_ -> Data#robot_ai_data{x=Mx,y=My,z=Mz}
	end.

get_shenqi_time(Id) ->
	case get(shenqi_time) of
		undefined -> 0;
		L ->
			case lists:keyfind(Id, 1, L) of
				{Id, Time} -> Time;
				_ -> 0
			end
	end.

put_shenqi_time(Id, Time) ->
	case get(shenqi_time) of
		undefined -> put(shenqi_time, [{Id, Time}]);
		L -> put(shenqi_time, lists:keystore(Id, 1, L, {Id, Time}))
	end.

% %%有能攻击的仇恨目标时进入追击
% %%有不能造成伤害的仇恨目标时继续寻找
% check_free(ID)->
% 	case fun_scene_obj:get_obj(ID) of
% 		Obj when erlang:is_record(Obj, scene_spirit_ex) ->
% 			List=get_orign_target_list(),
% 			{Rx,_Ry,Rz}=Obj#scene_spirit_ex.pos,
% 			Fun=fun(#scene_spirit_ex{id = EnemyId, die=Die,pos={X,_,Z}}) -> 
% 					if
% 						EnemyId == ID -> false;
% 						Die == true -> false;
% 						true ->
% 						   Dis=tool_vect:lenght(tool_vect:to_map_point({X-Rx, 0, Z-Rz})),
% 						   if
% 							   Dis < 20 -> true;
% 							   true -> false
% 						   end
% 					end
% 				end,
% 			FilterList=lists:filter(Fun, List),
% 			% ?debug("List:~p", [List]),
% 			if
% 				length(FilterList) > 0 ->
% 					Enemy=hd(FilterList),
% 					{chase,Enemy#scene_spirit_ex.id};
% 				true -> continue
% 			end;	
% 		_ -> continue
% 	end.

% %%再测试恐惧
% %%继续测试嘲讽
% check_chase(ID,Target) ->
% 	% ?debug("check_chase, ID:~p, Target:~p", [ID, Target]),
% 	case fun_scene_obj:get_obj(ID,?SPIRIT_SORT_ROBOT) of
% 		#scene_spirit_ex{buffs=Buffs} ->
% 			case fun_ai:check_fear(ID) of%%优先恐惧
% 				true -> fear;
% 				_ ->
% 					Check=case fun_ai:check_sneered(ID) of%%其次嘲讽
% 									 true ->
% 										 Sneereds=fun_scene_buff:get_sneered_buff(Buffs),
% 										 NewTag=if  
% 													length(Sneereds) > 0 ->
% 														#scene_buff{buff_adder=Adder}=lists:nth(1, Sneereds),Adder;
% 													true -> Target
% 												end,
% 										 if 
% 											 Target =/= NewTag -> {chase,NewTag};
% 											 true -> go
% 										 end;
% 									 _ -> go%%此处考虑是否检测当前目标是否是ply
% 								 end,
% 					case Check of
% 						go -> continue;	
% 						_ -> Check
% 					end
% 			end;
% 		_ -> continue
% 	end.

% check_atk(ID,{Mx,_My,Mz},Target) ->
% 	case fun_scene_obj:get_obj(ID,?SPIRIT_SORT_ROBOT) of
% 		Object=#scene_spirit_ex{buffs=Buffs,data=#scene_robot_ex{prof=Prof,far_skill=FarSkills,normal_skill=NorSkills,near_skill=NearSkills,gener_skill=GenerSkills}} ->
% 			case fun_ai:check_fear(ID) of%%优先恐惧
% 				true -> fear;
% 				_ ->
% 					Check=case fun_ai:check_sneered(ID) of%%其次嘲讽
% 									 true ->
% 										 Sneereds=fun_scene_buff:get_sneered_buff(Buffs),
% 										 NewTag=if  
% 													length(Sneereds) > 0 ->
% 														#scene_buff{buff_adder=Adder}=lists:nth(1, Sneereds),Adder;
% 													true -> Target
% 												end,
% 										 if 
% 											 Target =/= NewTag -> {chase,NewTag};
% 											 true -> go
% 										 end;
% 									 _ -> go%%此处考虑是否检测当前目标是否是ply
% 								 end,
% 					case Check of
% 						go ->
% 							case fun_scene_obj:get_obj(Target) of
% 								#scene_spirit_ex{pos={X,_Y,Z},sort=Sort,die=false} ->
% 									Dis = tool_vect:lenght(tool_vect:to_map_point({X-Mx, 0, Z-Mz})),
% 									if
% 										Sort==?SPIRIT_SORT_USR orelse Sort==?SPIRIT_SORT_ENTOURAGE orelse Sort==?SPIRIT_SORT_MONSTER orelse Sort == ?SPIRIT_SORT_ROBOT ->
% 											Dis = tool_vect:lenght(tool_vect:to_map_point({X-Mx, 0, Z-Mz})),
% 											CheckSkill=check_skills(Object,Prof,Dis,FarSkills,NorSkills,NearSkills,GenerSkills),
% 											case CheckSkill of
% 												{continue_chase,_Range} -> {chase,Target};
% 												atk -> continue;
% 												_ -> CheckSkill 
% 											end;
% 										true -> {chase,find_tag(ID)}
% 									end;
% 								_ -> {chase,find_tag(ID)}
% 							end;
% 						_ -> Check
% 					end	
% 			end;
% 		_ -> no
% 	end.

% %%free
% ai({Mx,My,Mz},_Moving,#robot_ai_data{id=ID,status=free} = Data) ->
% 	case check_free(ID) of
% 		{chase,Oid} -> Data#robot_ai_data{status=chase,x=Mx,y=My,z=Mz,target= Oid};	
% 		_ -> Data#robot_ai_data{x=Mx,y=My,z=Mz}
% 	end;

% %%chase
% ai({Mx,My,Mz},Moving,#robot_ai_data{id=ID,status=chase,target=Target,move_dir=MoveDir}=Data) ->
% 	case check_chase(ID,Target) of
% 		fear -> Data#robot_ai_data{status=fear,x=Mx,y=My,z=Mz};
% 		{chase,Oid} -> Data#robot_ai_data{x=Mx,y=My,z=Mz,target=Oid};
% 		_ ->
% 			case chase(ID,{Mx,My,Mz},Moving,MoveDir,Target) of
% 				{walk,Dir,ToPoint} -> {move,ToPoint,Data#robot_ai_data{x=Mx,y=My,z=Mz,move_dir=Dir,move_time=util:longunixtime()}};
% 				{atk,Oid} -> Data#robot_ai_data{status=atk,x=Mx,y=My,z=Mz,target= Oid};	
% 				{chase,Oid} -> Data#robot_ai_data{x=Mx,y=My,z=Mz,target=Oid};
% 				_R -> 
% 					Data#robot_ai_data{x=Mx,y=My,z=Mz}
% 			end
% 	end;

% %%fear
% ai({Mx,My,Mz},Moving,#robot_ai_data{id=ID,status=fear,move_time=Last_time}=Data) ->	
% 	case fear(ID,{Mx,My,Mz},Moving,Last_time) of
% 		free -> Data#robot_ai_data{status=free,x=Mx,y=My,z=Mz};
% 		{walk,Dir,ToPoint} -> {move,ToPoint,Data#robot_ai_data{x=Mx,y=My,z=Mz,move_dir=Dir,move_time=util:longunixtime()}};
% 		_ -> Data#robot_ai_data{x=Mx,y=My,z=Mz}
% 	end;

% %%atk
% ai({Mx,My,Mz},_Moving,#robot_ai_data{id=ID,status=atk,target=Target,cast_skill_time=Last_Skill_Time,used_gener_skill=UsedGenerSkills}=Data) ->
% 	case check_atk(ID,{Mx,My,Mz},Target) of
% 		fear -> Data#robot_ai_data{status=fear,x=Mx,y=My,z=Mz};
% 		{chase,Oid} -> Data#robot_ai_data{status=chase,x=Mx,y=My,z=Mz,target=Oid};
% 		_ ->
% 			case atk(ID,Last_Skill_Time,UsedGenerSkills) of%%SkillData=>{SkillType,SkillLev,SkillRune}
% 				{atk,NewUsedGenerSkills,SkillData} -> 
% 					fun_ai:atk_tag(SkillData,{Mx,My,Mz},Target,Data#robot_ai_data{x=Mx,y=My,z=Mz,cast_skill_time=util:longunixtime(),used_gener_skill=NewUsedGenerSkills});
% 				_ -> Data#robot_ai_data{x=Mx,y=My,z=Mz}
% 			end
% 	end;

% ai(S,_,D) -> ?log_error("error normal ai s=~p,d=~p",[S,D]),D.

% %% FAR_DIS
% %% NORMAL_DIS
% %% NEAR_DIS
% chase(ID,{Mx,My,Mz},Moving,MoveDir,Target) ->
% %% 	?debug("{ID,{Mx,My,Mz},Moving,MoveDir,Target}=~p~n",[{ID,{Mx,My,Mz},Moving,MoveDir,Target}]),
% 	case fun_scene_obj:get_obj(ID,?SPIRIT_SORT_ROBOT) of
% 		Object=#scene_spirit_ex{data=#scene_robot_ex{prof=Prof,far_skill=FarSkills,normal_skill=NorSkills,near_skill=NearSkills,gener_skill=GenerSkills}} ->
% 			% ?debug("Target:~p", [Target]),
% 			case fun_scene_obj:get_obj(Target) of
% 				#scene_spirit_ex{pos={X,Y,Z},sort=Sort,die=false} ->
% 					if
% 						Sort==?SPIRIT_SORT_USR orelse Sort==?SPIRIT_SORT_ENTOURAGE orelse Sort == ?SPIRIT_SORT_MONSTER orelse Sort == ?SPIRIT_SORT_ROBOT ->
% 							Dis = tool_vect:lenght(tool_vect:to_map_point({X-Mx, 0, Z-Mz})),
% 							Check=check_skills(Object,Prof,Dis,FarSkills,NorSkills,NearSkills,GenerSkills),
% 							case Check of
% 								{continue_chase,Range} -> 
% 									% ?debug("Range:~p", [Range]),
% 									fun_ai:ai_find_dir(Range,{Mx,My,Mz},{X,Y,Z},Moving,MoveDir);
% 								atk ->
% 									% ?debug("robt atk ~p", [Target]),
% 									{atk,Target};
% 								_ -> 
% 									% ?debug("Check:~p", [Check]),
% 									Check 
% 							end;
% 						true -> {chase,find_tag(ID)}
% 					end;
% 				_ -> 
% 					% ?debug("die:"),
% 					{chase,find_tag(ID)}
% 			end;
% 		_ -> no	
% 	end.

% atk(ID,Last_Skill_Time,UsedGenerSkills)->
% 	case fun_scene_obj:get_obj(ID,?SPIRIT_SORT_ROBOT) of
% 		Object=#scene_spirit_ex{data=#scene_robot_ex{near_skill=NearSkills,normal_skill=NorSkills,far_skill=FarSkills,gener_skill=GenerSkills}} ->
% 			Now=util:longunixtime(),
% 			if
% 				Now > Last_Skill_Time + 300 ->
% 					CheckFar=case check_cd(Object, FarSkills) of
% 								 0 -> 0;
% 								 FarSkill -> {atk,UsedGenerSkills,FarSkill}
% 							 end,
% 					CheckNor=case CheckFar of
% 									0 ->
% 										case check_cd(Object, NorSkills) of
% 											0 -> 0;
% 											NorSkill -> {atk,UsedGenerSkills,NorSkill}
% 										end;
% 									_ -> CheckFar
% 								end,
% 					CheckNear=case CheckNor of
% 								  0 ->
% 									  case check_cd(Object, NearSkills) of
% 										  0 -> 0;
% 										  NearSkill -> {atk,UsedGenerSkills,NearSkill}
% 									  end;
% 								  _ -> CheckNor	
% 							  end,
% 					case CheckNear of
% 						0 ->
% 							NotUsedGenerList = GenerSkills -- UsedGenerSkills,
% 							%%?debug("NotUsedGenerList=~p~n",[NotUsedGenerList]),
% 							case NotUsedGenerList of
% 								[] ->
% 									case check_cd(Object, GenerSkills) of
% 										0 -> 0;
% 										GenerSkill -> {atk,[GenerSkill],GenerSkill}
% 									end;
% 								_ ->
% 									case check_cd(Object, NotUsedGenerList) of
% 										0 -> 0;
% 										GenerSkill -> {atk,UsedGenerSkills++[GenerSkill],GenerSkill}
% 									end
% 							end;
% 						_ -> CheckNear
% 					end;
% 				true -> no
% 			end;
% 		_ -> no
% 	end.

% fear(_,_,true,_)-> no;
% fear(ID,{Mx,My,Mz},_Moving,Last_time)->
% 	case fun_ai:check_fear(ID) of
% 		true ->
% 			if
% 				true ->
% 					Now=util:longunixtime(),
% 					if
% 						Now < Last_time + 3*1000 -> no;
% 						true ->
% 							RandPos=fun_ai:find_rand_point({Mx,My,Mz},3,3),
% 							case fun_ai:ai_find_dir(3,{Mx,My,Mz},RandPos) of
% 								{Dir,ToPoint} -> {walk,Dir,ToPoint};
% 								_ -> no	
% 							end
% 					end
% 			end;
% 		_ -> free
% 	end.

% check_skills(Object,Prof,Dis,FarSkills,NorSkills,NearSkills,GenerSkills) ->
% 	GenSkillDis=get_gener_skill_dis(Prof),
% 	CheckFar=case check_cd(Object,FarSkills) of
% 				 0 -> continue;
% 				 _ -> 
% 					 if
% 						 Dis > ?FAR_DIS -> {continue_chase,?FAR_DIS};
% 						 true -> atk
% 					 end
% 			 end,
% 	CheckNormal=case CheckFar of
% 					continue ->
% 						case check_cd(Object,NorSkills) of
% 							0 -> continue;
% 							_ ->
% 								if
% 									Dis > ?NORMAL_DIS -> {continue_chase,?NORMAL_DIS};
% 									true -> atk
% 								end
% 						end;
% 					_ -> CheckFar
% 				end,
% 	CheckNear=case CheckNormal of
% 				  continue ->
% 					  case check_cd(Object,NearSkills) of
% 						  0 -> continue;
% 						  _ ->
% 							  if
% 								  Dis > ?FAR_DIS -> {continue_chase,?FAR_DIS};
% 								  true -> atk
% 							  end
% 					  end;
% 				  _ -> CheckNormal
% 			  end,
% 	case CheckNear of
% 		continue ->
% 			case check_cd(Object,GenerSkills) of
% 				0 -> continue;
% 				_ ->
% 					if
% 						Dis > GenSkillDis -> {continue_chase,GenSkillDis};
% 						true -> atk
% 					end
% 			end;
% 		_ -> CheckNear
% 	end.

% check_cd(Object,Skill_List) ->
% 	case Skill_List of
% 		[]	-> 0;
% 		_ ->
% 			Fun=fun({SkillType,_SkillLev,_SkillRune}) ->
% 					case fun_scene_cd:get_cd_by_type(Object, SkillType) of
% 						[] -> true;
% 						_ -> false
% 					end	 
% 				end,
% 			Check_List=lists:filter(Fun, Skill_List),
% 			case Check_List of
% 				[SkillData|_] -> SkillData;
% 				_ -> 0
% 			end
% 	end.