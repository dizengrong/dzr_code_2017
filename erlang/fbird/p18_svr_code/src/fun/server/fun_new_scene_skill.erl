%% @doc 新的技能实现
%% @time 2017-10-23
-module (fun_new_scene_skill).
-include("common.hrl").
-export([check_and_interrupt_continuity_buff_skill/1]).

%% 打断持续性的buffskill
check_and_interrupt_continuity_buff_skill({_AtkOid,DefOid,_AtkSort,_DefSort,_Demage,_DemageData}) ->
	case fun_scene_obj:get_obj(DefOid) of
		Obj = #scene_spirit_ex{buffs = BuffList} -> 
			case is_in_continuity_buff_skill_state(Obj) of
				false -> skip;
				{true, BuffType} ->
					% ?debug("in_continuity_buff_skill_state, BuffType:~p", [BuffType]),
					case has_interrupt_buff(BuffList) of
						true -> 
							% ?debug("interrupt skill"),
							NewObj = case BuffType of
								aleret -> %% 打断技能预警
									Obj#scene_spirit_ex{skill_aleret_data = 0};
								_ -> 
									fun_scene_buff:del_buff_by_type(Obj, BuffType)
							end,
							fun_scene_obj:update(NewObj);
						false -> skip
					end
			end;
		_ ->
			skip
	end.

%%是否存在可以打断持续性施法的buff
has_interrupt_buff([]) -> false;
has_interrupt_buff([Rec | Rest]) ->
	#st_buff_config{controlSort = ControlSort} = data_buff:get_data(Rec#scene_buff.type),
	case ControlSort of
		?BUFF_CONTROLL_SORT_CHENMO -> true;
		?BUFF_CONTROLL_SORT_XUANYUN -> true;
		?BUFF_CONTROLL_SORT_KONGJU -> true;
		_ -> has_interrupt_buff(Rest)
	end.


% is_in_continuity_buff_skill_state(Oid) when is_integer(Oid) ->
% 	case fun_scene_obj:get_obj(Oid) of
% 		Obj = #scene_spirit_ex{skill_aleret_data = SkillAleretData} -> 
% 			Oid == 1100000006 andalso ?debug("SkillAleretData:~p", [SkillAleretData]),
% 			case SkillAleretData of
% 				#skill_aleret_data{} -> 
% 					{true, aleret};
% 				_ ->
% 					is_in_continuity_buff_skill_state(Obj)
% 			end;
% 		_ -> false
% 	end;
is_in_continuity_buff_skill_state(Obj) ->
	#scene_spirit_ex{buffs = BuffList, skill_aleret_data = SkillAleretData} = Obj,
	case SkillAleretData of
		#skill_aleret_data{} -> 
			{true, aleret};
		aleret_cancel ->
			{true, aleret};
		_ ->
			is_in_continuity_buff_skill_state2(BuffList)
	end.

is_in_continuity_buff_skill_state2([]) -> false;
is_in_continuity_buff_skill_state2([Rec | Rest]) ->
	case data_buff:get_data(Rec#scene_buff.type) of
		#st_buff_config{sort = ?BUFF_SORT_CONTINUITY} ->
			{true, Rec#scene_buff.type};
		#st_buff_config{controlSort = ?BUFF_CONTROLL_SORT_CHIXU} ->
			{true, Rec#scene_buff.type};
		_ ->
			is_in_continuity_buff_skill_state2(Rest)
	end.




