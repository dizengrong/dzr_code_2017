%% @doc 怪物相关
-module (fun_monster).
-include("common.hrl").
-export ([is_boss/1, kill_all_monster/0, get_monster_name/1]).
-export ([get_conf_max_hp/1]).


is_boss(MonsterType) ->
	case data_monster:get_monster(MonsterType) of
		#st_monster_config{rank_level = RankLv} when RankLv >= 1 -> true;
		_ -> false
	end.

kill_all_monster() ->
	ML=fun_scene_obj:get_ml(),
	Fun=fun(Monster) ->
			case Monster of
				#scene_spirit_ex{id=ID,sort=?SPIRIT_SORT_MONSTER} ->					
					fun_scene_obj:remove_obj(ID);						
				_ -> skip
			end					
		end,
	lists:foreach(Fun, ML).


get_monster_name(MonsterType) ->
	case data_monster:get_monster(MonsterType) of
		#st_monster_config{name = Name} -> Name;
		_ -> ""
	end.


get_conf_max_hp(MonsterType) ->
	#st_monster_battle{hplimit = MaxHp} = data_monster:get_monster_prop(MonsterType),
	MaxHp.