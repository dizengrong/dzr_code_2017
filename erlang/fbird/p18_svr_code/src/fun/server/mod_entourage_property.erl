%% 英雄属性处理，用于离线获取英雄属性或者竞技场
-module(mod_entourage_property).
-include("common.hrl").
-export ([get_entourage_prop/2, set_entourage_prop/2, get_total_gs/2]).
-export ([scene_cal_final_property/2]).

get_data(Eid) ->
	case db_api:dirty_read(t_entourage_attr, Eid) of
		[Rec = #t_entourage_attr{}] -> Rec;
		_ -> []
	end.

set_data(Rec) ->
	db_api:dirty_write(Rec).

%% 计算英雄在场景里的最终属性
scene_cal_final_property(BaseBattle, BuffPropertys) ->
	Fun2 = fun(Attrs, ProRec) -> 
		fun_property:add_attrs_to_property(ProRec, Attrs)
	end,
	lists:foldl(Fun2, BaseBattle, [A || {_, A} <- BuffPropertys]).

get_entourage_prop(Uid, Eid) ->
	case get_data(Eid) of
		#t_entourage_attr{battle_attr = Battle} -> Battle;
		_ ->
			Battle = fun_agent_property:get_final_property(Uid, Eid),
			Battle
	end.

set_entourage_prop(Eid, Battle) ->
	Rec = #t_entourage_attr{eid = Eid, battle_attr = Battle},
	set_data(Rec).

get_total_gs(Uid, EidList) ->
	get_total_gs(Uid, EidList, 0).

get_total_gs(Uid, [Eid | Rest], Acc) ->
	Battle = get_entourage_prop(Uid, Eid),
	get_total_gs(Uid, Rest, Battle#battle_property.gs + Acc);
get_total_gs(_Uid, [], Acc) -> 
	Acc.
