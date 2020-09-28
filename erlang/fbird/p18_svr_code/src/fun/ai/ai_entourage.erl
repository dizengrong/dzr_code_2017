%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% name :  
%% author : Andy lee
%% date :  2016-3-9
%% Company : fbird.Co.Ltd
%% Desc : 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-module(ai_entourage).
-include("common.hrl").
-export([init/3,do_ai/3,add_partrol_point/2]).

add_partrol_point(AiData,_Points) -> AiData.

init(Scene,Id,{X,Y,Z}) ->		
	#robot_ai_data{id=Id,status=create,scene=Scene,x=X,y=Y,z=Z,move_dir=0,create_time=util:longunixtime()}.

get_orign_target_list() ->
	case erlang:get(robot_attack_robot) of
		true -> 
			fun_scene_obj:get_el();
		_ -> 
			case erlang:get(cannot_attack_usr) of
				true -> 
					fun_scene_obj:get_ml();
				_ ->
					fun_scene_obj:get_ul()
			end
	end.

find_tag(#scene_spirit_ex{id = AtkOid, camp = Camp, pos = {Rx,_,Rz}}, CollRelation, SkillAi) ->
	List = get_orign_target_list(),
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

do_ai(Pos, Moving, AiData = #robot_ai_data{id = _Id, status = Status}) ->
	case Status of
		create -> do_create(Pos, AiData);
		chase -> do_chase(Pos, Moving, AiData);
		fear -> do_fear(Pos, Moving, AiData);
		atk -> do_atk(Pos, Moving, AiData);
		_ ->
			?log_error("error normal ai s=~p",[Status]),
			AiData
	end.

%%create
do_create({Mx,My,Mz},#robot_ai_data{id=ID,status=create,create_time=CreateTime} = Data) ->
	case check_create(ID,CreateTime) of
		{chase,Oid} -> Data#robot_ai_data{status=chase,x=Mx,y=My,z=Mz,target=Oid};
		_ -> Data#robot_ai_data{x=Mx,y=My,z=Mz}
	end.

check_create(ID,CreateTime) ->
	Now = util:longunixtime(),
	DelayTime = case util_scene:scene_type(get(scene)) of
		?SCENE_SORT_ARENA -> 8000;
		_ -> 200
	end,
	if
		CreateTime + DelayTime < Now -> check_create_help(ID);
		true -> continue
	end.

check_create_help(ID) ->
	case fun_scene_obj:get_obj(ID,?SPIRIT_SORT_ENTOURAGE) of
		Object = #scene_spirit_ex{die = false, data=#scene_entourage_ex{skills=Skills,general_skill=GenerSkills}} ->
			{SkillType,_} = check_skills(Object,Skills,GenerSkills),
			#st_skillperformance_config{targetType=SkillTargetType,skill_ai=SkillAi} = data_skillperformance:get_skillperformance(SkillType),
			CollRelation = fun_scene_skill:get_relation_by_skill(SkillTargetType),
			case find_tag(Object, CollRelation, SkillAi) of
				0 -> continue;
				Oid -> {chase,Oid}
			end;
		_ -> continue
	end.

%%chase
do_chase({Mx,My,Mz},Moving,#robot_ai_data{id=ID,status=chase,target=Target,move_dir=MoveDir}=Data) ->
	case check_chase(ID,Target) of
		fear -> Data#robot_ai_data{status=fear,x=Mx,y=My,z=Mz};
		{chase,NewOid} ->
			case chase(ID,{Mx,My,Mz},Moving,MoveDir,NewOid) of
				atk -> Data#robot_ai_data{status=atk,x=Mx,y=My,z=Mz};
				{walk,Dir,ToPoint} -> {move,ToPoint,Data#robot_ai_data{x=Mx,y=My,z=Mz,move_dir=Dir,move_time=util:longunixtime()}};
				{chase,Oid} -> Data#robot_ai_data{status=chase,x=Mx,y=My,z=Mz,target=Oid};
				_ -> Data#robot_ai_data{x=Mx,y=My,z=Mz}
			end;
		_ ->
			case chase(ID,{Mx,My,Mz},Moving,MoveDir,Target) of
				atk -> Data#robot_ai_data{status=atk,x=Mx,y=My,z=Mz};
				{walk,Dir,ToPoint} -> {move,ToPoint,Data#robot_ai_data{x=Mx,y=My,z=Mz,move_dir=Dir,move_time=util:longunixtime()}};
				{chase,Oid} -> Data#robot_ai_data{status=chase,x=Mx,y=My,z=Mz,target=Oid};
				_ -> Data#robot_ai_data{x=Mx,y=My,z=Mz}
			end
	end.

%%再测试恐惧
%%继续测试嘲讽
check_chase(ID,Target) ->
	case check_chase_help(ID,Target) of
		{true, Buffs} ->
			case fun_ai:check_fear(ID) of%%优先恐惧
				true -> fear;
				_ ->
					case fun_ai:check_sneered(ID) of%%其次嘲讽
						true ->
							Sneereds=fun_scene_buff:get_sneered_buff(Buffs),
							NewTag = if  
								length(Sneereds) > 0 ->
									#scene_buff{buff_adder=Adder}=lists:nth(1, Sneereds),
									Adder;
								true -> Target
							end,
							if
								Target =/= NewTag -> {chase,NewTag};
								true -> continue
							end;
						_ -> continue %%此处考虑是否检测当前目标是否是ply
					end
			end;
		{chase, Oid} -> {chase, Oid};
		_ -> continue
	end.

check_chase_help(ID,Target) ->
	case fun_scene_obj:get_obj(ID,?SPIRIT_SORT_ENTOURAGE) of
		Object = #scene_spirit_ex{buffs=Buffs, die = false, data=#scene_entourage_ex{skills=Skills,general_skill=GenerSkills}} ->
			case fun_scene_obj:get_obj(Target) of
				#scene_spirit_ex{die=false} -> {true, Buffs};
				_ ->
					{SkillType,_} = check_skills(Object,Skills,GenerSkills),
					#st_skillperformance_config{targetType=SkillTargetType,skill_ai=SkillAi} = data_skillperformance:get_skillperformance(SkillType),
					CollRelation = fun_scene_skill:get_relation_by_skill(SkillTargetType),
					{chase, find_tag(Object, CollRelation, SkillAi)}
			end;
		_ -> continue
	end.

chase(ID,{Mx,My,Mz},Moving,MoveDir,Target) ->
	case fun_scene_obj:get_obj(ID,?SPIRIT_SORT_ENTOURAGE) of
		Object = #scene_spirit_ex{data=#scene_entourage_ex{skills=Skills,general_skill=GenerSkills}} ->
			{SkillType,_} = check_skills(Object,Skills,GenerSkills),
			#st_skillperformance_config{targetType=SkillTargetType,skill_ai=SkillAi,castRange=Range} = data_skillperformance:get_skillperformance(SkillType),
			case fun_scene_obj:get_obj(Target) of
				#scene_spirit_ex{pos={X,Y,Z},die=false} ->
					Dis = tool_vect:lenght(tool_vect:to_map_point({X-Mx, 0, Z-Mz})),
					if
						Dis > Range -> fun_ai:ai_find_dir(Range,{Mx,My,Mz},{X,Y,Z},Moving,MoveDir);
						true -> atk
					end;
				_ ->
					CollRelation = fun_scene_skill:get_relation_by_skill(SkillTargetType),
					{chase, find_tag(Object, CollRelation, SkillAi)}
			end;
		_ -> no	
	end.

%%fear
do_fear({Mx,My,Mz},Moving,#robot_ai_data{id=ID,status=fear,move_time=Last_time}=Data) ->
	case fear(ID,{Mx,My,Mz},Moving,Last_time) of
		create -> Data#robot_ai_data{status=create,x=Mx,y=My,z=Mz};
		{walk,Dir,ToPoint} -> {move,ToPoint,Data#robot_ai_data{x=Mx,y=My,z=Mz,move_dir=Dir,move_time=util:longunixtime()}};
		_ -> Data#robot_ai_data{x=Mx,y=My,z=Mz}
	end.

%%atk
do_atk({Mx,My,Mz},Moving,#robot_ai_data{id=ID,status=atk,target=Target,move_dir=MoveDir,cast_skill_time=Last_Skill_Time,used_gener_skill=UsedGenerSkills}=Data) ->	
	case check_atk(ID,{Mx,My,Mz},Moving,MoveDir,Target) of
		fear -> Data#robot_ai_data{status=fear,x=Mx,y=My,z=Mz};
		{walk,Dir,ToPoint} -> {move,ToPoint,Data#robot_ai_data{x=Mx,y=My,z=Mz,move_dir=Dir,move_time=util:longunixtime()}};
		{chase,Oid} -> Data#robot_ai_data{status=chase,x=Mx,y=My,z=Mz,target=Oid};
		_ ->
			case atk(ID,Last_Skill_Time,UsedGenerSkills) of
				{atk,NewUsedGenerSkills,SkillData} ->
					fun_ai:atk_tag(SkillData,{Mx,My,Mz},Target,Data#robot_ai_data{x=Mx,y=My,z=Mz,cast_skill_time=util:longunixtime(),used_gener_skill=NewUsedGenerSkills});
				_ -> Data#robot_ai_data{x=Mx,y=My,z=Mz}
			end
	end.

check_atk(ID,{Mx,My,Mz},Moving,MoveDir,Target) ->
	case fun_scene_obj:get_obj(ID,?SPIRIT_SORT_ENTOURAGE) of
		Object=#scene_spirit_ex{buffs=Buffs,data=#scene_entourage_ex{skills=Skills,general_skill=GenerSkills}} ->
			case fun_ai:check_fear(ID) of%%优先恐惧
				true -> fear;
				_ ->
					Check = case fun_ai:check_sneered(ID) of%%其次嘲讽
						true ->
							Sneereds=fun_scene_buff:get_sneered_buff(Buffs),
							NewTag = if  
								length(Sneereds) > 0 ->
									#scene_buff{buff_adder=Adder}=lists:nth(1, Sneereds),
									Adder;
								true -> Target
							end,
							if 
								Target =/= NewTag -> {chase,NewTag};
								true -> go
							end;
						_ -> go%%此处考虑是否检测当前目标是否是ply
					end,
					case Check of
						go ->
							{SkillType,_} = check_skills(Object,Skills,GenerSkills),
							#st_skillperformance_config{targetType=SkillTargetType,castRange=Range,skill_ai=SkillAi} = data_skillperformance:get_skillperformance(SkillType),
							CollRelation = fun_scene_skill:get_relation_by_skill(SkillTargetType),
							case fun_scene_obj:get_obj(Target) of
								#scene_spirit_ex{pos={X,Y,Z},die=false} ->
									Dis = tool_vect:lenght(tool_vect:to_map_point({X-Mx, 0, Z-Mz})),
									if
										Dis > Range -> fun_ai:ai_find_dir(Range,{Mx,My,Mz},{X,Y,Z},Moving,MoveDir);
										true -> atk
									end;
								_ ->{chase, find_tag(Object, CollRelation, SkillAi)}
							end;
						_ -> Check
					end
			end;
		_ -> no
	end.

atk(ID,Last_Skill_Time,UsedGenerSkills)->
	case fun_scene_obj:get_obj(ID,?SPIRIT_SORT_ENTOURAGE) of
		Object=#scene_spirit_ex{data=#scene_entourage_ex{skills=Skills,general_skill=GenerSkills}} ->
			Now=util:longunixtime(),
			if
				Now > Last_Skill_Time + 300 ->
					{SkillType,SkillLev} = check_skills(Object,Skills,GenerSkills),
					case lists:keyfind(SkillType, 1, GenerSkills) of
						false -> {atk,UsedGenerSkills,{SkillType,SkillLev}};
						_ ->
							NotUsedGenerList = GenerSkills -- UsedGenerSkills,
							case NotUsedGenerList of
								[] -> {atk,[{SkillType,SkillLev}],{SkillType,SkillLev}};
								_ -> {atk,[hd(NotUsedGenerList) | UsedGenerSkills],hd(NotUsedGenerList)}
							end
					end;
				true -> no
			end;
		_ -> no	
	end.

fear(_,_,true,_)-> no;
fear(ID,{Mx,My,Mz},_Moving,_Last_time)->
	case fun_ai:check_fear(ID) of
		true ->
			RandPos=fun_ai:find_rand_point({Mx,My,Mz},1,1),
			case fun_ai:ai_find_dir(1,{Mx,My,Mz},RandPos) of
				{Dir,ToPoint} -> {walk,Dir,ToPoint};
				_ -> no
			end;
		_ -> create
	end.

check_skills(Object,Skills,GenerSkills) ->
	case check_cd(Object,Skills) of
		[] -> hd(GenerSkills);
		List -> hd(List)
	end.

check_cd(Object,Skill_List) ->
	case Skill_List of
		[] -> [];
		_ ->
			Fun=fun({SkillType,_}) ->
				case fun_scene_cd:get_cd_by_type(Object, SkillType) of
					[] -> true;
					_ -> false
				end	 
			end,
			lists:filter(Fun, Skill_List)
	end.