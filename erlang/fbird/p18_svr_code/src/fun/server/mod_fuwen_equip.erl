%% @doc 符文装备模块
-module (mod_fuwen_equip).
-include("common.hrl").
-export ([
	req_load/5, req_unload/5, req_strengthen/4, get_loaded_equips_attr/2,
	cacl_equip_attr/1, req_unload_all/4
]).


req_load(Uid, Sid, Seq, EId, EquipId) ->
	case check_load(Uid, EId, EquipId) of
		{error, Reason} -> ?error_report(Sid, Reason);
		{ok, _Entourage, EquipRec} -> 
			Pos = fun_item_api:get_item_sort(EquipRec#item.type),
			case has_equip_on_pos(Uid, EId, Pos) of
				{true, LoadedEquipRec} -> 
					UnLoadEquip = LoadedEquipRec#item{owner = 0},
					UpdateList = fun_item_api:update_item(Uid, UnLoadEquip);
				_ -> 
					UnLoadEquip = undefined,
					UpdateList = []
			end,
			EquipRec2 = EquipRec#item{owner = EId},
			fun_item_api:update_item(Uid, EquipRec2),
			fun_item:send_items_to_sid(Uid, Sid, UpdateList ++ [EquipRec2], Seq),
			fun_agent_property:add_prop_when_change_fuwen_equip(Uid, EId, EquipRec2, UnLoadEquip)
	end.

check_load(Uid, EId, EquipId) ->
	case util_item:get_item_rec_and_sort(Uid, EId) of
		{Entourage, ?ITEM_TYPE_ENTOURAGE} -> 
			case util_item:get_item_rec_and_sort(Uid, EquipId) of
				{EquipRec = #item{owner = 0}, Sort} -> 
					case lists:member(Sort, ?FUWEN_ALL_POS) of
						true -> {ok, Entourage, EquipRec};
						_ -> {error, "check_data_error"}
					end;
				_ -> 
					{error, "check_data_error"}
			end;
		_ -> 
			{error, "check_data_error"}
	end. 


req_unload(Uid, Sid, Seq, EId, EquipId) ->
	case check_unload(Uid, EId, EquipId) of
		{error, Reason} -> ?error_report(Sid, Reason);
		{ok, _Entourage, EquipRec} -> 
			EquipRec2 = EquipRec#item{owner = 0},
			fun_item_api:update_item(Uid, EquipRec2),
			fun_item:send_items_to_sid(Uid, Sid, [EquipRec2], Seq),
			fun_agent_property:add_prop_when_change_fuwen_equip(Uid, EId, undefined, EquipRec2)
	end.


check_unload(Uid, EId, EquipId) ->
	case util_item:get_item_rec_and_sort(Uid, EId) of
		{Entourage, ?ITEM_TYPE_ENTOURAGE} -> 
			case util_item:get_item_rec_and_sort(Uid, EquipId) of
				{EquipRec = #item{owner = EId}, Sort} -> 
					case lists:member(Sort, ?FUWEN_ALL_POS) of
						true -> {ok, Entourage, EquipRec};
						_ -> {error, "check_data_error"}
					end;
				_ -> 
					{error, "check_data_error"}
			end;
		_ -> 
			{error, "check_data_error"}
	end. 


req_unload_all(Uid, Sid, Seq, EId) ->
	case util_item:get_item_rec_and_sort(Uid, EId) of
		{_Entourage, ?ITEM_TYPE_ENTOURAGE} ->
			List = get_all_loaded_equips(Uid, EId),
			List2 = [Rec#item{owner = 0} || Rec <- List],
			[fun_item_api:update_item(Uid, Rec) || Rec <- List2],
			fun_item:send_items_to_sid(Uid, Sid, List2, Seq),
			fun_agent_property:add_prop(Uid, EId, prop_class_fuwen);
		_ -> 
			?error_report(Sid, "check_data_error")
	end. 

req_strengthen(Uid, Sid, Seq, EquipId) ->
	case check_strengthen(Uid, EquipId) of
		{error, Reason} -> ?error_report(Sid, Reason);
		{ok, EquipRec = #item{owner = EId}, CostNum} -> 
			Succ = fun() -> 
				EquipRec2 = EquipRec#item{lev = EquipRec#item.lev + 1},
				fun_item_api:update_item(Uid, EquipRec2),
				fun_item:send_items_to_sid(Uid, Sid, [EquipRec2], Seq),
				fun_count:on_count_event(Uid, Sid, ?TASK_RUNE_STRENGTHEN, EquipRec#item.lev + 1, 1),
				fun_agent_property:add_prop_when_change_fuwen_equip(Uid, EId, EquipRec2, EquipRec)
			end,
			Args = #api_item_args{
				way      = ?ITEM_WAY_FUWEN_STRENGTHEN,
				spend    = [{?RESOUCE_FUWEN, CostNum}],
				add      = [],
				succ_fun = Succ
			},
			fun_item_api:add_items(Uid, Sid, Seq, Args)
	end.

check_strengthen(Uid, EquipId) ->
	case util_item:get_item_rec_and_sort(Uid, EquipId) of
		{EquipRec = #item{owner = _EId}, Sort}  -> 
			case lists:member(Sort, ?FUWEN_ALL_POS) of
				true ->
					#st_item_type{
						color        = Color, 
						default_star = Star
					} = data_item:get_data(EquipRec#item.type),
					MaxLv = data_fuwen:get_max_strength_lv(Color, Star),
					case EquipRec#item.lev >= MaxLv of
						true -> {error, "common_lv_full"};
						_ -> 
							CostNum = data_fuwen:get_strength_cost(Color, Star),
							{ok, EquipRec, CostNum}
					end;
				_ -> {error, "check_data_error"}
			end;
		_ -> 
			{error, "check_data_error"}
	end.


get_loaded_equips_attr(Uid, EId) -> 
	List = get_all_loaded_equips(Uid, EId),
	get_loaded_equips_attr2(List, []).

get_loaded_equips_attr2([EquipRec | Rest], Acc) -> 
	AddAttr = cacl_equip_attr(EquipRec),
	Acc2 = util_list:add_and_merge_list(Acc, AddAttr, 1, 2),
	get_loaded_equips_attr2(Rest, Acc2);
get_loaded_equips_attr2([], Acc) -> 
	Acc. 

cacl_equip_attr(#item{type = Type, lev = Lv}) -> 
	#st_item_type{
		color        = Color, 
		default_star = Star, 
		prop         = BaseAttr
	} = data_item:get_data(Type),
	AddRate = data_fuwen:get_attr_rate(Color, Star),
	[{T, V + util:floor(V * Lv * AddRate / 10000)} || {T, V} <- BaseAttr];
cacl_equip_attr(_) -> 
	[].


has_equip_on_pos(Uid, EId, Pos) ->
	Fun = fun(#item{type = Type, owner = Owner}) -> 
		fun_item_api:get_item_sort(Type) == Pos andalso EId == Owner
	end,
	case fun_item_api:filter_items(Uid, Fun) of
		[] -> false;
		[Rec] -> {true, Rec}
	end.


%% 获取所有已穿戴的符文装备
get_all_loaded_equips(Uid, EId) ->
	Fun = fun(#item{type = Type, owner = Owner}) -> 
		Pos = fun_item_api:get_item_sort(Type), 
		Owner == EId andalso lists:member(Pos, ?FUWEN_ALL_POS)
	end,
	fun_item_api:filter_items(Uid, Fun).
