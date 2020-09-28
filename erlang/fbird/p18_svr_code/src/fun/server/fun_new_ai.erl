%% @doc 新的怪物ai逻辑处理

-module(fun_new_ai).
-include("common.hrl").
-export([check_can_cast_skill/2,get_orign_target_list/0]).

get_orign_target_list() ->
	fun_scene_obj:get_el().

check_can_cast_skill(ID, SkillList) ->
	case fun_scene_obj:get_obj(ID,?SPIRIT_SORT_MONSTER) of
		MonsterObj when is_record(MonsterObj, scene_spirit_ex) ->
			check_can_cast_skill2(MonsterObj, SkillList);
		_ -> false
	end.

check_can_cast_skill2(_MonsterObj, []) -> false;
check_can_cast_skill2(MonsterObj, [SkillId | Rest]) ->
	case fun_scene_cd:get_cd_by_type(MonsterObj, SkillId) of
		[] ->
			St = data_skillmain:get_skillmain(SkillId),
			CastCondition = St#st_skillmain_config.ai_skill_cast_condition,
			case CastCondition of
				{ConditionType, ConditionData} ->
					case check_ai_skill_condition(MonsterObj, ConditionType, ConditionData) of
						true  -> {true, SkillId};
						false -> check_can_cast_skill2(MonsterObj, Rest)
					end;
				_ -> {true, SkillId}
			end;
		_ -> check_can_cast_skill2(MonsterObj, Rest)
	end.

check_ai_skill_condition(MonsterObj, ?NEW_AI_TYPE_CALL_MONSTER_BY_HP, ConditionData)  ->
	Hp = MonsterObj#scene_spirit_ex.hp,
	MaxHp = MonsterObj#scene_spirit_ex.data#scene_monster_ex.max_hp,
	(Hp/MaxHp*100 < ConditionData);
check_ai_skill_condition(MonsterObj, ?NEW_AI_TYPE_CAST_SKILL_BY_HP, ConditionData)  ->
	Hp = MonsterObj#scene_spirit_ex.hp,
	MaxHp = MonsterObj#scene_spirit_ex.data#scene_monster_ex.max_hp,
	% ?debug("MaxHp:~p, Hp:~p", [MaxHp, Hp]),
	(Hp/MaxHp*100 < ConditionData).
