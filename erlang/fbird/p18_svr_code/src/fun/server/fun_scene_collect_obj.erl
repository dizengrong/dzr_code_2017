%% 场景收集
-module(fun_scene_collect_obj).
-include("common.hrl").
-export([collect_obj/5,collect_obj/6,is_hate_relation/4,get_relation_config/3,collect_obj_help/3]).
-export([match_collect_obj_relation/2]).

get_scene_sort(?SCENE_SORT_MAIN) -> 1; %% 主关卡
get_scene_sort(?SCENE_SORT_ARENA) -> 2; %% 竞技场
get_scene_sort(?SCENE_SORT_ACTIVITY_COPY) -> 3; %% 活动副本
get_scene_sort(?SCENE_SORT_HERO_EXPEDITION) -> 4; %% 英雄远征
get_scene_sort(_) -> 10.

get_relation_config(Camp,MCamp,Scene) ->
	case data_scene_config:get_scene(Scene) of
		#st_scene_config{sort=SceneSort} ->
			Sort=get_scene_sort(SceneSort),
			case data_relation:get_relation(Camp,MCamp,Sort) of
				#st_relation_config{relation=Relation_C} -> Relation_C;
				_ -> ?RELATION_NEUTRAL
			end;
		_ -> ?log_error("get_relation_config not find scene Scene=~p",[Scene]),2
	end.

is_hate_relation(AtkOid,DefOid,AtkCamp,DefCamp) ->
	match_collect_obj_relation(?RELATION_FRIEND,{AtkOid,DefOid,AtkCamp,DefCamp,get(scene)}).	

is_same_team(#scene_spirit_ex{id=AtkOid,sort=?SPIRIT_SORT_USR},#scene_spirit_ex{sort=?SPIRIT_SORT_ENTOURAGE,data=#scene_entourage_ex{owner_id=OwnerID}}) ->
	if
		AtkOid == OwnerID -> true;
		true -> false
	end;
is_same_team(#scene_spirit_ex{sort=?SPIRIT_SORT_ENTOURAGE,data=#scene_entourage_ex{owner_id=OwnerID}},#scene_spirit_ex{id=DefOid,sort=?SPIRIT_SORT_USR}) ->
	if
		OwnerID == DefOid -> true;
		true -> false
	end;
is_same_team(#scene_spirit_ex{id=AtkOid,sort=?SPIRIT_SORT_ROBOT},#scene_spirit_ex{sort=?SPIRIT_SORT_ENTOURAGE,data=#scene_entourage_ex{owner_id=OwnerID}}) ->
	if
		AtkOid == OwnerID -> true;
		true -> false
	end;
is_same_team(#scene_spirit_ex{sort=?SPIRIT_SORT_ENTOURAGE,data=#scene_entourage_ex{owner_id=OwnerID}},#scene_spirit_ex{id=DefOid,sort=?SPIRIT_SORT_ROBOT}) ->
	if
		OwnerID == DefOid -> true;
		true -> false
	end;
is_same_team(#scene_spirit_ex{sort=?SPIRIT_SORT_ENTOURAGE,data=#scene_entourage_ex{owner_id=OwnerID}},#scene_spirit_ex{sort=?SPIRIT_SORT_ENTOURAGE,data=#scene_entourage_ex{owner_id=OwnerID}}) -> true;
is_same_team(_,_) -> false.

match_collect_obj_relation(?RELATION_TEAM,{AtkOid,DefOid,_Camp,_MCamp,_Scene}) when AtkOid==DefOid -> true;
match_collect_obj_relation(?RELATION_TEAM,{AtkOid,DefOid,_Camp,_MCamp,_Scene}) ->
	case fun_scene_obj:get_obj(AtkOid) of
		AtkUsr = #scene_spirit_ex{} ->
			case fun_scene_obj:get_obj(DefOid) of
				DefUsr = #scene_spirit_ex{} ->
					is_same_team(AtkUsr,DefUsr);
				_ -> false
			end;
		_ -> false
	end;
match_collect_obj_relation(?RELATION_FRIEND,{AtkOid,DefOid,_Camp,_MCamp,_Scene}) when AtkOid==DefOid -> true;
match_collect_obj_relation(?RELATION_FRIEND,{_AtkOid,_DefOid,Camp,MCamp,Scene}) ->
	Relation=get_relation_config(Camp,MCamp,Scene),
	?RELATION_FRIEND==Relation;
match_collect_obj_relation(?RELATION_ENEMY,{AtkOid,DefOid,_Camp,_MCamp,_Scene}) when AtkOid==DefOid -> false;
match_collect_obj_relation(?RELATION_ENEMY,{_AtkOid,_DefOid,Camp,MCamp,Scene}) ->	
	Relation=get_relation_config(Camp,MCamp,Scene),
	?RELATION_ENEMY==Relation;
match_collect_obj_relation(CollRelation,{_AtkOid,_DefOid,Camp,MCamp,Scene}) ->
	Relation=get_relation_config(Camp,MCamp,Scene),
	CollRelation==Relation.

collect_obj(CollArgs,Camp,Scene,CollNum,SkillAi) ->
	collect_obj(CollArgs,Camp,Scene,CollNum,SkillAi,?RELATION_ENEMY).
collect_obj({rect,AtkOid,Pos,Dir,ParList},Camp,Scene,CollNum,SkillAi,CollRelation) ->
	RL=lists:nth(?RECT_L, ParList), 
	RW=lists:nth(?RECT_W, ParList),
	UH=lists:nth(?RECT_UP_H, ParList), 
	DH=lists:nth(?RECT_DOWN_H, ParList),
	NAll = fun_scene_map:get_all_bojs_by_id(AtkOid),
	All=if
		CollRelation == ?RELATION_ENEMY -> lists:keydelete(AtkOid, #scene_spirit_ex.id, NAll);
		true -> NAll
	end,
	Fun=fun(Obj)->
	  case Obj of
			#scene_spirit_ex{id=DefOid,sort=?SPIRIT_SORT_MONSTER,pos=Pos2,die=false,camp=MCamp,data=#scene_monster_ex{type = MT}} ->
				MatchRet=match_collect_obj_relation(CollRelation,{AtkOid,DefOid,Camp,MCamp,Scene}),
				if
					MatchRet == false -> false; 
					true ->
						#st_monster_config{monster_r=R} = data_monster:get_monster(MT),
						lib_c_map_module:calc_in_rect(Pos, Pos2, Dir, R, RL, RW, UH, DH)
				end;
			#scene_spirit_ex{id=DefOid,sort=?SPIRIT_SORT_ENTOURAGE,pos=Pos2,die=false,camp=OCamp} ->
					MatchRet=match_collect_obj_relation(CollRelation,{AtkOid,DefOid,Camp,OCamp,Scene}),
					MatchRet andalso lib_c_map_module:calc_in_rect(Pos, Pos2, Dir, 0, RL, RW, UH, DH);
			_ -> false
		end
	end,
	collect_obj_help(lists:filter(Fun, All), CollNum, SkillAi);
collect_obj({cir,AtkOid,Pos,_Dir,ParList},Camp,Scene,CollNum,SkillAi,CollRelation) ->
	NAll = fun_scene_map:get_all_bojs_by_id(AtkOid),
	All = if
		CollRelation == ?RELATION_ENEMY -> lists:keydelete(AtkOid, #scene_spirit_ex.id, NAll);
		true -> NAll
	end,	
	Radis=lists:nth(?OUT_RAD, ParList),
	UH=lists:nth(?RECT_UP_H, ParList), 
	DH=lists:nth(?RECT_DOWN_H, ParList),
	Fun=fun(Obj)->
		case Obj of
			#scene_spirit_ex{id=DefOid,sort=?SPIRIT_SORT_MONSTER,pos=Pos2,die=false,camp=MCamp,data=#scene_monster_ex{type = MT}} ->
				MatchRet=match_collect_obj_relation(CollRelation,{AtkOid,DefOid,Camp,MCamp,Scene}),
				if
					MatchRet == false -> false;
					true ->
						#st_monster_config{monster_r=R} = data_monster:get_monster(MT),
						lib_c_map_module:calc_in_cir(Pos,Pos2,R,Radis,UH,DH)
				end;
			#scene_spirit_ex{id=DefOid,sort=?SPIRIT_SORT_ENTOURAGE,pos=Pos2,die=false,camp=OCamp} ->
				MatchRet=match_collect_obj_relation(CollRelation,{AtkOid,DefOid,Camp,OCamp,Scene}),
				MatchRet andalso lib_c_map_module:calc_in_cir(Pos,Pos2,0,Radis,UH,DH);
			_ -> false
		end
	end,
	collect_obj_help(lists:filter(Fun, All), CollNum, SkillAi);
collect_obj({sector,AtkOid,Pos,Dir,ParList},Camp,Scene,CollNum,SkillAi,CollRelation) ->
	NAll = fun_scene_map:get_all_bojs_by_id(AtkOid),
	All = if
		CollRelation == ?RELATION_ENEMY ->
			lists:keydelete(AtkOid, #scene_spirit_ex.id, NAll);
		true -> NAll
	end,
	Radis=lists:nth(?OUT_RAD, ParList),
	Seg_Ang=lists:nth(?SEG_ANGLE, ParList),
	UH=lists:nth(?RECT_UP_H, ParList), 
	DH=lists:nth(?RECT_DOWN_H, ParList),
	Fun=fun(Obj)->
		case Obj of
			#scene_spirit_ex{id=DefOid,sort=?SPIRIT_SORT_MONSTER,pos=Pos2,die=false,camp=MCamp,data=#scene_monster_ex{type = MT}} ->
				MatchRet=match_collect_obj_relation(CollRelation,{AtkOid,DefOid,Camp,MCamp,Scene}),
				if
					MatchRet == false -> false;
					true ->
				  		#st_monster_config{monster_r=R} = data_monster:get_monster(MT),
						lib_c_map_module:calc_in_sector(Pos,Pos2,Dir,R,Radis,Seg_Ang,UH,DH)
				end;
			#scene_spirit_ex{id=DefOid,sort=?SPIRIT_SORT_ENTOURAGE,pos=Pos2,die=false,camp=OCamp} ->
				MatchRet=match_collect_obj_relation(CollRelation,{AtkOid,DefOid,Camp,OCamp,Scene}),
				MatchRet andalso lib_c_map_module:calc_in_sector(Pos,Pos2,Dir,0,Radis,Seg_Ang,UH,DH);
			_ -> false
		end
	end,
	% Obj1 = fun_scene_obj:get_obj(AtkOid),
	collect_obj_help(lists:filter(Fun, All), CollNum, SkillAi);
collect_obj({ring,AtkOid,Pos,_Dir,ParList},Camp,Scene,CollNum,SkillAi,CollRelation) ->
	NAll = fun_scene_map:get_all_bojs_by_id(AtkOid),
	All=if
			 CollRelation == ?RELATION_ENEMY ->
				 lists:keydelete(AtkOid, #scene_spirit_ex.id, NAll);
			 true -> NAll
		 end,
	ORadis=lists:nth(?OUT_RAD, ParList), 
	IRadis=lists:nth(?IN_RAD, ParList),
	UH=lists:nth(?RECT_UP_H, ParList), 
	DH=lists:nth(?RECT_DOWN_H, ParList),
	Fun=fun(Obj)->
		case Obj of
			#scene_spirit_ex{id=DefOid,sort=?SPIRIT_SORT_MONSTER,pos=Pos2,die=false,camp=MCamp,data=#scene_monster_ex{type = MT}} ->
				MatchRet=match_collect_obj_relation(CollRelation,{AtkOid,DefOid,Camp,MCamp,Scene}),
				if
					MatchRet == false -> false;
					true ->
				  		#st_monster_config{monster_r=R} = data_monster:get_monster(MT),
				  		lib_c_map_module:calc_in_ring(Pos,Pos2,R,ORadis,IRadis,UH,DH)
				end;
			#scene_spirit_ex{id=DefOid,sort=?SPIRIT_SORT_ENTOURAGE,pos=Pos2,die=false,camp=OCamp} ->
				MatchRet=match_collect_obj_relation(CollRelation,{AtkOid,DefOid,Camp,OCamp,Scene}),
				MatchRet andalso lib_c_map_module:calc_in_ring(Pos,Pos2,0,ORadis,IRadis,UH,DH);
			_ -> false
		end
	end,
	collect_obj_help(lists:filter(Fun, All), CollNum, SkillAi);
collect_obj({target,AtkOid,DefOid},Camp,Scene,_CollNum,_SkillAi,CollRelation) ->
	case fun_scene_obj:get_obj(DefOid) of
		Obj = #scene_spirit_ex{die=false,camp=CollCamp} ->
			MatchRet=match_collect_obj_relation(CollRelation,{AtkOid,DefOid,Camp,CollCamp,Scene}),
			if
				MatchRet == false -> [];
				true -> [Obj]
			end;
		_ -> []
	end;

collect_obj({self, AtkOid},_Camp,_Scene,_CollNum,_SkillAi,_CollRelation) ->
	case fun_scene_obj:get_obj(AtkOid) of
		Obj = #scene_spirit_ex{die=false} -> [Obj];
		_ -> []
	end;

collect_obj(R,_,_,_,_,_) -> 
	?log_error("collect_obj error R=~p",[R]),
	[].

collect_obj_help(CollList, CollNum, SkillAi) ->
	case CollList of
		[] -> [];
		_ ->
			{NeedSort, NeedVal} = SkillAi,
			{FirstList, List} = case NeedSort of
				?ATK_NORMAL -> {CollList, []};
				_ ->
					Fun = fun(Obj = #scene_spirit_ex{data = Data},{Acc1,Acc2}) ->
						case Data of
							#scene_monster_ex{profession = Profession, race = Race, sex = Sex} ->
								case NeedSort of
									?ATK_RACE ->
										if
											Race == NeedVal -> {[Obj | Acc1], Acc2};
											true -> {Acc1, [Obj | Acc2]}
										end;
									?ATK_PROFESSION ->
										if
											Profession == NeedVal -> {[Obj | Acc1], Acc2};
											true -> {Acc1, [Obj | Acc2]}
										end;
									?ATK_SEX ->
										if
											Sex == NeedVal -> {[Obj | Acc1], Acc2};
											true -> {Acc1, [Obj | Acc2]}
										end;
									_ -> {Acc1, [Obj | Acc2]}
								end;
							#scene_entourage_ex{profession = Profession, race = Race, sex = Sex} ->
								case NeedSort of
									?ATK_RACE ->
										if
											Race == NeedVal -> {[Obj | Acc1], Acc2};
											true -> {Acc1, [Obj | Acc2]}
										end;
									?ATK_PROFESSION ->
										if
											Profession == NeedVal -> {[Obj | Acc1], Acc2};
											true -> {Acc1, [Obj | Acc2]}
										end;
									?ATK_SEX ->
										if
											Sex == NeedVal -> {[Obj | Acc1], Acc2};
											true -> {Acc1, [Obj | Acc2]}
										end;
									_ -> {Acc1, [Obj | Acc2]}
								end;
							_ -> {Acc1, [Obj | Acc2]}
						end
					end,
					lists:foldl(Fun, {[],[]}, CollList)
			end,
			Length1 = length(FirstList),
			Length2 = length(List),
			case CollNum of
				all -> CollList;
				no -> [];
				single ->
					if
						Length1 > 0 -> hd(FirstList);
						true -> hd(List)
					end;
				_ -> 
					if
						Length1 > CollNum -> {NColls,_}=lists:split(CollNum, FirstList),NColls;
						Length1 == CollNum -> FirstList;
						Length1 + Length2 > CollNum ->
							{NColls,_}=lists:split(CollNum - Length1, List),
							FirstList ++ NColls;
						true -> CollList
					end
			end
	end.