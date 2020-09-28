%% @doc 与pk相关的一些方法
-module (util_pk).
-include("common.hrl").
-export ([get_target_role/3, get_robot_data/1]).


get_target_role(Uid, EntourageList, ShenqiId) ->
	[Usr|_] = db:dirty_get(usr,Uid),
	Name = Usr#usr.name,
	Camp = Usr#usr.camp,
	Lev = Usr#usr.lev,
	EntourageData = fun_entourage:get_entourage_battle_data(Uid, EntourageList),
	Obj = #scene_spirit_ex{
		name=Name,camp=Camp,dir=180,hp=100,final_property=#battle_property{hpLimit = 100},
		data=#scene_robot_ex{lev = Lev, shenqi_skill = fun_shenqi:get_shenqi_data(Uid, ShenqiId)}
	},
	{{Name, Lev}, {Obj ,EntourageData}}.

get_robot_data(ID) ->
	case data_robot:get_data(ID) of 
		#st_robot{level=Lev,entourageList=EntourageList,artifact=Shenqi} ->
			EntourageData = init_entourage(EntourageList, 1, []),
			Name = util_lang:get_robot_name(ID),
			Obj = #scene_spirit_ex{
				name=Name,camp=4,dir=180,hp=100,final_property=#battle_property{hpLimit = 100}
				,data=#scene_robot_ex{lev=Lev,shenqi_skill=Shenqi}
			},
			{{Name, Lev}, {Obj ,EntourageData}};
		_ ->
			case fun_arena:get_all_on_battled_heros(ID) of
				EntourageList when length(EntourageList) > 0 ->
					EntourageData = fun_entourage:get_entourage_battle_data(ID, EntourageList),
					Name = util:get_name_by_uid(ID),
					Lev = util:get_lev_by_uid(ID),
					Obj = #scene_spirit_ex{
						name=Name,camp=4,dir=180,hp=100,final_property=#battle_property{hpLimit = 100}
						,data=#scene_robot_ex{lev = Lev, shenqi_skill=fun_arena:get_arena_used_shenqi(ID)}
					},
					{{Name, Lev}, {Obj ,EntourageData}};
				_ -> ?log_error("not find robot config,id=~p~n",[ID]),[]
			end
	end.

init_entourage([], _Pos, Acc) -> Acc;
init_entourage(_EntourageList, Pos, Acc) when Pos > 5 -> Acc;
init_entourage([{MonsterType, Etype} | Rest], Pos, Acc) ->
	case data_monster:get_monster(MonsterType) of
		#st_monster_config{level = Lev, star = Star, normal_skill = Normal, skill = Skill1} ->
			case data_entourage:get_data(Etype) of
				#st_entourage_config{} ->
					Entourage = #item{type = Etype, lev = Lev, star = Star},
					Battle = fun_property:get_monster_property_by_difficulty(MonsterType, #st_dungeon_dificulty{}),
					Skill = [{SkillType, 1} || SkillType <- Skill1],
					Acc2 = [{Entourage, Battle, [{Normal, 1} | Skill], [], Pos} | Acc],
					init_entourage(Rest, Pos + 1, Acc2);
				_ -> init_entourage(Rest, Pos, Acc)
			end;
		_ -> init_entourage(Rest, Pos, Acc)
	end.