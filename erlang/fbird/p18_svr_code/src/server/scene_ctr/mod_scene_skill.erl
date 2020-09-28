%% @doc 新的技能模块，新写的技能方法都将会放这里
-module (mod_scene_skill).
-include ("common.hrl").
-export ([
	do_trigger_hp_stolen/3
]).


%% 生命偷取处理
do_trigger_hp_stolen(AtkObj = #scene_spirit_ex{sort = Sort}, _BeAtkedObj, AtkDemage) when Sort == ?SPIRIT_SORT_USR ->
	#battle_property{
		hpLimit = MaxHp,
		hp_stolen = HpStolen, 
		hp_stolen_percent = Rate
	} = AtkObj#scene_spirit_ex.final_property,
	case Rate > 0 andalso HpStolen > 0 of
		true -> 
			case util:rand(1, 1000) < Rate of
				true -> 
					StolenHp = AtkDemage,
					CurrentHp = AtkObj#scene_spirit_ex.hp,
					AtkObj2 = AtkObj#scene_spirit_ex{hp = min(MaxHp, StolenHp + CurrentHp)},
					{true, AtkObj2, StolenHp};
				_ -> false
			end;
		_ -> false
	end;
do_trigger_hp_stolen(_AtkObj, _BeAtkedObj, _AtkDemage) ->
	false.


