-module(fun_scene_skill).
-include("common.hrl").
-export([handle/1]).
-export([init/0,update_skill/2,check_skill/3,check_skill_entourage/3,collect_skill_targets/6,
		 collect_arrow_run_targets/8,collect_arrow_targets/6,collect_trap_targets/6,get_atk_sort_num/1,get_def_sort_num/1]).
-export([check_cd/3,buff_dot/8,checknormal/2,get_demage/1,get_coin/0,init_coin/0,
		 cast_skill/5,skill_by_aleret/5,buff_skill/2,arrow_skill/5,trap_skill/7,get_dis_center_cast_point/3]).
-export([monster_cast_skill/7, do_skill_help/10, count_usr_demage/3, collect_target_area_list/13]).
-export([get_damage_list/0,reset_damage_list/0]).
-export([count_scene_damage/3,get_scene_damage_list/0,get_scene_treat_list/0,get_relation_by_skill/1,get_skill_type/1]).

init() ->
	fun_scene_arrow:init(),
	ok.

handle({cast_passive_skill, AtkOid, BeAtkOid, Skill, Lev}) ->
	case fun_scene_obj:get_obj(AtkOid) of
		Obj = #scene_spirit_ex{sort = Sort, die = false} ->
			case fun_scene_obj:get_obj(BeAtkOid) of
				#scene_spirit_ex{die = false, pos = TargetPos} ->
					case Sort of
						?SPIRIT_SORT_MONSTER ->
							#st_skillmain_config{ai_skill_cast_condition = AiCondition, ai_skill_cast_param = AiSkillParam} = data_skillmain:get_skillmain(Skill),
							monster_cast_skill(Obj,BeAtkOid,TargetPos,{Skill,Lev},AiCondition,AiSkillParam,0);
						_ -> cast_skill(Obj,BeAtkOid,TargetPos,{Skill,Lev},0)
					end;
				_ -> skip
			end;
		_ -> skip
	end;

handle(Msg) -> ?debug("unknow msg, module = ~p, Msg = ~p",[?MODULE, Msg]).

update_skill(_Uid,_SkillData) -> ok.
check_skill(Uid,Skill,_Lev) ->
	case fun_scene_obj:get_obj(Uid) of
		Usr = #scene_spirit_ex{} -> 
			case data_skillmain:get_skillmain(Skill) of
				#st_skillmain_config{skillMode= "NORMALSKILL"} -> fun_scene_buff:can_start_normal(Usr#scene_spirit_ex.buffs);
				#st_skillmain_config{skillMode= "PARALLELSKILL"} -> true;
				_ -> fun_scene_buff:can_start_skill(Usr#scene_spirit_ex.buffs)
			end;
		_ -> false 
	end.
check_skill_entourage(Eid,_Skill,_Lev) ->
	case fun_scene_obj:get_obj(Eid) of
		Entourage = #scene_spirit_ex{} -> fun_scene_buff:can_start_skill(Entourage#scene_spirit_ex.buffs);
		_ -> false
	end.

get_skill_type(SkillType) ->
	#st_skillmain_config{skillMode = SkillMode} = data_skillmain:get_skillmain(SkillType),
	SkillMode.

get_relation_by_skill(?SKILL_TARGET_TYPE_ENEMY) -> ?RELATION_ENEMY;
get_relation_by_skill(?SKILL_TARGET_TYPE_FRIEND) -> ?RELATION_FRIEND;
get_relation_by_skill(?SKILL_TARGET_TYPE_SELF) -> ?RELATION_FRIEND;
get_relation_by_skill(?SKILL_TARGET_TYPE_TEAM) -> ?RELATION_TEAM;
get_relation_by_skill(_) -> ?RELATION_NEUTRAL.

get_coll_target_num(?COLL_TARGET_NUM_AOERANDOM,CollNum) -> CollNum;
get_coll_target_num(?COLL_TARGET_NUM_SINGLE,_CollNum) -> single;
get_coll_target_num(?COLL_TARGET_NUM_NO,_CollNum) -> no;
get_coll_target_num(?COLL_TARGET_NUM_AOEALL,_CollNum) -> all;
get_coll_target_num(_,_) -> all.
		
get_dis_center_cast_point(Pos,Dir,ACR) ->
	VD = tool_vect:get_vect_by_dir(tool_vect:angle2radian(Dir)),
	#map_point{x=X,y=Y,z=Z}=tool_vect:add(tool_vect:to_map_point(Pos), tool_vect:ride(tool_vect:normal(VD), ACR)),
	{X,Y,Z}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 技能预警,根据目标收集规则,找到预警点,再进行技能收集时候

%% 技能的收集目标说明
%% 根据技能释放点配置来决定是:
%%				自身角色释放
%%				目标角色释放
%%				角色当前所在坐标为释放�存在有目标和无目标两种情况的处�
%%				所选中的目标所在坐标为释放�
%% 根据技能配置来计算，如方形,圆形,扇形,环形,点等范围内的目标
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_aleret_pos(Pos,Dir,TargetPos,SkillType) ->
	case data_skillperformance:get_skillperformance(SkillType) of
		#st_skillperformance_config{castPoint=Skill_Cast_Point,areaCenterRange=ACR} ->
			case Skill_Cast_Point of
				?SKILL_CAST_SELF -> Pos;
				?SKILL_CAST_TARGET -> TargetPos;
				?SKILL_CAST_SELF_AREA ->
					if
						ACR == 0 -> Pos;
						true -> get_dis_center_cast_point(Pos,Dir,ACR)
					end;
				?SKILL_CAST_TARGET_AREA -> TargetPos;
				_ -> no
			end;
		_ -> no
	end.

collect_skill_targets(AtkOid,Pos,Dir,TargetID,TargetPos,Skill) ->
	collect_skill_targets(AtkOid,Pos,Dir,TargetID,TargetPos,Skill,no).
collect_skill_targets(AtkOid,Pos,Dir,TargetID,TargetPos,Skill,AleretPos) ->	
	% ?debug("collect_skill_targets data=~p~n",[data_skillperformance:get_skillperformance(Skill)]),
	% ?debug("collect_skill_targets data=~p~n",[{AtkOid,Pos,Dir,TargetID,TargetPos,Skill}]),
	case data_skillperformance:get_skillperformance(Skill) of
		#st_skillperformance_config{castRange=SkillCastDis,targetType=SkillTargetType,castPoint=Skill_Cast_Point,targetnumType=NumberType,
									targetnum=CollNum,impactArea=Skill_AREA,areaPara=ParList,areaCenterRange=ACR,skill_ai=SkillAi} ->
			CollRelation=get_relation_by_skill(SkillTargetType),
			Num=get_coll_target_num(NumberType,CollNum),
			% ?debug("Num = ~p",[{AtkOid, Num}]),
			% Obj = fun_scene_obj:get_obj(AtkOid),
			% case Obj#scene_spirit_ex.sort of
			% 	?SPIRIT_SORT_ENTOURAGE -> ?debug("Num = ~p",[{TargetID, Num}]);
			% 	_ -> skip
			% end,
			collect_targets(AtkOid,Pos,Dir,TargetID,TargetPos,Skill_Cast_Point,Skill_AREA,ParList,CollRelation,Num,SkillAi,ACR,SkillCastDis,AleretPos);
		_ -> []
	end.

collect_buff_skill_target(BuffOid,Pos,Dir,BuffType) ->
	case data_buff:get_data(BuffType) of
%% 		#st_buff_config{targetType=?SKILL_TARGET_TYPE_TEAM} -> [];%%暂时无组
%% 		#st_buff_config{targetType=?SKILL_TARGET_TYPE_NO} -> [];
		#st_buff_config{impactArea= Skill_AREA,areaPara= ParList,targetType=TargetType} ->
			CollRelation=get_relation_by_skill(TargetType),
%% 			?debug("buff,collect_buff_skill_target,data = ~p",[{BuffOid,Pos,Dir,BuffOid,{0,0,0},?SKILL_CAST_SELF_AREA,Skill_AREA,ParList,CollRelation,all}]),
			collect_targets(BuffOid,Pos,Dir,BuffOid,{0,0,0},?SKILL_CAST_SELF_AREA,Skill_AREA,ParList,CollRelation,all,{?ATK_NORMAL, 0});
		_ -> []
	end.
collect_arrow_run_targets(ArrowOid,Pos,Dir,Width,Length,TargetType,UpHigh,DownHigh) ->
%% 	?debug("collect_arrow_run_targets data = ~p",[{ArrowOid,Pos,Dir,Width,Length,TargetType,UpHigh,DownHigh}]),
	CollRelation=get_relation_by_skill(TargetType),
	collect_targets(ArrowOid,tool_vect:to_point(Pos),Dir,0,{0,0,0},?SKILL_CAST_SELF_AREA,?AREA_RECT,[0,0,0,Length,Width,UpHigh,DownHigh],CollRelation,all,{?ATK_NORMAL, 0}).
collect_arrow_targets(ArrowOid,Pos,TargetID,Dir,TargetType,ArrowType) ->
	case data_arrow:get_data(ArrowType) of
		#st_arrow_config{impactArea= Skill_AREA,areaPara= ParList} ->
			CollRelation=get_relation_by_skill(TargetType),
			collect_targets(ArrowOid,tool_vect:to_point(Pos),Dir,TargetID,{0,0,0},?SKILL_CAST_TARGET_AREA,Skill_AREA,ParList,CollRelation,all,{?ATK_NORMAL, 0});
		_ -> []
	end.
collect_trap_targets(TrapOid,Pos,Dir,ACR,TargetType,TrapType) ->
	case data_trap:get_data(TrapType) of
		#st_trap_config{impactArea= Skill_AREA,areaPara= ParList} ->
         CollRelation=get_relation_by_skill(TargetType),
	     collect_targets(TrapOid,tool_vect:to_point(Pos),Dir,0,{0,0,0},?SKILL_CAST_SELF_AREA,Skill_AREA,ParList,CollRelation,all,{?ATK_NORMAL, 0},ACR,0);
		_ -> []
	end.
	

collect_targets(AtkOid,Pos,Dir,TargetID,_TargetPos,Skill_Cast_Point,Skill_AREA,ParList,CollRelation,CollNum,SkillAi) ->
	collect_targets(AtkOid,Pos,Dir,TargetID,_TargetPos,Skill_Cast_Point,Skill_AREA,ParList,CollRelation,CollNum,SkillAi,0,0).	
collect_targets(AtkOid,Pos,Dir,TargetID,_TargetPos,Skill_Cast_Point,Skill_AREA,ParList,CollRelation,CollNum,SkillAi,ACR,SkillCastDis) ->
	collect_targets(AtkOid,Pos,Dir,TargetID,_TargetPos,Skill_Cast_Point,Skill_AREA,ParList,CollRelation,CollNum,SkillAi,ACR,SkillCastDis,no).
collect_targets(AtkOid,Pos,Dir,TargetID,_TargetPos,Skill_Cast_Point,Skill_AREA,ParList,CollRelation,CollNum,SkillAi,ACR,SkillCastDis,AleretPos) ->	
	% ?debug("collect_targets,data = ~p",[{AtkOid,Pos,Dir,TargetID,_TargetPos,Skill_Cast_Point,Skill_AREA,ParList,CollRelation,CollNum,ACR,SkillCastDis}]),
	% ?debug("Skill_Cast_Point = ~p",[Skill_Cast_Point]),
	Scene = get(scene),
	case fun_scene_obj:get_obj(AtkOid) of
		#scene_spirit_ex{camp=Camp} ->
			% ?debug("Camp = ~p",[{AtkOid, Camp}]),
			case Skill_Cast_Point of
				?SKILL_CAST_SELF ->
					collect_self_list(Scene,Camp,AtkOid,CollRelation,AleretPos);
				?SKILL_CAST_TARGET ->
					collect_target_list(Scene,Camp,AtkOid,Pos,TargetID,CollRelation,SkillCastDis,AleretPos);
				?SKILL_CAST_SELF_AREA ->
					collect_self_area_list(Scene,Camp,AtkOid,Pos,Dir,Skill_AREA,ParList,CollRelation,CollNum,SkillAi,ACR,AleretPos);
				?SKILL_CAST_TARGET_AREA ->
					collect_target_area_list(Scene,Camp,AtkOid,Pos,Dir,TargetID,Skill_AREA,ParList,CollRelation,CollNum,SkillAi,SkillCastDis,AleretPos);
				_ -> ?log_warning("skill castpoint config error,Skill_Cast_Point=~p~n",[Skill_Cast_Point]),[]
			end;
		_ -> []
	end.

%%SKILL_CAST_SELF
collect_self_list(Scene,Camp,AtkOid,CollRelation,_AleretPos) -> 
	fun_scene_collect_obj:collect_obj({self, AtkOid},Camp,Scene,0,{?ATK_NORMAL, 0},CollRelation).

%%SKILL_CAST_TARGET
collect_target_list(Scene,Camp,AtkOid,{X,_Y,Z},TargetID,CollRelation,SkillCastDis1,_AleretPos) ->
	SkillCastDis = SkillCastDis1 + 0.5,
	NoYStartPos = {X,0,Z},
	case fun_scene_obj:get_obj(TargetID) of
		#scene_spirit_ex{pos={Mx,_My,Mz},die=false,data=#scene_monster_ex{type=Type}} ->
			MR = get_monster_r(Type),
			NoYMonPos = {Mx,0,Mz},
			D = tool_vect:lenght(tool_vect:dec(tool_vect:to_map_point(NoYMonPos), tool_vect:to_map_point(NoYStartPos))) - MR,
			if
				D =< SkillCastDis -> 
					fun_scene_collect_obj:collect_obj({target,AtkOid,TargetID},Camp,Scene,0,{?ATK_NORMAL, 0},CollRelation);
				true -> []
			end;
		#scene_spirit_ex{pos={Mx,_My,Mz},die=false}->
			NoYMonPos = {Mx,0,Mz},
			D = tool_vect:lenght(tool_vect:dec(tool_vect:to_map_point(NoYMonPos), tool_vect:to_map_point(NoYStartPos))),
			if
				D =< SkillCastDis ->
					fun_scene_collect_obj:collect_obj({target,AtkOid,TargetID},Camp,Scene,0,{?ATK_NORMAL, 0},CollRelation);
				true -> []
			end;
		_ -> []
	end.
get_monster_r(Type)->
	case data_monster:get_monster(Type) of
		#st_monster_config{monster_r= Monster_r} -> Monster_r;
		_ -> 0
	end.

%%SKILL_CAST_SELF_AREA
collect_self_area_list(Scene,Camp,AtkOid,Pos,Dir,Skill_AREA,ParList,CollRelation,CollNum,SkillAi,ACR,AleretPos) ->
	NPos=case AleretPos of
		no ->
			if
				 ACR == 0 -> Pos;
				 true -> get_dis_center_cast_point(Pos,Dir,ACR)
			end;
		_ -> AleretPos
	end,
	case Skill_AREA of
		?AREA_SECTOR ->
			fun_scene_collect_obj:collect_obj({sector,AtkOid,NPos,Dir,ParList},Camp,Scene,CollNum,SkillAi,CollRelation);
		?AREA_CYCLE ->
			fun_scene_collect_obj:collect_obj({cir,AtkOid,NPos,Dir,ParList},Camp,Scene,CollNum,SkillAi,CollRelation);
		?AREA_RECT ->
			fun_scene_collect_obj:collect_obj({rect,AtkOid,NPos,Dir,ParList},Camp,Scene,CollNum,SkillAi,CollRelation);
		?AREA_RING ->
			fun_scene_collect_obj:collect_obj({ring,AtkOid,NPos,Dir,ParList},Camp,Scene,CollNum,SkillAi,CollRelation);
		?AREA_POINT ->
			fun_scene_collect_obj:collect_obj({self, AtkOid},Camp,Scene,CollNum,SkillAi,CollRelation);
		_ -> ?log_warning("skill impactarea config error,Skill_AREA=~p~n",[Skill_AREA]),[]
	end.

%%SKILL_CAST_TARGET_AREA
collect_target_area_list(Scene,Camp,AtkOid,Pos,Dir,TargetID,Skill_AREA,ParList,CollRelation,CollNum,SkillAi,SkillCastDis,AleretPos) ->
	% ?debug("AleretPos = ~p",[AleretPos]),
	case AleretPos of
		no ->
			case fun_scene_obj:get_obj(TargetID) of
				TargetObj when erlang:is_record(TargetObj, scene_spirit_ex) ->
					TOPos=TargetObj#scene_spirit_ex.pos,
					Monster_r = if
						TargetObj#scene_spirit_ex.sort == ?SPIRIT_SORT_MONSTER -> get_monster_r(TargetObj#scene_spirit_ex.data#scene_monster_ex.type);
						true -> 0
					end,
					collect_target_area_action(Scene,Camp,AtkOid,Pos,Dir,TOPos,TargetID,Skill_AREA,ParList,CollRelation,CollNum,SkillAi,SkillCastDis,Monster_r);
				_ -> []
			end;
		_ -> 
			Monster_r=case fun_scene_obj:get_obj(TargetID,?SPIRIT_SORT_MONSTER) of
				TargetObj when erlang:is_record(TargetObj, scene_spirit_ex) ->
					get_monster_r(TargetObj#scene_spirit_ex.data#scene_monster_ex.type);
				_ -> 0	
			end,
			collect_target_area_action(Scene,Camp,AtkOid,Pos,Dir,AleretPos,TargetID,Skill_AREA,ParList,CollRelation,CollNum,SkillAi,SkillCastDis,Monster_r)	
	end.
collect_target_area_action(Scene,Camp,AtkOid,Pos,Dir,TOPos,TargetID,Skill_AREA,ParList,CollRelation,CollNum,SkillAi,SkillCastDis,Monster_r) ->
	D = tool_vect:lenght(tool_vect:dec(tool_vect:to_map_point(TOPos), tool_vect:to_map_point(Pos)))-Monster_r,
	if
		D =< SkillCastDis ->
			case Skill_AREA of
				?AREA_SECTOR ->
					fun_scene_collect_obj:collect_obj({sector,AtkOid,TOPos,Dir,ParList},Camp,Scene,CollNum,SkillAi,CollRelation);
				?AREA_CYCLE ->
					fun_scene_collect_obj:collect_obj({cir,AtkOid,TOPos,Dir,ParList},Camp,Scene,CollNum,SkillAi,CollRelation);
				?AREA_RECT ->
					fun_scene_collect_obj:collect_obj({rect,AtkOid,TOPos,Dir,ParList},Camp,Scene,CollNum,SkillAi,CollRelation);
				?AREA_RING ->
					fun_scene_collect_obj:collect_obj({ring,AtkOid,TOPos,Dir,ParList},Camp,Scene,CollNum,SkillAi,CollRelation);
				?AREA_POINT ->
					fun_scene_collect_obj:collect_obj({target,AtkOid,TargetID},Camp,Scene,CollNum,SkillAi,CollRelation);
				_ -> ?log_warning("skill impactarea config error,Skill_AREA=~p~n",[Skill_AREA]),[]
			end;
		true -> []%%客户端有技能释放距离判
	end.

count_buff_effect(AdderObj,Obj,Sort,Type,DemageGet) ->
	ObjBattle = Obj#scene_spirit_ex.final_property,
	case Type of
		?PROPERTY_HP -> 
			CurHp = Obj#scene_spirit_ex.hp,
			MaxHp = ObjBattle#battle_property.hpLimit,
			Demage = if
				DemageGet < 0 ->
					case Sort of
						?BUFF_SORT_DOT_NUM -> -1 * DemageGet;
						?BUFF_SORT_DOT_PER -> util:ceil(MaxHp * util:abs(DemageGet) / 10000)
					end;
				true ->
					case Sort of
						?BUFF_SORT_DOT_NUM -> -1 * DemageGet;
						?BUFF_SORT_DOT_PER -> -1 * util:ceil(MaxHp * DemageGet / 10000)
					end
			end,
			%%无敌buff阻挡伤害
			Demage1 = if
				Demage > 0 ->
					case fun_scene_buff:can_be_atk(AdderObj#scene_spirit_ex.buffs) of
						true -> 0;
						_ -> Demage
					end;
				true -> Demage
			end,
%% 			Demage = case Sort of
%% 						 ?BUFF_SORT_DOT_NUM -> DemageGet;
%% 						 ?BUFF_SORT_DOT_PER -> util:ceil(MaxHp * DemageGet / 10000)
%% 					 end,
			
%% 			?debug("CurHp = ~p,MaxHp = ~p",[CurHp,MaxHp]),
%% 			?debug("Demage = ~p",[Demage]),
			{DefWay,RealDemage} = if
				Demage1 < 0 -> 
					if
						CurHp >= MaxHp -> {skip,0};
						true ->
							if
								CurHp - Demage1 > MaxHp -> {treat,-1 * (MaxHp - CurHp)};
								true -> {treat,Demage1}
							end
					end;
				CurHp - Demage1 < 0 -> {no,CurHp};
				true -> {no,Demage1}
			end,
%% 			?debug("{DefWay,RealDemage} = ~p",[{DefWay,RealDemage}]),
			{AdderObj#scene_spirit_ex.id,Obj#scene_spirit_ex.id,hit,DefWay,RealDemage,null};
		?PROPERTY_MP ->
			CurMp = Obj#scene_spirit_ex.mp,
			MaxMp = ObjBattle#battle_property.mpLimit,
			
			Demage = if
				DemageGet < 0 ->
					case Sort of
						?BUFF_SORT_DOT_NUM -> -1 * DemageGet;
						?BUFF_SORT_DOT_PER -> util:ceil(MaxMp * util:abs(DemageGet) / 10000)
					end;
				true ->
					case Sort of
						?BUFF_SORT_DOT_NUM -> -1 * DemageGet;
						?BUFF_SORT_DOT_PER -> -1 * util:ceil(MaxMp * DemageGet / 10000)
					end
			end,
%% 			Demage = case Sort of
%% 						 ?BUFF_SORT_DOT_NUM -> DemageGet;
%% 						 ?BUFF_SORT_DOT_PER -> util:ceil(MaxMp * DemageGet / 10000)
%% 					 end,
			{DefWay,RealDemage} = if
				Demage == 0 -> {skip,0};
				Demage < 0 ->
					if
						CurMp >= MaxMp -> {skip,0};
						true -> {treat_mp, Demage}
					end;
				CurMp - Demage < 0 -> {treat_mp,Demage};
				true -> {treat_mp, Demage}
			end,
			{AdderObj#scene_spirit_ex.id,Obj#scene_spirit_ex.id,hit,DefWay,RealDemage,null};
		_ -> null
	end.
	
count_buff_skill_effects(AtkOid,BeAtkedObj = #scene_spirit_ex{id = BeAtkedOid},Buff = #scene_buff{power=Power}) ->
	% ?debug("-----count_buff_skill_effects---------AdderObj=~p,BeAtkedObj=~p,BeAtkedOid=~p,Buff=~p",[AtkOid,BeAtkedObj,BeAtkedOid,Buff]),
	case data_buff:get_data(Buff#scene_buff.type) of
		#st_buff_config{data1 = Data1, script = DmgScript} -> 
			BuffDes = {Buff#scene_buff.type,Buff#scene_buff.power,Buff#scene_buff.mix_lev},
			case fun_scene_obj:get_obj(AtkOid) of
				AtkObj = #scene_spirit_ex{} -> 
					AtkBattle = AtkObj#scene_spirit_ex.final_property,
					BeAtkedBattle = BeAtkedObj#scene_spirit_ex.final_property,
					Module = util:to_atom("fun_battle_" ++ DmgScript),
					DodRate = erlang:apply(Module, get_dodRate, [{AtkOid,AtkBattle},{BeAtkedOid,BeAtkedBattle},BuffDes]),
					CriRate = erlang:apply(Module, get_criRate, [{AtkOid,AtkBattle},{BeAtkedOid,BeAtkedBattle},BuffDes]),
					BlockRate = erlang:apply(Module, get_blockRata, [{AtkOid,AtkBattle},{BeAtkedOid,BeAtkedBattle},BuffDes]),
					Rand = util:rand(0, 999999),
					DodVal = DodRate * 1000000,
					CriVal = CriRate * 1000000,
					BlockVal = BlockRate * 1000000,
					Way = if
						Rand < DodVal -> dod;
						Rand < DodVal + BlockVal -> block;
						Rand < DodVal + BlockVal + CriVal -> cri;
						true -> hit
					end,
					case Way of
						dod -> [{AtkOid,BeAtkedOid,dod,no,0,null}];
						_ ->
							IsBanish=fun_scene_buff:is_banish(BeAtkedObj#scene_spirit_ex.buffs),%%放逐不受伤
							IsCanBeAtk = fun_scene_buff:can_be_atk(BeAtkedObj#scene_spirit_ex.buffs), %%无敌不受伤
							if
								IsBanish == true -> [{AtkOid,BeAtkedOid,Way,no,0,null}];
								IsCanBeAtk == true -> [{AtkOid,BeAtkedOid,Way,no,0,null}];
								true ->				
									Demage1 = erlang:apply(Module, get_demage, [{AtkOid,AtkBattle},{BeAtkedOid,BeAtkedBattle},BuffDes,Buff#scene_buff.from_skill]),
									Demage = if
												 Power > 0 -> Demage1;
												 true -> -1 * Demage1
											 end,
									RealDemage1 = case Way of
													  cri -> erlang:apply(Module, get_cri_demage, [{AtkOid,AtkBattle},{BeAtkedOid,BeAtkedBattle},BuffDes,Demage]);
													  block -> erlang:apply(Module, get_block_demage, [{AtkOid,AtkBattle},{BeAtkedOid,BeAtkedBattle},BuffDes,Demage]);
													  _ -> Demage
												  end,
									TargetHp = BeAtkedObj#scene_spirit_ex.hp,
									{DefWay,NewRealDemage} = if
																 RealDemage1 < 0 -> {treat,RealDemage1};
																 TargetHp - RealDemage1 < 0 -> {no,TargetHp};
																 true -> {no,RealDemage1}
															 end,
									
									RealDemage  = case DefWay of
													  treat ->
														  TargetMaxHp = BeAtkedBattle#battle_property.hpLimit,
														  if
															  TargetHp - NewRealDemage > TargetMaxHp -> -1 * (TargetMaxHp - TargetHp);
															  true -> NewRealDemage
														  end;
													  _ -> NewRealDemage
												  end,
									{NewDefWay1,DamageData} = case DefWay of
										treat -> {DefWay,0};
										_ ->
											case Buff#scene_buff.from_skill of 
												{Skill,Lev} -> 
													KickType = case data_skillperformance:get_skillperformance(Skill) of
														#st_skillperformance_config{kick_type = GetKickType} -> GetKickType;
														_ -> "NO"
													end,
													GetDamageData = make_demage_data(AtkObj,BeAtkedObj,Skill),
													NBeAtkedObj=fun_scene_buff:add_skill_target_buff(AtkOid,BeAtkedObj,{Skill,Lev}, data_skillleveldata:get_skillleveldata(Skill),?BUFF_SKILL,Buff#scene_buff.type),
													fun_scene_obj:update(NBeAtkedObj#scene_spirit_ex{stifle=0}),
													DefWay1 = case KickType of
														"KICKBACK" -> stifle;
														"KICKDOWN" -> kickdown;
														"KICKFLY" -> kick;
														_ -> no
													end,
													{DefWay1,GetDamageData};
												_ -> {DefWay,0}
											end
									end,
									NewDefWay = case Data1 of
										?PROPERTY_MP -> treat_mp;
										_ -> NewDefWay1
									end,
									% ?debug("RealDemage = ~p",[RealDemage]),
									count_usr_demage(AtkOid, BeAtkedObj, RealDemage),
									count_scene_damage(AtkOid, AtkObj#scene_spirit_ex.sort, RealDemage),
									[{AtkOid,BeAtkedOid,Way,NewDefWay,RealDemage,DamageData}]
							end
					end;
				_ ->
					[{AtkOid,BeAtkedOid,dod,no,0,null}]
			end;
		_ -> [{AtkOid,BeAtkedOid,dod,no,0,null}]
	end.

count_skill_effects(AtkObj = #scene_spirit_ex{id = AtkOid},#scene_spirit_ex{id = AtkOid},SkillType,Lev,EffectsType) ->	
	case data_skillleveldata:get_skillleveldata(SkillType) of
		#st_skillleveldata_config{dmgScript=""} -> 
			BuffReleaseType = case data_skillperformance:get_skillperformance(SkillType) of
				#st_skillperformance_config{buffReleaseType = BuffReleaseType1} -> BuffReleaseType1; 
				_ -> "NO"
			end,
			%%命中buff处理
			Cnf = data_skillleveldata:get_skillleveldata(SkillType),
			BeAtkedObj=fun_scene_buff:add_skill_target_buff(AtkOid,AtkObj,{SkillType,Lev},Cnf,EffectsType,BuffReleaseType),
			{BeAtkedObj,[{AtkOid,AtkOid,dod,no,0,null}]};
		#st_skillleveldata_config{dmgScript= DmgScript} -> 
			AtkBattle = AtkObj#scene_spirit_ex.final_property,
			Module = util:to_atom("fun_battle_" ++ DmgScript),
			DodRate = erlang:apply(Module, get_dodRate, [{AtkOid,AtkBattle},{AtkOid,AtkBattle},{SkillType,Lev}]),
			CriRate = erlang:apply(Module, get_criRate, [{AtkOid,AtkBattle},{AtkOid,AtkBattle},{SkillType,Lev}]),
			BlockRate = erlang:apply(Module, get_blockRata, [{AtkOid,AtkBattle},{AtkOid,AtkBattle},{SkillType,Lev}]),
			Rand = util:rand(0, 999999),
			DodVal = DodRate * 1000000,
			CriVal = CriRate * 1000000,
			BlockVal = BlockRate * 1000000,
			Way = if
				Rand < DodVal -> dod;
				Rand < DodVal + BlockVal -> block;
				Rand < DodVal + BlockVal + CriVal -> cri;
				true -> hit
			end,
			case Way of
				dod -> 
					{AtkObj,[{AtkOid,AtkOid,dod,no,0,null}]};
				_ ->
					IsCanBeAtk = fun_scene_buff:can_be_atk(AtkObj#scene_spirit_ex.buffs), %%无敌 放逐不受伤
					if
						IsCanBeAtk == true -> {AtkObj,[{AtkOid,AtkOid,Way,no,0,null}]};
						true ->
							Demage = erlang:apply(Module, get_demage, [{AtkOid,AtkBattle},{AtkOid,AtkBattle},{SkillType,Lev}]),
							RealDemage1 = case Way of
								cri -> erlang:apply(Module, get_cri_demage, [{AtkOid,AtkBattle},{AtkOid,AtkBattle},{SkillType,Lev},Demage]);
								block -> erlang:apply(Module, get_block_demage, [{AtkOid,AtkBattle},{AtkOid,AtkBattle},{SkillType,Lev},Demage]);
								_ -> Demage
							end,
							{RealDemage, OtherEffects} = fun_scene_buff:count_demage(AtkObj, AtkObj, RealDemage1),
							DefWay =  no,
							TargetHp = AtkObj#scene_spirit_ex.hp,
							DefWay1 = if
								RealDemage < 0 -> treat;
								true -> DefWay
							end,
							NewRealDemage2 = case DefWay1 of
								treat ->
									TargetMaxHp = AtkBattle#battle_property.hpLimit,
									if
										TargetHp - RealDemage > TargetMaxHp -> -1 * (TargetMaxHp - TargetHp);
										true -> RealDemage
									end;
								_ -> RealDemage
							end,
							%%受到伤害删除buff
							BuffReleaseType = case data_skillperformance:get_skillperformance(SkillType) of
								#st_skillperformance_config{buffReleaseType = BuffReleaseType1} -> BuffReleaseType1;
								_ -> "NO"
							end,
							%%命中buff处理
							Cnf = data_skillleveldata:get_skillleveldata(SkillType),
							BeAtkedObj=fun_scene_buff:add_skill_target_buff(AtkOid,AtkObj,{SkillType,Lev},Cnf,EffectsType,BuffReleaseType),
							
							count_usr_demage(AtkOid, BeAtkedObj, NewRealDemage2),
							count_scene_damage(AtkOid, AtkObj#scene_spirit_ex.sort, NewRealDemage2),
							{BeAtkedObj,[{AtkOid,AtkOid,Way,DefWay1,NewRealDemage2,0} | OtherEffects]}
					end
			end;
		_ -> 
			{AtkObj,[{AtkOid,AtkOid,dod,no,0,null}]}
	end;
count_skill_effects(AtkObj = #scene_spirit_ex{id = AtkOid,camp=AtkCamp},BeAtkedObj = #scene_spirit_ex{id = BeAtkedOid,camp=BeAtkCamp},SkillType,Lev,EffectsType) ->	
	case data_skillleveldata:get_skillleveldata(SkillType) of
		#st_skillleveldata_config{dmgScript=""} -> 
			IsCanBeAtk = fun_scene_buff:can_be_atk(BeAtkedObj#scene_spirit_ex.buffs), %%无敌 放逐不受伤
			if
				IsCanBeAtk == true -> {AtkObj,[{AtkOid,BeAtkedOid,dod,no,0,null}]};
				true ->	
					BuffReleaseType = case data_skillperformance:get_skillperformance(SkillType) of
										   #st_skillperformance_config{buffReleaseType = BuffReleaseType1} -> BuffReleaseType1; 
										   _ -> "NO"
									   end,
					%%命中buff处理
					Cnf = data_skillleveldata:get_skillleveldata(SkillType),
					NewBeAtkedObj4=fun_scene_buff:add_skill_target_buff(AtkOid,BeAtkedObj,{SkillType,Lev}, Cnf,EffectsType,BuffReleaseType),
					case NewBeAtkedObj4 of
						#scene_spirit_ex{sort=?SPIRIT_SORT_MONSTER} ->
							case fun_scene_collect_obj:is_hate_relation(AtkOid,BeAtkedOid,AtkCamp,BeAtkCamp) of
								true -> skip;
								_ ->
									fun_scene_obj:update(NewBeAtkedObj4)
							end;
						_ ->
							fun_scene_obj:update(NewBeAtkedObj4)
					end,
					{AtkObj,[{AtkOid,BeAtkedOid,dod,no,0,null}]}
			end;
		#st_skillleveldata_config{dmgScript= DmgScript} -> 
			AtkBattle = AtkObj#scene_spirit_ex.final_property,
			BeAtkedBattle = BeAtkedObj#scene_spirit_ex.final_property,
			Module = util:to_atom("fun_battle_" ++ DmgScript),
			DodRate = erlang:apply(Module, get_dodRate, [{AtkOid,AtkBattle},{BeAtkedOid,BeAtkedBattle},{SkillType,Lev}]),
			CriRate = erlang:apply(Module, get_criRate, [{AtkOid,AtkBattle},{BeAtkedOid,BeAtkedBattle},{SkillType,Lev}]),
			BlockRate = erlang:apply(Module, get_blockRata, [{AtkOid,AtkBattle},{BeAtkedOid,BeAtkedBattle},{SkillType,Lev}]),
			Rand = util:rand(0, 999999),
			DodVal = DodRate * 1000000,
			CriVal = CriRate * 1000000,
			BlockVal = BlockRate * 1000000,
			Way = if
					  Rand < DodVal -> dod;
					  Rand < DodVal + BlockVal -> block;
					  Rand < DodVal + BlockVal + CriVal -> cri;
					  true -> hit
				  end,
			case Way of
				dod -> 
					{AtkObj,[{AtkOid,BeAtkedOid,dod,no,0,null}]};
				_ ->
					IsCanBeAtk = fun_scene_buff:can_be_atk(BeAtkedObj#scene_spirit_ex.buffs), %%无敌 放逐不受伤
					if
						IsCanBeAtk == true -> {AtkObj,[{AtkOid,BeAtkedOid,Way,no,0,null}]};
						true ->					
							Demage = erlang:apply(Module, get_demage, [{AtkOid,AtkBattle},{BeAtkedOid,BeAtkedBattle},{SkillType,Lev}]),
							Demage2 = case Way of
								cri -> erlang:apply(Module, get_cri_demage, [{AtkOid,AtkBattle},{BeAtkedOid,BeAtkedBattle},{SkillType,Lev},Demage]);
								block -> erlang:apply(Module, get_block_demage, [{AtkOid,AtkBattle},{BeAtkedOid,BeAtkedBattle},{SkillType,Lev},Demage]);
								_ -> Demage
							end,
							{Demage3, OtherEffects} = fun_scene_buff:count_demage(AtkObj, BeAtkedObj, Demage2),
							RealDemage = mod_scene_entourage:cacl_zhenfa_add_damage(AtkObj, BeAtkedObj, Demage3),
							
							KickType = case data_skillperformance:get_skillperformance(SkillType) of
										   #st_skillperformance_config{kick_type = GetKickType} -> GetKickType;
										   _ -> "NO"
									   end,
							DamageData = make_demage_data(AtkObj,BeAtkedObj,SkillType),
							NewBeAtkedObj2  = BeAtkedObj#scene_spirit_ex{stifle=0},
							DefWay = case KickType of
								?SKILL_KICK_BACK -> stifle;
								?SKILL_KICK_DOWN -> kickdown;
								?SKILL_KICK_FLY -> kick;
								_ -> no
							end,
								   
							
							%%濒死判断
							TargetHp = NewBeAtkedObj2#scene_spirit_ex.hp,
							DefWay2 = if
										  RealDemage < 0 -> treat;
										  true -> DefWay
									  end,
							
							NewAtkObj3 = AtkObj,
							
							NewRealDemage2 = case DefWay2 of
												 treat ->
													 TargetMaxHp = BeAtkedBattle#battle_property.hpLimit,
													 if
														 TargetHp - RealDemage > TargetMaxHp -> -1 * (TargetMaxHp - TargetHp);
														 true -> RealDemage
													 end;
												 _ -> RealDemage
											 end,
							
							%%受到伤害删除buff
							NewBeAtkedObj3=fun_scene_buff:del_skill_target_buff(NewBeAtkedObj2),
							
							BuffReleaseType = case data_skillperformance:get_skillperformance(SkillType) of
										   #st_skillperformance_config{buffReleaseType = BuffReleaseType1} -> BuffReleaseType1; 
										   _ -> "NO"
									   end,
							
							%%命中buff处理
							Cnf = data_skillleveldata:get_skillleveldata(SkillType),
							NewBeAtkedObj4=fun_scene_buff:add_skill_target_buff(AtkOid,NewBeAtkedObj3,{SkillType,Lev},Cnf,EffectsType,BuffReleaseType),
							{ok, NewAtkObj4, NewBeAtkedObj5} = fun_scene_passive_skill:trigger_skill(NewAtkObj3, NewBeAtkedObj4, NewRealDemage2, get_skill_type(SkillType)),
							case NewBeAtkedObj5 of
								#scene_spirit_ex{sort=?SPIRIT_SORT_MONSTER} ->
									case fun_scene_collect_obj:is_hate_relation(AtkOid,BeAtkedOid,AtkCamp,BeAtkCamp) of
										true -> skip;
										_ ->
											fun_scene_obj:update(NewBeAtkedObj5#scene_spirit_ex{stifle = 0})
									end;
								_ ->
									fun_scene_obj:update(NewBeAtkedObj5#scene_spirit_ex{stifle = 0})
							end,
							
							count_usr_demage(AtkOid, BeAtkedObj, NewRealDemage2),
							count_scene_damage(AtkOid, AtkObj#scene_spirit_ex.sort, NewRealDemage2),
							{NewAtkObj4,[{AtkOid,BeAtkedOid,Way,DefWay2,NewRealDemage2,DamageData} | OtherEffects]}
					end
			end;
		_ -> 
			{AtkObj,[{AtkOid,BeAtkedOid,dod,no,0,null}]}
	end.

check_cd(ID,Skill_List,Normal_Skill) when erlang:is_integer(ID)->
	case fun_scene_obj:get_obj(ID,?SPIRIT_SORT_MONSTER) of
		Monster when erlang:is_record(Monster, scene_spirit_ex) ->
			check_cd(Monster,Skill_List,Normal_Skill);
		_ -> 0
	end;
check_cd(Object,Skill_List,Normal_Skill) ->
	case Skill_List of
		[0]	->
			checknormal(Object, Normal_Skill);
		_	->
			Fun=fun(SkillID) ->
					case fun_scene_cd:get_cd_by_type(Object, SkillID) of
						[] -> true;
						_ -> false
					end	 
				end,
			Check_List=lists:filter(Fun, Skill_List),
			case Check_List of
				[Skill|_] ->
					case Skill of
						0 -> checknormal(Object, Normal_Skill);
						_ -> Skill
					end;
				_ -> checknormal(Object, Normal_Skill)
			end
	end.

checknormal(Monster,Normal_Skill) -> 
	case fun_scene_cd:get_cd_by_type(Monster, Normal_Skill) of
		[] -> Normal_Skill;
		_ -> 0
	end.

get_atk_sort_num(dod) -> ?ATT_SORT_DODGE;
get_atk_sort_num(cri) -> ?ATT_SORT_CRIT;
get_atk_sort_num(clock) -> ?ATT_SORT_HIGHDEF;
get_atk_sort_num(_) -> ?ATT_SORT_NARMAL.


get_def_sort_num(treat) -> ?DEF_SORT_TREAT;
get_def_sort_num(treat_mp) -> ?DEF_SORT_TREAT_MP;
get_def_sort_num(die) -> ?DEF_SORT_DIE;
get_def_sort_num(stifle) -> ?DEF_SORT_STIFLE;
get_def_sort_num(kickdown) -> ?DEF_SORT_KICKDOWN;
get_def_sort_num(kick) -> ?DEF_SORT_KICK;
get_def_sort_num(untreat) -> ?DEF_SORT_UNTREAT;
get_def_sort_num(nokickdown) -> ?DEF_SORT_NOKICKDOWN;
get_def_sort_num(nostifle) -> ?DEF_SORT_NOSTIFLE;
get_def_sort_num(nokick) -> ?DEF_SORT_NOKICK;
get_def_sort_num(no_mp) -> ?DEF_SORT_NO_MP;
get_def_sort_num(_) -> ?DEF_SORT_NO.


make_skill_aleret_data(AleretTime,AleretPos,SkillData) ->
	Now = util:longunixtime(),
	#skill_aleret_data{start_time = Now,all_time = AleretTime,point = AleretPos,skill_data = SkillData}.

make_skill_data(Obj,TargetID,SkillType) -> 
	case data_skillperformance:get_skillperformance(SkillType) of
		#st_skillperformance_config{time_yz_start= YzStart,time_yz= Yz,time_bt_start= BtStart,time_bt= Bt,time_wd_start= WdStart
									,time_wd= Wd,selfShiftType= "NO",selfShiftRange = _Range,shiftDirection = _Dir} ->
			#skill_data{start_time = util:longunixtime(),yz_start = YzStart, yz_time = Yz,bt_start = BtStart, bt_time = Bt
						,wd_start = WdStart ,wd_time = Wd ,move_sort = 0,move_speed = 0,move_data = 0};
		#st_skillperformance_config{time_yz_start= YzStart,time_yz= Yz,time_bt_start= BtStart,time_bt= Bt,time_wd_start= WdStart
									,time_wd= Wd,selfShiftType= "PATH",selfShiftRange = _Range,shiftDirection = ShiftDir} ->
%% 			?debug("make_skill_data PATH"),
			case fun_scene_obj:get_obj(TargetID) of
				Target = #scene_spirit_ex{data=#scene_monster_ex{type=MType}} ->
					MR = get_monster_r(MType),
%% 					?debug("---------ShiftDir=~p,MR=~p,pos=~p,ObjPos=~p",[ShiftDir,MR,Target#scene_spirit_ex.pos,Obj#scene_spirit_ex.pos]),
					DirVect1 = tool_vect:dec(tool_vect:to_map_point(Target#scene_spirit_ex.pos),tool_vect:to_map_point(Obj#scene_spirit_ex.pos)),
					Dis1 = tool_vect:lenght(DirVect1),
					{DirVect,Dis} = if
										ShiftDir > 0 -> {DirVect1,(Dis1 + ShiftDir+MR)};
										true -> 
											if
												Dis1 > MR - ShiftDir -> {DirVect1,Dis1 - (MR - ShiftDir)};
												true -> {DirVect1, 0}
											end
									end,
					Now = util:longunixtime(),
					ToPoint = case fun_scene_map:check_dir(tool_vect:to_map_point(Obj#scene_spirit_ex.pos), DirVect, Dis) of
								  {_,_GetDis,#map_point{x = ToX,y = ToY,z = ToZ}} ->
									  {ToX,ToY,ToZ};
								  _ ->Obj#scene_spirit_ex.pos
							  end,
%% 					?debug("make_skill_data PATH ToPoint =~p",[ToPoint]), 
					#skill_data{start_time = Now,yz_start = YzStart, yz_time = Yz,bt_start = BtStart, bt_time = Bt
								,wd_start = WdStart ,wd_time = Wd ,move_sort = "PATH",move_speed = 100
								,move_data = #move_data{start_time = Now,all_time = 0,to_pos = ToPoint,move_speed = 100,next = []}};
				Target = #scene_spirit_ex{} -> 
					DirVect1 = tool_vect:dec(tool_vect:to_map_point(Target#scene_spirit_ex.pos),tool_vect:to_map_point(Obj#scene_spirit_ex.pos)),
					Dis1 = tool_vect:lenght(DirVect1),
					{DirVect,Dis} =if
									   ShiftDir > 0 -> {DirVect1,(Dis1 + ShiftDir+1)};
									   true -> 
										   if
											   Dis1 > 1 - ShiftDir -> {DirVect1,Dis1 - (1 - ShiftDir)};
											   true -> {DirVect1, 0}
										   end
								   end,
					Now = util:longunixtime(),
					ToPoint = case fun_scene_map:check_dir(tool_vect:to_map_point(Obj#scene_spirit_ex.pos), DirVect, Dis) of
								  {_,_GetDis,#map_point{x = ToX,y = ToY,z = ToZ}} ->
									  {ToX,ToY,ToZ};
								  _ -> Obj#scene_spirit_ex.pos
							  end,
%% 					?debug("make_skill_data PATH ToPoint =~p",[ToPoint]),
					#skill_data{start_time = Now,yz_start = YzStart, yz_time = Yz,bt_start = BtStart, bt_time = Bt
								,wd_start = WdStart ,wd_time = Wd ,move_sort = "PATH",move_speed = 100
								,move_data = #move_data{start_time = Now,all_time = 0,to_pos = ToPoint,move_speed = 100,next = []}};
				_ -> 0
			end;
		#st_skillperformance_config{time_yz_start= YzStart,time_yz= Yz,time_bt_start= BtStart,time_bt= Bt,time_wd_start= WdStart
									,time_wd= Wd,selfShiftType= "DIRECTION",selfShiftRange = Range,shiftDirection = _ShiftDir} ->
			case fun_scene_obj:get_obj(TargetID) of
				Target = #scene_spirit_ex{} -> 
					DirVect1 = tool_vect:dec(tool_vect:to_map_point(Target#scene_spirit_ex.pos),tool_vect:to_map_point(Obj#scene_spirit_ex.pos)),
					{DirVect,Dis} = if
										Range > 0 -> {DirVect1,Range};
										true -> {tool_vect:ride(DirVect1, -1), Range * -1}
									end,
					Now = util:longunixtime(),
					
					case fun_scene_map:check_dir(tool_vect:to_map_point(Obj#scene_spirit_ex.pos), DirVect, Dis) of
						{_,GetDis,#map_point{x = ToX,y = ToY,z = ToZ}} ->
							ToPoint = {ToX,ToY,ToZ},
							if
								GetDis < 0.1 -> 
									#skill_data{start_time = Now,yz_start = YzStart, yz_time = Yz,bt_start = BtStart, bt_time = Bt
												,wd_start = WdStart ,wd_time = Wd ,move_sort = 0,move_speed = 0,move_data = 0};
								true ->
									#skill_data{start_time = Now,yz_start = YzStart, yz_time = Yz,bt_start = BtStart, bt_time = Bt
												,wd_start = WdStart ,wd_time = Wd ,move_sort = "PATH",move_speed = 100
												,move_data = #move_data{start_time = Now,all_time = 0,to_pos = ToPoint,move_speed = 100,next = []}}
							end;
						_ -> 
							#skill_data{start_time = Now,yz_start = YzStart, yz_time = Yz,bt_start = BtStart, bt_time = Bt
										,wd_start = WdStart ,wd_time = Wd ,move_sort = 0,move_speed = 0,move_data = 0}
					end;
				_ -> 0
			end;
		#st_skillperformance_config{time_yz_start= YzStart,time_yz= Yz,time_bt_start= BtStart,time_bt= Bt,time_wd_start= WdStart
									,time_wd= Wd,selfShiftType= "BLINK",selfShiftRange = Range,shiftDirection = _ShiftDir} ->
			DirVect1 = tool_vect:get_vect_by_dir(tool_vect:angle2radian(Obj#scene_spirit_ex.dir)),
			{DirVect,Dis} = if
								Range > 0 -> {DirVect1,Range};
								true -> {tool_vect:ride(DirVect1, -1), Range * -1}
							end,
			Now = util:longunixtime(),
			case fun_scene_map:check_dir(tool_vect:to_map_point(Obj#scene_spirit_ex.pos), DirVect, Dis) of
				{_,GetDis,#map_point{x = ToX,y = ToY,z = ToZ}} ->
					ToPoint = {ToX,ToY,ToZ},
					if
						GetDis < 0.1 -> 
							#skill_data{start_time = Now,yz_start = YzStart, yz_time = Yz,bt_start = BtStart, bt_time = Bt
										,wd_start = WdStart ,wd_time = Wd ,move_sort = 0,move_speed = 0,move_data = 0};
						true ->
							#skill_data{start_time = Now,yz_start = YzStart, yz_time = Yz,bt_start = BtStart, bt_time = Bt
										,wd_start = WdStart ,wd_time = Wd ,move_sort = "PATH",move_speed = 100
										,move_data = #move_data{start_time = Now,all_time = 0,to_pos = ToPoint,move_speed = 100,next = []}}
					end;
				_ -> 
					#skill_data{start_time = Now,yz_start = YzStart, yz_time = Yz,bt_start = BtStart, bt_time = Bt
								,wd_start = WdStart ,wd_time = Wd ,move_sort = 0,move_speed = 0,move_data = 0}
			end;
		_ -> 0
	end.

make_demage_data(Atk,Def,SkillType) -> 
	case data_skillperformance:get_skillperformance(SkillType) of
		#st_skillperformance_config{kick_type = "NO"} -> 0;
		#st_skillperformance_config{kick_type = Sort ,kickStartTime = Start,kickTimes = Times,kickdistance = Dis,kickSpeed = Speed} ->
			DisAbs=util:abs(Dis),
			if
				DisAbs > 0.1 ->
%% 					?debug("Dis = ~p",[Dis]),
					DirVect1 = tool_vect:dec(tool_vect:to_map_point(Def#scene_spirit_ex.pos),tool_vect:to_map_point(Atk#scene_spirit_ex.pos)),
					Lp = tool_vect:lenght_power(DirVect1#map_point{y = 0}),
					if
						Lp < 0.0001 -> 0;
						true ->
							{DirVect,NDis} = if
												 Dis > 0 -> {DirVect1,Dis};
												 true -> {tool_vect:ride(DirVect1, -1), Dis * -1}
											 end,
							Now = util:longunixtime(),
							case fun_scene_map:check_dir(tool_vect:to_map_point(Def#scene_spirit_ex.pos), DirVect, NDis) of
								{_,GetDis,#map_point{x = ToX,y = ToY,z = ToZ}} ->
									ToPoint = {ToX,ToY,ToZ},
									if
										GetDis < 0.1 -> 
											#demage_data{start_time = Now, jz_time = Times};
										true ->
											%% 									NextNeedTime = fun_scene:get_move_time(fun_scene_obj:get_pace_speed(Def),Speed,Def#scene_spirit_ex.pos,ToPoint),
											#demage_data{start_time = Now, jz_time = Start + Times,move_start = Start,move_sort = Sort,move_speed = Speed
														 ,move_data = #move_data{start_time = Now + Start,all_time = 0,to_pos = ToPoint,move_speed = Speed,next = []}}
									end;
								_R -> 
									%% 							?debug("_R = ~p",[_R]),
									#demage_data{start_time = Now, jz_time = Times}
							end
					end;
				true ->
					#demage_data{start_time = util:longunixtime(), jz_time = Times}
			end;
		_ -> 0
	end.

%% ?BUFF_SORT_DOT_NUM
buff_dot(Obj,Sort,Type,DotType,Power,AdderObj,Skill,Lev) ->
	case count_buff_effect(AdderObj,Obj,Sort,DotType,Power) of
		{_AtkOid,_DefOid,_AtkSort,_DefSort,0,_DemageData} -> Obj;
		{_AtkOid,_DefOid,_AtkSort,skip,_Demage,_DemageData} -> Obj;
		Effect = {AtkOid,_DefOid,AtkSort,DefSort,Demage,_DemageData} ->
			count_usr_demage(AtkOid,Obj,Demage),
			count_scene_damage(AtkOid,Obj#scene_spirit_ex.sort,Demage),
			{NSkill,NLev} = case data_buff:get_data(Type)of
				#st_buff_config{skilleffectEnable = 1} -> {Skill,Lev};
				_ -> {899998,1}
			end,
			NewObj = do_effects([Effect],Obj),
			ObjSort = fun_scene_obj:get_spirit_client_type(AtkOid),
			Curr_Hp=fun_scene_obj:get_spirit_hp(Obj#scene_spirit_ex.id),
			Curr_Mp=fun_scene_obj:get_spirit_mp(Obj#scene_spirit_ex.id),
			{X,Y,Z} = AdderObj#scene_spirit_ex.pos,
			Pt1 = #pt_scene_skill_effect{
				oid = AtkOid,
				obj_sort = ObjSort,
				cur_mp = Curr_Mp,
				skill = NSkill,
				lev = NLev,
				x = X,
				y = Y,
				z = Z,
				dir = AdderObj#scene_spirit_ex.dir,
				target_id = 0,
				target_x = 0,
				target_y = 0,
				target_z = 0
			},
			TargetSort = util_scene:server_obj_type_2_client_type(Obj#scene_spirit_ex.sort),
			Ptm = #pt_public_skill_effect{
				target_id = Obj#scene_spirit_ex.id,
				target_sort = TargetSort,
				atk_sort = fun_scene_skill:get_atk_sort_num(AtkSort),
				def_sort = fun_scene_skill:get_def_sort_num(DefSort),
				demage = util:abs(Demage),
				cur_hp = Curr_Hp,
				cur_mp = Curr_Mp,
				effect_x = 0,
				effect_y = 0,
				effect_z = 0
			},
			Pt = Pt1#pt_scene_skill_effect{effect_list = [Ptm]},
			fun_scene_obj:send_all_usr(proto:pack(Pt)),
			NewObj;
		_ -> Obj
	end.

arrow_skill(Obj,ArrowTarget,TargetType,{SkillType,SkillLev},ArrowType) ->
	%% 	?debug("skill data = ~p,Seq = ~p",[{Obj,TargetID,TargetPos},Seq]),
	Targets = collect_arrow_targets(Obj#scene_spirit_ex.id,ArrowTarget#scene_spirit_ex.pos,ArrowTarget#scene_spirit_ex.id,Obj#scene_spirit_ex.dir,TargetType,ArrowType),
	FunEffect = fun(Target, {GetObj,GetEffcts}) ->
		case count_skill_effects(GetObj,Target,SkillType,SkillLev,?ARROW_SKILL) of
			{NewGetObj,NewEffects} -> {NewGetObj, GetEffcts ++ NewEffects};
			_ -> {GetObj, GetEffcts}
		end
	end,
	{NewObj,Effects} = lists:foldr(FunEffect, {Obj,[]}, Targets),
	NewGetObj = case do_effects(Effects,NewObj) of
		GetObj when erlang:is_record(GetObj, scene_spirit_ex) -> 
			case fun_scene_obj:get_obj(GetObj#scene_spirit_ex.id) of
				#scene_spirit_ex{} ->
					fun_scene_obj:update(GetObj);
				_ -> GetObj
			end;
		_ -> no
	end,
	ObjSort = util_scene:server_obj_type_2_client_type(Obj#scene_spirit_ex.sort),
	Curr_Mp1=fun_scene_obj:get_spirit_mp(Obj#scene_spirit_ex.id),
	{X,Y,Z} = Obj#scene_spirit_ex.pos,
	Pt1 = #pt_scene_skill_effect{
		oid = Obj#scene_spirit_ex.id,
		obj_sort = ObjSort,
		cur_mp = Curr_Mp1,
		skill = SkillType,
		lev = SkillLev,
		x = X,
		y = Y,
		z = Z,
		dir = Obj#scene_spirit_ex.dir,
		target_id = ArrowTarget#scene_spirit_ex.id,
		target_x = 0,
		target_y = 0,
		target_z = 0
	},
	Fun = fun({_AtkOid,DefOid,AtkSort,DefSort,Demage,DemageData}) ->
		{EffectX,EffectY,EffectZ} = case DemageData of
			#demage_data{move_data = #move_data{to_pos = {X1,Y1,Z1}}}  -> {X1,Y1,Z1};							
			_ -> {0,0,0}						  
		end,
		Curr_Hp=fun_scene_obj:get_spirit_hp(DefOid),
		Curr_Mp=fun_scene_obj:get_spirit_mp(DefOid),
		TargetSort = fun_scene_obj:get_spirit_client_type(DefOid),
		#pt_public_skill_effect{
			target_id = DefOid,
			target_sort = TargetSort,
			atk_sort = fun_scene_skill:get_atk_sort_num(AtkSort),
			def_sort = fun_scene_skill:get_def_sort_num(DefSort),
			demage = util:abs(Demage),
			cur_hp = Curr_Hp,
			cur_mp = Curr_Mp,
			effect_x = EffectX,
			effect_y = EffectY,
			effect_z = EffectZ
		}
	end,
	Effects1 = lists:map(Fun, Effects),	
	Pt = Pt1#pt_scene_skill_effect{effect_list = Effects1},
	
%% 	?debug("Pt12 = ~p",[Pt12]),
	fun_scene_obj:send_cell_all_usr(ArrowTarget,proto:pack(Pt)),
	
	NewGetObj.

trap_skill(Obj,Pos,Dir,ACR,TargetType,{SkillType,SkillLev},TrapType) ->
	%% 	?debug("skill data = ~p",[{Obj,Pos,Dir,TargetType,{SkillType,SkillLev,SkillRune},TrapType}]),
	Targets = collect_trap_targets(Obj#scene_spirit_ex.id,Pos,Dir,ACR,TargetType,TrapType),
	FunEffect = fun(Target, {GetObj,GetEffcts}) ->
		case count_skill_effects(GetObj,Target,SkillType,SkillLev,?TRAP_SKILL) of
			{NewGetObj,NewEffects} -> {NewGetObj, GetEffcts ++ NewEffects};
			_ -> {GetObj, GetEffcts}
		end
	end,		
	{NewObj,Effects} = lists:foldr(FunEffect, {Obj,[]}, Targets),
	%% 	?debug("Effects=~p",[Effects]),		
	
	NewNewObj = case do_effects(Effects,NewObj) of
		GetObj when erlang:is_record(GetObj, scene_spirit_ex) -> 
			case fun_scene_obj:get_obj(GetObj#scene_spirit_ex.id) of
				#scene_spirit_ex{} ->
					fun_scene_obj:update(GetObj);
				_ -> GetObj
			end;
		_ -> no
	end,
	ObjSort = util_scene:server_obj_type_2_client_type(Obj#scene_spirit_ex.sort),
	Curr_Mp1=fun_scene_obj:get_spirit_mp(Obj#scene_spirit_ex.id),
	{X,Y,Z} = Obj#scene_spirit_ex.pos,
	Pt1 = #pt_scene_skill_effect{
		oid = Obj#scene_spirit_ex.id,
		obj_sort = ObjSort,
		skill = SkillType,
		cur_mp = Curr_Mp1,
		lev = SkillLev,
		x = X,
		y = Y,
		z = Z,
		dir = Obj#scene_spirit_ex.dir,
		target_id = 0,
		target_x = 0,
		target_y = 0,
		target_z = 0
	},
	Fun = fun({_AtkOid,DefOid,AtkSort,DefSort,Demage,DemageData}) ->
		{EffectX,EffectY,EffectZ} = case DemageData of
			#demage_data{move_data = #move_data{to_pos = {X1,Y1,Z1}}}  -> {X1,Y1,Z1};
			_ -> {0,0,0}
		end,
		Curr_Hp=fun_scene_obj:get_spirit_hp(DefOid),
		Curr_Mp=fun_scene_obj:get_spirit_mp(DefOid),
		TargetSort = fun_scene_obj:get_spirit_client_type(DefOid),
		#pt_public_skill_effect{
			target_id = DefOid,
			target_sort = TargetSort,
			atk_sort = fun_scene_skill:get_atk_sort_num(AtkSort),
			def_sort = fun_scene_skill:get_def_sort_num(DefSort),
			demage = util:abs(Demage),
			cur_hp = Curr_Hp,
			cur_mp = Curr_Mp,
			effect_x = EffectX,
			effect_y = EffectY,
			effect_z = EffectZ
		}
	end,	
	Effects1 = lists:map(Fun, Effects),	
	Pt = Pt1#pt_scene_skill_effect{effect_list = Effects1},
	%% 	?debug("Pt12=~p",[Pt12]),	
	fun_scene_obj:send_cell_all_usr(Obj,proto:pack(Pt)),
	NewNewObj.

buff_skill(Obj,Buff) ->
	%% 	?debug("buff_skill data = ~p",[{Obj,Buff}]),
	Targets = collect_buff_skill_target(Obj#scene_spirit_ex.id,Obj#scene_spirit_ex.pos,Obj#scene_spirit_ex.dir,Buff#scene_buff.type),
	% ?debug("Targets=~p",[Targets]),
	AtkOid = Buff#scene_buff.buff_adder,
	case fun_scene_obj:get_obj(AtkOid) of
		#scene_spirit_ex{} -> 
			EffectLists = [count_buff_skill_effects(AtkOid,Target,Buff)  || Target <-Targets],
			Effects = lists:append(EffectLists),
			NewObj = do_effects(Effects,Obj),			
			{Skill,Lev} = case data_buff:get_data(Buff#scene_buff.type)of
				#st_buff_config{skilleffectEnable = 1} -> Buff#scene_buff.from_skill;
				_ -> {899998,1}
			end,
			ObjSort = fun_scene_obj:get_spirit_client_type(Buff#scene_buff.buff_adder),
			Curr_Mp1=fun_scene_obj:get_spirit_mp(Buff#scene_buff.buff_adder),
			{X,Y,Z} = Obj#scene_spirit_ex.pos,
			Pt1 = #pt_scene_skill_effect{
				oid = Buff#scene_buff.buff_adder,
				obj_sort = ObjSort,
				cur_mp = Curr_Mp1,
				skill = Skill,
				lev = Lev,
				x = X,
				y = Y,
				z = Z,
				dir = Obj#scene_spirit_ex.dir,
				target_id = 0,
				target_x = 0,
				target_y = 0,
				target_z = 0
			},
			Fun = fun({_AtkOid,DefOid,AtkSort,DefSort,Demage,DemageData}) ->
				{EffectX,EffectY,EffectZ} = case DemageData of
					#demage_data{move_data = #move_data{to_pos = {X1,Y1,Z1}}}  -> {X1,Y1,Z1};							
					_ -> {0,0,0}						  
				end,
				Curr_Hp=fun_scene_obj:get_spirit_hp(DefOid),
				Curr_Mp=fun_scene_obj:get_spirit_mp(DefOid),
				TargetSort = fun_scene_obj:get_spirit_client_type(DefOid),
				#pt_public_skill_effect{
					target_id = DefOid,
					target_sort = TargetSort,
					atk_sort = fun_scene_skill:get_atk_sort_num(AtkSort),
					def_sort = fun_scene_skill:get_def_sort_num(DefSort),
					demage = util:abs(Demage),
					cur_hp = Curr_Hp,
					cur_mp = Curr_Mp,
					effect_x = EffectX,
					effect_y = EffectY,
					effect_z = EffectZ
				}
			end,	
			Effects1 = lists:map(Fun, Effects),	
			Pt = Pt1#pt_scene_skill_effect{effect_list = Effects1},
			fun_scene_obj:send_cell_all_usr(Obj,proto:pack(Pt)),
			NewObj;
		_ -> Obj
	end.

monster_cast_skill(Obj,TargetID,TargetPos,{Skill,SkillLev},AiCondition,AiSkillParam,Seq) ->
	case AiCondition of
		{?NEW_AI_TYPE_CALL_MONSTER_BY_HP, _} ->
			Pos = Obj#scene_spirit_ex.pos,
			Dir = Obj#scene_spirit_ex.dir,
			ai_skill_call_monster(Pos, Dir, AiSkillParam),
			do_skill_help(Obj, Obj, Skill, SkillLev, TargetID, TargetPos, [], 0, Seq, false);
		{?NEW_AI_TYPE_CAST_SKILL_BY_HP, _} ->
			cast_skill(Obj,TargetID,TargetPos,{Skill,SkillLev},Seq);
		_ ->
			cast_skill(Obj,TargetID,TargetPos,{Skill,SkillLev},Seq)
	end.

ai_skill_call_monster(_Pos, _Dir, []) -> ok;
ai_skill_call_monster(Pos, Dir, [MonsterType | Rest]) ->
	RandPos = fun_ai:find_rand_point(Pos,3,3),
	fun_interface:s_add_monster(no,MonsterType,RandPos,4,Dir,0),
	ai_skill_call_monster(Pos, Dir, Rest).

cast_skill(Obj,TargetID,TargetPos = {TX,TY,TZ},{Skill,Lev},Seq) ->
	#st_skillperformance_config{aleretTimes= AleretTimes} = data_skillperformance:get_skillperformance(Skill),
	if
		AleretTimes > 0 -> 
			case get_aleret_pos(Obj#scene_spirit_ex.pos,Obj#scene_spirit_ex.dir,TargetPos,Skill) of
				no -> 
					?log_warning("cast_skill,get aleret pos error,data = ~p",[{Obj#scene_spirit_ex.pos,Obj#scene_spirit_ex.dir,TargetPos}]);
				AleretPos ->
					ObjSort = util_scene:server_obj_type_2_client_type(Obj#scene_spirit_ex.sort),
					
					case Obj#scene_spirit_ex.skill_aleret_data of
						#skill_aleret_data{skill_data = {_,_,{OldSkill,OldLev}}} ->
							Ptc = #pt_scene_skill_aleret_cancel{
								skill 	   = OldSkill,
								lev 	   = OldLev,
								oid 	   = Obj#scene_spirit_ex.id,
								obj_sort   = ObjSort
							},
							fun_scene_obj:send_cell_all_usr(Obj,proto:pack(Ptc, Seq));
						_ -> skip
					end,
					{X,Y,Z} = Obj#scene_spirit_ex.pos,
					{AX,AY,AZ} = AleretPos,
					Pt = #pt_scene_skill_aleret{
						skill = Skill,
						lev = Lev,
						oid = Obj#scene_spirit_ex.id,
						obj_sort = ObjSort,
						x = X,
						y = Y,
						z = Z,
						dir = Obj#scene_spirit_ex.dir,
						target_id = TargetID,
						target_x = TX,
						target_y = TY,
						target_z = TZ,
						aleret_x = AX,
						aleret_y = AY,
						aleret_z = AZ,
						aleret_dir = Obj#scene_spirit_ex.dir
					},
					fun_scene_obj:send_cell_all_usr(Obj,proto:pack(Pt, Seq)),							
					AleretData = make_skill_aleret_data(AleretTimes,AleretPos,{TargetID,TargetPos,{Skill,Lev}}),
					% ?debug("id:~p, AleretData:~p", [AleretData, Obj#scene_spirit_ex.id]),
					fun_scene_obj:update(Obj#scene_spirit_ex{skill_aleret_data = AleretData,move_data=0,demage_data=0,skill_data=0})
			end;
		true ->
			skill_by_normal(Obj,TargetID,TargetPos = {TX,TY,TZ},{Skill,Lev},Seq)
	end.

skill_by_aleret(Obj,TargetID,TargetPos,{Skill,Lev},AleretPos) ->
	Targets = collect_skill_targets(Obj#scene_spirit_ex.id,Obj#scene_spirit_ex.pos,Obj#scene_spirit_ex.dir,TargetID,TargetPos,Skill,AleretPos),
	skill(Obj,TargetID,TargetPos,{Skill,Lev},0,Targets).

skill_by_normal(Obj=#scene_spirit_ex{},TargetID,TargetPos,{Skill,Lev},Seq) ->
	Targets = collect_skill_targets(Obj#scene_spirit_ex.id,Obj#scene_spirit_ex.pos,Obj#scene_spirit_ex.dir,TargetID,TargetPos,Skill),
	skill(Obj,TargetID,TargetPos,{Skill,Lev},Seq,Targets);

skill_by_normal(_,_TargetID,_TargetPos,_,_Seq) ->
	% ?debug("error obj---------------"),
	skip.
																				   
skill(Obj,TargetID,TargetPos,{Skill,SkillLev},Seq,Targets) ->
	% ?debug("skill data = ~p,Seq = ~p",[{Skill,SkillLev,SkillRune},Seq]),
%% 	Targets = collect_skill_targets(Obj#scene_spirit_ex.id,Obj#scene_spirit_ex.pos,Obj#scene_spirit_ex.dir,TargetID,TargetPos,SkillRune),
	Obj2 = fun_scene_buff:add_skill_self_buff(Obj,{Skill,SkillLev},data_skillleveldata:get_skillleveldata(Skill)),

	FunEffect = fun(Target, {GetObj,GetEffcts}) ->
		case count_skill_effects(GetObj,Target,Skill,SkillLev,?ITSELF_SKILL) of
			{NewGetObj,NewEffects} -> {NewGetObj, GetEffcts ++ NewEffects};
			_ -> {GetObj, GetEffcts}
		end
	end,
	{NewObj,Effects} = lists:foldr(FunEffect, {Obj2,[]}, Targets),
	% ?debug("Targets=~p",[Targets]),
	% ?debug("Effects=~p",[Effects]),
	SkillPerformance = data_skillperformance:get_skillperformance(Skill),
	CheckTarget = if
		TargetID == 0 -> true;
		SkillPerformance#st_skillperformance_config.castType == "NOTARGET" -> true;
		true ->
			case lists:keyfind(TargetID, #scene_spirit_ex.id, Targets) of
				false -> false;
				_ -> true
			end
	end,
	case SkillPerformance of
		#st_skillperformance_config{skillType= "FOLLOWARROW"} -> skip;
		#st_skillperformance_config{arrowEffect= Arrow} ->
			if
				Arrow =/= 0 -> 
					fun_scene_arrow:delay_add_arrow(Skill, SkillLev, SkillPerformance, NewObj, Arrow, NewObj#scene_spirit_ex.pos, NewObj#scene_spirit_ex.dir,  util:longunixtime());
				true -> skip
			end;
		_ -> skip
	end,
	SkillData = case CheckTarget of
		true ->
			case SkillPerformance of
				#st_skillperformance_config{aoeEffect= Trap,castPoint=Skill_Cast_Point} ->
					if
						Trap =/= 0 -> 
							Point = case Skill_Cast_Point of
								?SKILL_CAST_SELF -> Obj#scene_spirit_ex.pos;
								?SKILL_CAST_TARGET ->
									case fun_scene_obj:get_obj(TargetID) of
										#scene_spirit_ex{pos = ThisPos} ->ThisPos;
										_ -> TargetPos
									end;
								?SKILL_CAST_SELF_AREA -> Obj#scene_spirit_ex.pos;
								?SKILL_CAST_TARGET_AREA ->
									case fun_scene_obj:get_obj(TargetID) of
										#scene_spirit_ex{pos = ThisPos} ->ThisPos;
										_ -> TargetPos
									end;
								_ -> Obj#scene_spirit_ex.pos
							end,
							fun_scene_arrow:delay_add_trap(Skill, SkillLev, SkillPerformance, NewObj, Trap, Point, NewObj#scene_spirit_ex.dir, util:longunixtime()); 
						true -> skip
					end;
				_ -> skip
			end,
			%% 	技能位移在这里做处�
			make_skill_data(NewObj,TargetID,Skill);
		_ -> 0
	end,
	do_skill_help(Obj, NewObj, Skill, SkillLev, TargetID, TargetPos, Effects, SkillData, Seq, false).


do_skill_help(OldCasterObj, CasterObj, Skill, SkillLev, TargetID, TargetPos, Effects, SkillData, Seq, IsShenqiSkill) ->
	NewCasterObj = case do_effects(Effects,CasterObj) of
		GetObj = #scene_spirit_ex{} -> fun_scene_obj:update(GetObj#scene_spirit_ex{move_data = 0,demage_data = 0,skill_data = SkillData});
		_ -> no
	end,

	Fun = fun({_AtkOid,DefOid,AtkSort,DefSort,Demage,DemageData}) ->
		{EffectX,EffectY,EffectZ}=case DemageData of
			#demage_data{move_data = #move_data{to_pos = {X1,Y1,Z1}}}  ->
				{X1,Y1,Z1};							
				_ -> {0,0,0}						  
			end,
		Curr_Hp=fun_scene_obj:get_spirit_hp(DefOid),
		Curr_Mp=fun_scene_obj:get_spirit_mp(DefOid),
		TargetSort = fun_scene_obj:get_spirit_client_type(DefOid),
		#pt_public_skill_effect{
			target_id = DefOid,
			target_sort = TargetSort,
			atk_sort = fun_scene_skill:get_atk_sort_num(AtkSort),
			def_sort = fun_scene_skill:get_def_sort_num(DefSort),
			demage = util:abs(Demage),
			cur_hp = Curr_Hp,
			cur_mp = Curr_Mp,
			effect_x = EffectX,
			effect_y = EffectY,
			effect_z = EffectZ
		}
	end,
	Effects1 = lists:map(Fun, Effects),
	Effects2 = [E || E <- Effects1, E /= skip],
	PtBin = case IsShenqiSkill of
		false ->
			do_normal_skill_help(OldCasterObj, CasterObj, Skill, SkillLev, SkillData, TargetID, TargetPos, Effects2, Seq);
		true -> 
			do_shenqi_skill_help(CasterObj, Skill, SkillLev, TargetID, TargetPos, Effects2, Seq)
	end,
	fun_scene_obj:send_cell_all_usr(OldCasterObj,PtBin),
	[fun_new_scene_skill:check_and_interrupt_continuity_buff_skill(E) || E <- Effects],
	NewCasterObj.

do_normal_skill_help(OldCasterObj, CasterObj, Skill, SkillLev, SkillData, TargetID, TargetPos, Effects, Seq) ->
	{TX,TY,TZ} = TargetPos,
	ObjSort = util_scene:server_obj_type_2_client_type(CasterObj#scene_spirit_ex.sort),
	Curr_Mp = fun_scene_obj:get_spirit_mp(CasterObj#scene_spirit_ex.id),
	{X,Y,Z} = OldCasterObj#scene_spirit_ex.pos,
	{ToX,ToY,ToZ} = case SkillData of
		#skill_data{move_data = #move_data{to_pos = {ToX1,ToY1,ToZ1}}} -> {ToX1,ToY1,ToZ1};
		_ -> {0,0,0}
	end,
	Pt = #pt_scene_skill_effect{
		oid = CasterObj#scene_spirit_ex.id,
		obj_sort = ObjSort,
		cur_mp = Curr_Mp,
		skill = Skill,
		lev = SkillLev,
		x = X,
		y = Y,
		z = Z,
		dir = CasterObj#scene_spirit_ex.dir,
		target_id = TargetID,
		target_x = TX,
		target_y = TY,
		target_z = TZ,
		shift_x = ToX,
		shift_y = ToY,
		shift_z = ToZ,
		effect_list = Effects
	},
	% case OldCasterObj#scene_spirit_ex.sort of
	% 	?SPIRIT_SORT_MONSTER -> ?DBG(Pt);
	% 	_ -> skip
	% end,
	proto:pack(Pt, Seq).

do_shenqi_skill_help(CasterObj, Skill, _SkillLev, TargetID, TargetPos, Effects, Seq) -> 
	{TX,TY,TZ} = TargetPos,
	% {AreaType, _} = data_shenqi:get_area_range(Skill, SkillLev),
	Pt = #pt_shenqi_skill_effect{
		src_id      = CasterObj#scene_spirit_ex.id,
		src_sort    = util_scene:server_obj_type_2_client_type(CasterObj#scene_spirit_ex.sort),
		skill       = Skill,
		target_id   = TargetID,
		target_x    = TX,
		target_y    = TY,
		target_z    = TZ,
		effect_list = Effects
	},
	proto:pack(Pt, Seq).

do_effects(Effects,SkillUsr) -> 
	% ?debug("Effects:~p", [Effects]),
	lists:foldr(fun(Effect = {_,DefOid,_,_,_,_},GetSkillUsr) -> 
		case GetSkillUsr of
			#scene_spirit_ex{id=_Id} ->
				if
					DefOid == GetSkillUsr#scene_spirit_ex.id ->
						do_effect(GetSkillUsr,Effect);
					true -> 
						do_effect(fun_scene_obj:get_obj(DefOid),Effect),
						GetSkillUsr
				end;
			_ ->
				do_effect(fun_scene_obj:get_obj(DefOid),Effect),
				GetSkillUsr
		end
	end, SkillUsr, Effects).
			
do_effect(BeAtkedObj=#scene_spirit_ex{id = ID,sort=?SPIRIT_SORT_MONSTER,data=MonData,pos = Pos},{AtkOid,DefOid,die}) ->
	Type=MonData#scene_monster_ex.type,
	try
		ConItemID=MonData#scene_monster_ex.con_scene_item,
		if  
			ConItemID == 0 -> skip;
			true ->
				fun_scene_item_event:action_scene_item_del(ConItemID)	
		end,	
		if
			MonData#scene_monster_ex.ontime_off > 0 ->
				DieMoudle = MonData#scene_monster_ex.script,
				try
					DieMoudle:die(get(scene),Type,ID - ?OBJ_OFF,Pos)
				catch
					E1:R1 -> ?log_error("monster script error,type=~p,E=~p,R=~p,stack=~p",[Type,E1,R1,erlang:get_stacktrace()])
				end;
			true -> skip
		end
	catch E:R -> ?log_error("monster die error,E = ~p,R = ~p,stack=~w",[E,R,erlang:get_stacktrace()])
	end,
	BeAtkedObj1 = fun_scene_buff:del_buff_by_die(BeAtkedObj), 
	NewBeAtkedObj = fun_scene_obj:update(BeAtkedObj1#scene_spirit_ex{die = true,hp = 0}),
	%%添加场景触发脚本 satan 2016.1.30
	fun_scene:run_scene_script(onMontserDie,[AtkOid,NewBeAtkedObj#scene_spirit_ex.id,fun_scene_obj:get_monster_spc_data(BeAtkedObj, type),BeAtkedObj#scene_spirit_ex.pos]),
	
	#st_monster_config{corpse_remain_time=RT} = data_monster:get_monster(Type),
	if
		RT > 0 ->
			scene_big_loop:add_callback(RT, fun_scene_obj, remove_obj, DefOid),
			NewBeAtkedObj;
		true -> %% 至少给1秒的延后删除，这样让对象在删除之前可以正常操作
			scene_big_loop:add_callback(1, fun_scene_obj, remove_obj, DefOid),
			NewBeAtkedObj
	end;
do_effect(BeAtkedObj = #scene_spirit_ex{sort=?SPIRIT_SORT_USR,name=DefName,buffs=Buffs,data=#scene_usr_ex{demage_list=_DemageList,hid=AgentHid}},{AtkOid,DefOid,die}) ->
	BeAtkedObj1 = fun_scene_buff:del_buff_by_die(BeAtkedObj), 
	NBeAtkedObj = fun_scene_obj:update(BeAtkedObj1#scene_spirit_ex{die = true,hp = 0}),
	add_enemy(AtkOid,DefOid,get(scene)),
	BuffIds=lists:map(fun(#scene_buff{type=Type})-> Type end, Buffs),
	fun_scene:run_scene_script(onUsrDie,[AtkOid,DefOid,BuffIds]),
	NewBeAtkedObj1=fun_scene_obj:put_usr_spc_data(NBeAtkedObj,penta_kill,0),
	NewBeAtkedObj=fun_scene_obj:put_usr_spc_data(NewBeAtkedObj1,penta_kill_time,util:longunixtime()),
	fun_scene_obj:update(fun_scene_obj:put_usr_spc_data(NewBeAtkedObj,demage_list,[])),
	case fun_scene_obj:get_obj(AtkOid)   of  
		#scene_spirit_ex{sort=?SPIRIT_SORT_USR,name=AtkName}->
			fun_scene_obj:agent_msg(AgentHid, {camp_kill,AtkOid,AtkName, DefOid,DefName});
		_->skip
	end,
	?debug("usr_die:~p", [BeAtkedObj#scene_spirit_ex.id]),
	fun_scene_event:handle_scene_event(usr_die, BeAtkedObj#scene_spirit_ex.id),
	NBeAtkedObj;

do_effect(BeAtkedObj = #scene_spirit_ex{id=Eid,sort=?SPIRIT_SORT_ENTOURAGE,data = #scene_entourage_ex{}},{_AtkOid,DefOid,die}) ->
	NBeAtkedObj = fun_scene_obj:update(BeAtkedObj#scene_spirit_ex{die = true,hp = 0}),
%%  英雄挑战佣兵死亡标记
	case get(scene) of  
		?HERO_CHALLEGE_SCENE->put(hc_ed,{Eid-?ETRG_OFF,0});
		_->skip
	end,
	entourage_die(DefOid),
	NBeAtkedObj;

do_effect(BeAtkedObj = #scene_spirit_ex{sort=?SPIRIT_SORT_ROBOT},{AtkOid,DefOid,die}) ->
	fun_interface:s_game_robot_die(AtkOid, DefOid),
	kill_entourage_when_robot_die(BeAtkedObj),
	fun_scene_obj:update(BeAtkedObj#scene_spirit_ex{die = true,hp = 0});

do_effect(BeAtkedObj = #scene_spirit_ex{sort=?SPIRIT_SORT_ITEM,data=#scene_item_ex{type =Type}},{_AtkOid,_DefOid,die}) -> 
	case data_scene_item:get_data(Type) of
		#st_scene_item_config{deadTimes=DeadDelayDel} ->			
			if
				DeadDelayDel > 0 ->
					erlang:start_timer(DeadDelayDel, self(), {fun_interface, s_del_item, BeAtkedObj#scene_spirit_ex.id-?OBJ_OFF});				
				true -> skip
			end;				
		_ ->skip
	end,	
	fun_scene_obj:update(BeAtkedObj#scene_spirit_ex{die = true,hp = 0});		

do_effect(BeAtkedObj = #scene_spirit_ex{},{_AtkOid,_DefOid,die}) ->
	fun_scene_obj:update(BeAtkedObj#scene_spirit_ex{die = true,hp = 0});

do_effect(BeAtkedObj = #scene_spirit_ex{final_property = BeAtkedBattle},{_AtkOid,_DefOid,_AtkSort,treat_mp,Demage,_DemageData}) ->
	CurrMp = BeAtkedObj#scene_spirit_ex.mp,
	MaxMp = BeAtkedBattle#battle_property.mpLimit,
	CurrMp1 = CurrMp - Demage,
	NewMp = if
		CurrMp1 >= MaxMp -> MaxMp;
		CurrMp1 < 0 -> 0;
		true -> CurrMp1
	end,
	fun_scene_obj:update(BeAtkedObj#scene_spirit_ex{mp = NewMp});

do_effect(BeAtkedObj = #scene_spirit_ex{sort=?SPIRIT_SORT_MONSTER,camp=_BeAtkCamp,data=MonData},{AtkOid,DefOid,AtkSort,_,Demage,DemageData}) ->
	AI_Data=MonData#scene_monster_ex.ai_data,
	NData=AI_Data,
	NewKiller = entourage_owner(AtkOid), 
	NewOwner = case MonData#scene_monster_ex.owner of
				   0 -> entourage_owner(NewKiller);
				   _ -> entourage_owner(MonData#scene_monster_ex.owner)
			   end,
	
	NewFirstkiller = 
		case MonData#scene_monster_ex.first_killer of
			0 -> entourage_owner(NewKiller);
			_ ->  entourage_owner(MonData#scene_monster_ex.first_killer)
		end,
	BeAtkedHp = BeAtkedObj#scene_spirit_ex.hp,
	NewBeAtkedHp = if
		BeAtkedHp =< Demage -> 0;
		true -> BeAtkedHp - Demage
	end,

	NBeAtkedObj = case DemageData of
		0 -> fun_scene_obj:update(BeAtkedObj#scene_spirit_ex{hp=NewBeAtkedHp, data=MonData#scene_monster_ex{ai_data=NData,last_killer = NewKiller,owner = NewOwner,first_killer=NewFirstkiller}});
		_ ->
			%%取消预警
			case BeAtkedObj#scene_spirit_ex.skill_aleret_data of
				#skill_aleret_data{skill_data = {_,_,{OldSkill,OldLev}}} ->
					ObjSort = util_scene:server_obj_type_2_client_type(BeAtkedObj#scene_spirit_ex.sort),
					Ptc = #pt_scene_skill_aleret_cancel{
						skill = OldSkill,
						lev = OldLev,
						oid = BeAtkedObj#scene_spirit_ex.id,
						obj_sort = ObjSort
					},
					fun_scene_obj:send_cell_all_usr(BeAtkedObj,proto:pack(Ptc)),
					?debug("cancel alert"),
					AleretData = 0;
				_ -> AleretData = 0
			end,
			fun_scene_obj:update(BeAtkedObj#scene_spirit_ex{skill_aleret_data = AleretData,demage_data=DemageData,skill_data=0,hp=NewBeAtkedHp, data=MonData#scene_monster_ex{ai_data=NData,last_killer = NewKiller,owner = NewOwner,first_killer=NewFirstkiller}})
	end,	
	MaxHp=BeAtkedObj#scene_spirit_ex.data#scene_monster_ex.max_hp,
	
	%%添加场景触发脚本 satan 2016.1.30
	fun_scene:run_scene_script(onMonsterInjured,[BeAtkedObj#scene_spirit_ex.id - ?OBJ_OFF,fun_scene_obj:get_monster_spc_data(BeAtkedObj, type),BeAtkedObj#scene_spirit_ex.pos
												,Demage,NewBeAtkedHp,MaxHp,AtkOid]),
	if
		NewBeAtkedHp == 0 -> 
			add_kill_num(AtkOid, AtkSort),
			do_effect(fun_scene_obj:get_obj(DefOid),{AtkOid,DefOid,die});  
		true -> NBeAtkedObj
	end;
do_effect(BeAtkedObj = #scene_spirit_ex{id=_BeAtkedObj_id,sort=Sort},{AtkOid,DefOid,AtkSort,_,Demage,DemageData}) ->
	if
		Demage > 0 andalso Sort == ?SPIRIT_SORT_USR ->
			% ?debug("Hp = ~p",[BeAtkedObj#scene_spirit_ex.hp]),
			AgentHid = BeAtkedObj#scene_spirit_ex.data#scene_usr_ex.hid,
			fun_scene_obj:agent_msg(AgentHid, {in_fight});
%% 			gen_server:cast(AgentHid, {in_fight});
		true -> skip
	end,
	BeAtkedHp = BeAtkedObj#scene_spirit_ex.hp,
	NewBeAtkedHp = if
		BeAtkedHp =< Demage -> 0;
		true -> BeAtkedHp - Demage
	end,
	NBeAtkedObj = case DemageData of
		0 ->
			fun_scene_obj:update(BeAtkedObj#scene_spirit_ex{hp=NewBeAtkedHp});
		_ ->
			%%取消预警
			case BeAtkedObj#scene_spirit_ex.skill_aleret_data of
				#skill_aleret_data{skill_data = {_,_,{OldSkill,OldLev}}} ->
					ObjSort = util_scene:server_obj_type_2_client_type(BeAtkedObj#scene_spirit_ex.sort),
					Ptc = #pt_scene_skill_aleret_cancel{
						skill = OldSkill,
						lev = OldLev,
						oid = BeAtkedObj#scene_spirit_ex.id,
						obj_sort = ObjSort
					},
					fun_scene_obj:send_cell_all_usr(BeAtkedObj,proto:pack(Ptc));
				_ -> skip
			end,
			fun_scene_obj:update(BeAtkedObj#scene_spirit_ex{demage_data=DemageData,skill_data=0,hp=NewBeAtkedHp,skill_aleret_data = 0})
	end,
	if
		NewBeAtkedHp == 0 -> 
			add_kill_num(AtkOid, AtkSort),
			do_effect(fun_scene_obj:get_obj(DefOid),{AtkOid,DefOid,die});
		true -> NBeAtkedObj
	end;
do_effect(BeAtkedObj,_E) ->?log_warning("do_effect,_E = ~p",[_E]), BeAtkedObj.

entourage_owner(ID)->
	case fun_scene_obj:get_obj(ID, ?SPIRIT_SORT_USR) of
		 #scene_spirit_ex{} -> ID;
		_->
			case fun_scene_obj:get_obj(ID, ?SPIRIT_SORT_ENTOURAGE) of
				 #scene_spirit_ex{data = #scene_entourage_ex{owner_id = Owner_id}} -> Owner_id;
				_->0
			end
	end.

entourage_die(Oid)->
	case fun_scene_obj:get_obj(Oid, ?SPIRIT_SORT_ENTOURAGE) of
		BeAtkedObj = #scene_spirit_ex{id = Eid, data = #scene_entourage_ex{type = Etype, owner_id=OwnerId}} ->
			Now = scene:get_scene_now(),
			case fun_scene_obj:get_obj(OwnerId) of
				#scene_spirit_ex{data = #scene_usr_ex{}} -> 
					fun_entourage:entourage_die(OwnerId,Eid,Now),
					entourage_die_time(BeAtkedObj, Etype, Oid);
				#scene_spirit_ex{data = #scene_robot_ex{}} ->
					fun_entourage:entourage_die(OwnerId,Eid,Now),
					entourage_die_time(BeAtkedObj, Etype, Oid);
				_ -> skip
			end;
		_ -> skip
	end.

entourage_die_time(BeAtkedObj,Type,DefOid)->
	case data_entourage:get_data(Type) of
		#st_entourage_config{deatlagtime=RT} ->			
			if
				RT > 0 -> 
					erlang:start_timer(RT*1000, self(), {fun_scene_obj, remove_obj, DefOid}),
					fun_scene_obj:update(BeAtkedObj#scene_spirit_ex{die = true,hp = 0});
				RT == 0 -> 
					fun_scene_obj:remove_obj(DefOid),
					no;
				true -> 
					BeAtkedObj
			end;				
		_ -> BeAtkedObj	
	end.

add_enemy(AtkOid,DefOid,Scene)->
	case check_revenge_scene(Scene) of
		true->
			case fun_scene_obj:get_obj(AtkOid, ?SPIRIT_SORT_USR) of
				#scene_spirit_ex{data=#scene_usr_ex{hid=AgentHid}} -> 
					fun_scene:send_count_event(DefOid, be_kill, 0, 0, 1),
					fun_scene_obj:agentmng_msg(AgentHid,{add_enemy,DefOid,AtkOid});
				%% 					gen_server:cast({global, agent_mng},{add_enemy,DefOid,AtkOid});
				_->
					case fun_scene_obj:get_obj(AtkOid, ?SPIRIT_SORT_ENTOURAGE) of
						#scene_spirit_ex{data = #scene_entourage_ex{owner_id=OwnerId}} ->
							case fun_scene_obj:get_obj(OwnerId, ?SPIRIT_SORT_USR) of
								#scene_spirit_ex{data=#scene_usr_ex{hid=AgentHid}} ->
									fun_scene_obj:agentmng_msg(AgentHid,{add_enemy,DefOid,OwnerId});
%% 							gen_server:cast({global, agent_mng},{add_enemy,DefOid,OwnerId});
								_->skip
							end;
						_->skip
					end
			end;
		_->skip
	end.
%%检查仇人所在地图是否可飞
check_revenge_scene(SceneType)->
	case data_scene_config:get_scene(SceneType) of
		#st_scene_config{sort=Sort}->
			case Sort of
				?SCENE_SORT_CAMP->true;
				?SCENE_SORT_SCUFFLE ->true;
				_->false
			end;
		_->false
	end.	

%% 计算场景对象伤害
count_scene_damage(Id, ObjType, Damage) ->
	if 
		Damage == 0 -> skip;
		Damage < 0 ->
			add_scene_treat(Id, ObjType, -Damage);
		true ->
			add_scene_damage(Id, ObjType, Damage)
	end.

add_scene_damage(Id, ObjType, Damage) ->
	Maps = util_misc:get_process_dict(scene_damage, #{}),
	ObjMaps = maps:get(Id, Maps, #{obj_type => ObjType}),
	ObjMaps2 = ObjMaps#{damage => Damage + maps:get(damage, ObjMaps, 0)},
	erlang:put(scene_damage, Maps#{Id => ObjMaps2}).


add_scene_treat(Id, ObjType, Treat) ->
	Maps = util_misc:get_process_dict(scene_treat, #{}),
	ObjMaps = maps:get(Id, Maps, #{obj_type => ObjType}),
	ObjMaps2 = ObjMaps#{damage => Treat + maps:get(damage, ObjMaps, 0)},
	erlang:put(scene_treat, Maps#{Id => ObjMaps2}).


%% 增加击杀数量
add_kill_num(Id, ObjType) ->
	Maps = util_misc:get_process_dict(scene_damage, #{}),
	ObjMaps = maps:get(Id, Maps, #{obj_type => ObjType}),
	ObjMaps2 = ObjMaps#{kill_num => 1 + maps:get(kill_num, ObjMaps, 0)},
	erlang:put(scene_damage, Maps#{Id => ObjMaps2}).


count_usr_demage_help(Uid,SceneType,Demage) ->
	case get(count_usr_demage) of
		?UNDEFINED -> put(count_usr_demage,[{Uid,SceneType,Demage}]);
		UsrList->
			case lists:keyfind(Uid, 1, UsrList) of
				{_,_,UsrDemage}->
					%% ?debug("UsrList = ~p,{Uid,SceneType,UsrDemage+Demage} = ~p",[UsrList,{Uid,SceneType,UsrDemage+Demage}]),
					Lists = lists:keyreplace(Uid, 1, UsrList, {Uid,SceneType,UsrDemage+Demage}),
					put(count_usr_demage,Lists);
				_->
					Lists = lists:append(UsrList, [{Uid,SceneType,Demage}]),
					put(count_usr_demage,Lists)
			end
	end.

%%计算玩家伤害
count_usr_demage(Id,Obj,Demage)->
	% ?debug("Id:~p, Demage:~p", [Id, Demage]),
	if 
		Demage < 0 -> skip;
		true ->
			case fun_scene_obj:get_obj(Id) of
				#scene_spirit_ex{sort = ?SPIRIT_SORT_USR} -> 
					count_usr_demage2(Id,Obj,Demage);
				#scene_spirit_ex{sort = ?SPIRIT_SORT_ENTOURAGE, data = #scene_entourage_ex{owner_id = Owner_id}} -> 
					count_usr_demage2(Owner_id,Obj,Demage);
				#scene_spirit_ex{sort = ?SPIRIT_SORT_ROBOT, id = RobotId} -> 
					% ?debug("count_robot_demage"),
					SceneType = get(scene),
					case data_scene_config:get_scene(SceneType) of
						#st_scene_config{sort = Sort} ->
							if 
								Sort == ?SCENE_SORT_WORLDBOSS ->
									count_usr_demage_help(RobotId,SceneType,Demage);
								true -> skip
							end;
						_ -> skip
					end;
				_ ->
					0
			end
	end.

count_usr_demage2(Uid,_Obj,Demage) ->
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		#scene_spirit_ex{} ->
			SceneType = get(scene), 
			case data_scene_config:get_scene(SceneType) of
				#st_scene_config{sort=  Sort} ->
					if
						Sort == ?SCENE_SORT_COPY orelse Sort == ?SCENE_SORT_WORLDBOSS orelse Sort == ?SCENE_SORT_LIMITBOSS orelse Sort == ?SCENE_SORT_MELLEBOSS ->
							count_usr_demage_help(Uid,SceneType,Demage);
						true -> skip
					end;
				_ -> skip
			end;
		_ -> skip
	end.

init_coin() -> put(count_usr_coin,0).

get_coin() ->
	case get(count_usr_coin) of
		undefined -> 0;
		Coin -> Coin
	end.

get_demage(Uid) ->
	case get(count_usr_demage) of
		undefined -> 0;
		List when is_list(List) ->
			case lists:keyfind(Uid, 1, List) of
				{_,_,Demage} -> Demage;
				_ -> 0
			end
	end.

get_damage_list() ->
	case get(count_usr_demage) of
		undefined -> [];
		List -> List
	end.

get_scene_damage_list() ->
	util_misc:get_process_dict(scene_damage, #{}).

get_scene_treat_list() ->
	util_misc:get_process_dict(scene_treat, #{}).

reset_damage_list() ->
	put(scene_damage, #{}),
	put(scene_treat, #{}).

kill_entourage_when_robot_die(#scene_spirit_ex{data = #scene_robot_ex{battle_entourage = List}}) ->
	[fun_scene_obj:remove_obj(Eid) || Eid <- List],
	ok.