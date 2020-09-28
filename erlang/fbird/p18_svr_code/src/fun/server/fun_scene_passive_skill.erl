-module(fun_scene_passive_skill).
-include("common.hrl").

-export([trigger_skill/4]).


-define (TRIGGER_ATK, 1011).
-define (TRIGGER_BEATK, 1012).
-define (TRIGGER_ATK_NORMAL, 1013).


get_cast_time(Oid, SkillId) ->
	case erlang:get({cast_time, Oid, SkillId}) of
		undefined -> 0;
		Time -> Time
	end.

set_cast_time(Oid, SkillId, Time) ->
	erlang:put({cast_time, Oid, SkillId}, Time).


trigger_skill(AtkObj, BeAtkedObj, Damage, SkillMode) ->
	#scene_spirit_ex{id = Oid, sort = AtkSort, passive_skill_data = Skills1, hp = Hp1, buffs = AtkBuffs} = AtkObj,
	#scene_spirit_ex{id = DefOid, sort = DefSort, passive_skill_data = Skills2, hp = Hp2, buffs = BeAtkBuffs} = BeAtkedObj,
	#battle_property{hpLimit = HpLimit1} = AtkObj#scene_spirit_ex.final_property,
	#battle_property{hpLimit = HpLimit2} = BeAtkedObj#scene_spirit_ex.final_property,
	AtkBuffs2 = [T || #scene_buff{type = T} <- AtkBuffs],
	BeAtkBuffs2 = [T || #scene_buff{type = T} <- BeAtkBuffs],
	AtkHpRate = Hp1 / HpLimit1 * 10000,
	DefHpRate = (Hp2 - Damage) / HpLimit2 * 10000,
	Now = fun_scene:get_time(),
	% ?debug("Oid:~p, Skills1:~w", [Oid, Skills1]),
	case find_atk_trigger_skill(Skills1, Oid, AtkSort, AtkHpRate, AtkBuffs2, DefHpRate, Now, SkillMode) of
		{ok, TriggerSkill, Lv} ->
			?debug("trigger attack skill:~p", [TriggerSkill]),
			{ok, AtkObj2, BeAtkedObj2} = trigger_atk_skill(AtkObj, BeAtkedObj, TriggerSkill, Lv),
			case find_def_trigger_skill(Skills2, DefOid, DefSort, AtkHpRate, AtkBuffs2, DefHpRate, Now) of
				{ok, DefTriggerSkill, Lv} ->
					?debug("trigger defend skill:~p", [DefTriggerSkill]),
					trigger_def_skill(AtkObj2, BeAtkedObj2, DefTriggerSkill, Lv);
				_ -> {ok, AtkObj2, BeAtkedObj2}
			end;
		_ -> 
			case find_def_trigger_skill(Skills2, DefOid, DefSort, AtkHpRate, BeAtkBuffs2, DefHpRate, Now) of
				{ok, DefTriggerSkill, Lv} ->
					?debug("trigger defend skill:~p", [DefTriggerSkill]),
					trigger_def_skill(AtkObj, BeAtkedObj, DefTriggerSkill, Lv);
				_ -> {ok, AtkObj, BeAtkedObj}
			end
	end.


trigger_atk_skill(#scene_spirit_ex{id = Oid, final_property = BattleProperty} = AtkObj, #scene_spirit_ex{id = TOid} = BeAtkedObj, TriggerSkill, Lv) ->
	#passive_skill{
		skill = SkillList,
		add_self_buff = AddSelfBuff,
		add_other_buff = AddOtherBuff,
		add_all_friend_buff = AddFriendBuff,
		add_all_enemy_buff = AddEnemyBuff
	} = data_passive_skill:get_data(TriggerSkill),
	Fun1 = fun({Type, PropertyType, PropertyBase, PropertyAdd, BasePower, PowerAdd, BaseLen, LenAdd}, Acc) ->
		Property = fun_property:property_get_data(BattleProperty,PropertyType),
		PropertyPower = util:ceil(Property*((PropertyBase+(PropertyAdd * (Lv-1)))/10000)),
		fun_scene_buff:add_buff(Acc,Type, PropertyPower + BasePower + PowerAdd*(Lv-1),BaseLen + LenAdd*(Lv-1),Oid)
	end,
	AtkObj2 = lists:foldl(Fun1, AtkObj, AddSelfBuff),
	BeAtkedObj2 = lists:foldl(Fun1, BeAtkedObj, AddOtherBuff),
	add_friend_buff(Oid, BattleProperty, AtkObj, AddFriendBuff, Lv),
	add_enemy_buff(Oid, TOid, BattleProperty, AtkObj, AddEnemyBuff, Lv),
	set_cast_time(Oid, TriggerSkill, fun_scene:get_time()),
	cast_skill_help(Oid, TOid, SkillList, Lv),
	{ok, AtkObj2, BeAtkedObj2}.


trigger_def_skill(#scene_spirit_ex{id = TOid} = AtkObj, #scene_spirit_ex{id = DefOid, final_property = BattleProperty} = BeAtkedObj, TriggerSkill, Lv) ->
	#passive_skill{
		skill = SkillList,
		add_self_buff = AddSelfBuff,
		add_other_buff = AddOtherBuff,
		add_all_friend_buff = AddFriendBuff,
		add_all_enemy_buff = AddEnemyBuff
	} = data_passive_skill:get_data(TriggerSkill),
	Fun1 = fun({Type, PropertyType, PropertyBase, PropertyAdd, BasePower, PowerAdd, BaseLen, LenAdd}, Acc) ->
		Property = fun_property:property_get_data(BattleProperty,PropertyType),
		PropertyPower = util:ceil(Property*((PropertyBase+(PropertyAdd * (Lv-1)))/10000)),
		fun_scene_buff:add_buff(Acc,Type, PropertyPower + BasePower + PowerAdd*(Lv-1),BaseLen + LenAdd*(Lv-1),DefOid)
	end,
	AtkObj2 = lists:foldl(Fun1, AtkObj, AddOtherBuff),
	BeAtkedObj2 = lists:foldl(Fun1, BeAtkedObj, AddSelfBuff),
	add_friend_buff(DefOid, BattleProperty, BeAtkedObj, AddFriendBuff, Lv),
	add_enemy_buff(DefOid, TOid, BattleProperty, BeAtkedObj, AddEnemyBuff, Lv),
	set_cast_time(DefOid, TriggerSkill, fun_scene:get_time()),
	cast_skill_help(DefOid, TOid, SkillList, Lv),
	{ok, AtkObj2, BeAtkedObj2}.


has_buff([], _AtkBuffs) -> true;
has_buff(CnfBuffList, AtkBuffs) -> 
	has_buff2(CnfBuffList, AtkBuffs).

has_buff2([Buff | Rest], AtkBuffs) -> 
	case lists:member(Buff, AtkBuffs) of
		true -> true;
		_ -> has_buff2(Rest, AtkBuffs)
	end;
has_buff2([], _AtkBuffs) -> false. 


find_atk_trigger_skill([{Skill, Lv, Probability} | Rest], Oid, AtkSort, AtkHpRate, AtkBuffs, DefHpRate, Now, SkillMode) ->
	#passive_skill{
		cd           = Cd, 
		trigger_type = TriggerType,
		has_buff     = CnfBuffList,
		selfHpRate   = CnfAtkHpRate,
		targetHpRate = CnfTargetHpRate
	} = data_passive_skill:get_data(Skill),
	Ret = case (TriggerType == ?TRIGGER_ATK_NORMAL andalso SkillMode == "NORMALSKILL") orelse (TriggerType == ?TRIGGER_ATK andalso SkillMode /= "NORMALSKILL") of
		true -> 
			case Now - Cd > get_cast_time(Oid, Skill) of 
				true ->
					case AtkHpRate =< CnfAtkHpRate andalso 
						 DefHpRate =< CnfTargetHpRate andalso 
						 has_buff(CnfBuffList, AtkBuffs) of
						true ->
							case util:rand(0, 10000) < Probability of
								true -> 
									{ok, Skill, Lv};
								_ -> skip
							end;
						_ -> skip
					end;
				_ -> skip
			end;
		_ -> skip
	end,
	case Ret of
		{ok, _, _} -> Ret;
		_ -> 
			find_atk_trigger_skill(Rest, Oid, AtkSort, AtkHpRate, AtkBuffs, DefHpRate, Now, SkillMode)
	end;
find_atk_trigger_skill([], _Oid, _AtkSort, _AtkHpRate, _AtkBuffs, _DefHpRate, _Now, _SkillMode) -> skip.



find_def_trigger_skill([{Skill, Lv, Probability} | Rest], DefOid, DefSort, AtkHpRate, DefBuffs, DefHpRate, Now) ->
	#passive_skill{
		cd           = Cd, 
		trigger_type = TriggerType,
		has_buff     = CnfBuffList,
		selfHpRate   = CnfAtkHpRate,
		targetHpRate = CnfTargetHpRate
	} = data_passive_skill:get_data(Skill),
	Ret = case TriggerType == ?TRIGGER_BEATK of
		true -> 
			case Now - Cd > get_cast_time(DefOid, Skill) of 
				true ->
					case AtkHpRate < CnfAtkHpRate andalso 
						 DefHpRate < CnfTargetHpRate andalso 
						 has_buff(CnfBuffList, DefBuffs) of
						true ->
							case util:rand(0, 10000) < Probability of
								true -> 
									{ok, Skill, Lv};
								_ -> skip
							end;
						_ -> skip
					end;
				_ -> skip
			end;
		_ -> skip
	end,
	case Ret of
		{ok, _, _} -> Ret;
		_ -> 
			find_def_trigger_skill(Rest, DefOid, DefSort, AtkHpRate, DefBuffs, DefHpRate, Now)
	end;
find_def_trigger_skill([], _DefOid, _DefSort, _AtkHpRate, _DefBuffs, _DefHpRate, _Now) -> skip.

add_friend_buff(Oid, BattleProperty, Obj, AddFriendBuff, Lv) ->
	Fun = fun({Type, PropertyType, PropertyBase, PropertyAdd, BasePower, PowerAdd, BaseLen, LenAdd}, Acc) ->
		Property = fun_property:property_get_data(BattleProperty,PropertyType),
		PropertyPower = util:ceil(Property*((PropertyBase+(PropertyAdd * (Lv-1)))/10000)),
		case Acc of
			#scene_spirit_ex{id = Id} ->
				if
					Id /= Oid -> fun_scene_obj:update(fun_scene_buff:add_buff(Acc, Type, PropertyPower + BasePower + PowerAdd*(Lv-1), BaseLen + LenAdd*(Lv-1), Oid));
					true -> Acc
				end;
			_ -> Acc
		end
	end,
	case Obj#scene_spirit_ex.sort of
		?SPIRIT_SORT_USR -> [lists:foldl(Fun, fun_scene_obj:get_obj(Eid), AddFriendBuff) || Eid <- fun_scene_obj:get_usr_spc_data(Obj,battle_entourage)];
		?SPIRIT_SORT_ROBOT -> [lists:foldl(Fun, fun_scene_obj:get_obj(Eid), AddFriendBuff) || Eid <- fun_scene_obj:get_robot_spc_data(Obj,battle_entourage)];
		?SPIRIT_SORT_ENTOURAGE ->
			Owner = fun_scene_obj:get_entourage_spc_data(Obj,owner_id),
			TObj = fun_scene_obj:get_obj(Owner),
			lists:foldl(Fun, TObj, AddFriendBuff),
			case TObj of
				#scene_spirit_ex{sort = ?SPIRIT_SORT_USR} -> [lists:foldl(Fun, fun_scene_obj:get_obj(Eid), AddFriendBuff) || Eid <- fun_scene_obj:get_usr_spc_data(TObj,battle_entourage)];
				#scene_spirit_ex{sort = ?SPIRIT_SORT_ROBOT} -> [lists:foldl(Fun, fun_scene_obj:get_obj(Eid), AddFriendBuff) || Eid <- fun_scene_obj:get_robot_spc_data(TObj,battle_entourage)];
				_ -> skip
			end;
		_ -> skip
	end.

add_enemy_buff(Oid, TOid, BattleProperty, Obj, AddEnemyBuff, Lv) ->
	Scene = get(scene),
	Fun = fun(#scene_spirit_ex{camp = Camp}) ->
		fun_scene_collect_obj:get_relation_config(Camp, Obj#scene_spirit_ex.camp, Scene) == ?RELATION_ENEMY
	end,
	Fun1 = fun({Type, PropertyType, PropertyBase, PropertyAdd, BasePower, PowerAdd, BaseLen, LenAdd}, Acc) ->
		Property = fun_property:property_get_data(BattleProperty,PropertyType),
		PropertyPower = util:ceil(Property*((PropertyBase+(PropertyAdd * (Lv-1)))/10000)),
		case Acc of
			#scene_spirit_ex{id = Id} ->
				if
					Id /= TOid -> fun_scene_obj:update(fun_scene_buff:add_buff(Acc, Type, PropertyPower + BasePower + PowerAdd*(Lv-1),BaseLen + LenAdd*(Lv-1), Oid));
					true -> Acc
				end;
			_ -> Acc
		end
	end,
	List = lists:filter(Fun, fun_scene_obj:get_all()),
	[lists:foldl(Fun1, TObj, AddEnemyBuff) || TObj <- List].

cast_skill_help(_AtkOid, _BeAtkOid, [], _Lev) -> skip;
cast_skill_help(AtkOid, BeAtkOid, [Skill | Rest], Lev) ->
	mod_msg:handle_to_scene(self(), fun_scene_skill, {cast_passive_skill, AtkOid, BeAtkOid, Skill, Lev}),
	cast_skill_help(AtkOid, BeAtkOid, Rest, Lev).