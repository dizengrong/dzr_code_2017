%% P18英雄装备模块
-module(mod_entourage_equipment).
-include("common.hrl").
-export([req_once_unload_equipment/4]).
-export([req_equipment/5,req_unload_equipment/5,req_equipment_synthwsis/5]).
-export([get_equip_prop/2, get_equip_suit_prop/2, cacl_equip_attr/3]).

-define(NEED_RACE,       1). %%指定种族
-define(NEED_PROFESSION, 2). %%指定职业
-define(NEED_SEX,        3). %%指定性别
-define(NEED_ENTOURAGE,  4). %%指定英雄

req_once_unload_equipment(Uid, Sid, Seq, Eid) ->
	case fun_item_api:get_item_by_id(Uid, Eid) of
		Entourage = #item{equip_list = EquipmentList} ->
			Fun = fun(ItemId, Acc) ->
				case fun_item_api:get_item_by_id(Uid, ItemId) of
					Equip = #item{owner = Owner} ->
						NewEquip = Equip#item{owner = Owner - 1},
						mod_role_tab:insert(Uid, NewEquip),
						[NewEquip | Acc];
					_ -> Acc
				end
			end,
			ItemList = lists:foldl(Fun, [], EquipmentList),
			NewEntourage = Entourage#item{equip_list = []},
			mod_role_tab:insert(Uid, NewEntourage),
			fun_item:send_items_to_sid(Uid, Sid, [NewEntourage | ItemList], Seq),
			fun_agent_property:add_prop(Uid, Eid, prop_class_item),
			check_and_trigger_suit_add_prop(Uid, Eid),
			fun_entourage:req_attr_info(Uid, Sid, Seq, Eid);
		_ -> skip
	end.

req_unload_equipment(Uid, Sid, EntourageId, ItemId, Seq) ->
	Equip = fun_item_api:get_item_by_id(Uid, ItemId),
	case fun_item_api:get_item_by_id(Uid, EntourageId) of
		Entourage = #item{type = EType, equip_list = EquipmentList} ->
			case lists:member(ItemId, EquipmentList) of
				true ->
					NewEquipmentList = lists:delete(ItemId, EquipmentList),
					NewEquip = Equip#item{owner = Equip#item.owner - 1},
					NewEntourage = Entourage#item{equip_list = NewEquipmentList},
					mod_role_tab:insert(Uid, NewEquip),
					mod_role_tab:insert(Uid, NewEntourage),
					fun_item:send_items_to_sid(Uid, Sid, [NewEquip,NewEntourage], Seq),
					fun_agent_property:add_prop_when_change_equip(Uid, EntourageId, EType, undefined, Equip#item.id),
					check_and_trigger_suit_add_prop(Uid, EntourageId),
					fun_entourage:req_attr_info(Uid, Sid, Seq, EntourageId);
				_ -> skip
			end;
		_ -> skip
	end.

req_equipment_synthwsis(Uid, Sid, ItemType, Times, Seq) ->
	case data_equipment_synthwsis:get_data(ItemType) of
		[] -> skip;
		SpendItems1 ->
			SpendItems = [{T, N * Times} || {T, N} <- SpendItems1],
			AddItems = [{ItemType, Times}],
			Succ = fun() ->
				fun_count:on_count_event(Uid, Sid, ?TASK_EQUIPMENT_SYNTHESIS, fun_item_api:get_default_star(ItemType), Times),
				fun_item_api:send_show_fetched_reward(Uid, Sid, ?SHOW_REWARD_COMMON, AddItems)
			end,
			Args = #api_item_args{
				way      = ?ITEM_WAY_EQUIPMENT_SYNTHWSIS,
				spend    = SpendItems,
				add      = AddItems,
				succ_fun = Succ
			},
			fun_item_api:add_items(Uid, Sid, Seq, Args)
	end.

req_equipment(Uid, Sid, EntourageId, ItemList, Seq) ->
	Entourage = #item{} = fun_item_api:get_item_by_id(Uid, EntourageId),
	Fun = fun(ItemId, {Acc1, Acc2}) ->
		Equip = #item{type = Type, num = Num, owner = Owner} = fun_item_api:get_item_by_id(Uid, ItemId),
		Sort = fun_item_api:get_item_sort(Type),
		case lists:member(Sort, ?EQUIP_LIST) andalso Num > Owner of
			true ->
				EquipmentList = Acc2#item.equip_list,
				NewEquip = Equip#item{owner = Owner + 1},
				case get_sort_equipment(Uid, EquipmentList, Sort) of
					OldEquip = #item{id = Id} ->
						NewOldEquip = OldEquip#item{owner = OldEquip#item.owner - 1},
						NewEquipmentList = [ItemId | lists:delete(Id, EquipmentList)],
						NewEntourage = Acc2#item{equip_list = NewEquipmentList},
						mod_role_tab:insert(Uid, NewOldEquip),
						mod_role_tab:insert(Uid, NewEquip),
						{lists:append([NewOldEquip, NewEquip], Acc1), NewEntourage};
					_ ->
						NewEquipmentList = [ItemId | EquipmentList],
						NewEntourage = Acc2#item{equip_list = NewEquipmentList},
						mod_role_tab:insert(Uid, NewEquip),
						{[NewEquip | Acc1], NewEntourage}
				end;
			_ -> {Acc1, Acc2}
		end
	end,
	{ItemList1, NewEntourage1} = lists:foldl(Fun, {[], Entourage}, ItemList),
	mod_role_tab:insert(Uid, NewEntourage1),
	NewItemList = [NewEntourage1 | ItemList1],
	fun_agent_property:add_prop(Uid, EntourageId, prop_class_item),
	check_and_trigger_suit_add_prop(Uid, EntourageId),
	fun_item:send_items_to_sid(Uid, Sid, NewItemList, Seq),
	fun_entourage:req_attr_info(Uid, Sid, Seq, EntourageId),
	ok.

get_sort_equipment(Uid, EquipmentList, Sort) ->
	Fun = fun(ItemId, Acc) ->
		case fun_item_api:get_item_by_id(Uid, ItemId) of
			Item = #item{type = Type} ->
				case Sort == fun_item_api:get_item_sort(Type) of
					true -> Item;
					_ -> Acc
				end;
			_ -> Acc
		end
	end,
	lists:foldl(Fun, [], EquipmentList).

get_equip_prop(Uid, EntourageId) ->
	case fun_item_api:get_item_by_id(Uid, EntourageId) of
		#item{type = Etype, equip_list = EquipmentList} ->
			Fun = fun(EquipId, Acc) -> 
				Acc ++ cacl_equip_attr(Uid, Etype, EquipId)
			end,
			AttrList = lists:foldl(Fun, [], EquipmentList),
			AttrList;
		_ -> []
	end.

cacl_equip_attr(Uid, Etype, EquipId) -> 
	#item{type = EquipType} = fun_item_api:get_item_by_id(Uid, EquipId),
	#st_entourage_config{sex = Sex, race = Race, profession = Profession} = data_entourage:get_data(Etype),
	case data_item:get_data(EquipType) of
		#st_item_type{prop = BaseProp, spe_prop = SpeProp} ->
			FunSpe = fun({Sort,Need,PropList}, Acc1) ->
				case Sort of
					?NEED_RACE ->
						if
							Race == Need -> Acc1 ++ PropList;
							true -> Acc1
						end;
					?NEED_PROFESSION ->
						if
							Profession == Need -> Acc1 ++ PropList;
							true -> Acc1
						end;
					?NEED_SEX ->
						if
							Sex == Need -> Acc1 ++ PropList;
							true -> Acc1
						end;
					?NEED_ENTOURAGE ->
						if
							Etype == Need -> Acc1 ++ PropList;
							true -> Acc1
						end;
					_ -> Acc1
				end
			end,
			lists:foldl(FunSpe, BaseProp, SpeProp);
		_ ->
			?ERROR("cannot find equip config:~p", [EquipType]), 
			[]
	end.


get_equip_suit_prop(Uid, EntourageId) -> 
	case get({hero_equip_suit, EntourageId}) of
		undefined -> 
			{ActivatedSuits, Attrs} = get_activated_suits(Uid, EntourageId),
			put({hero_equip_suit, EntourageId}, {ActivatedSuits, Attrs}),
			Attrs;
		{_, Attrs} -> Attrs
	end.


get_activated_suits(Uid, EntourageId) ->
	case fun_item_api:get_item_by_id(Uid, EntourageId) of
		#item{equip_list = EquipmentList} ->
			FunSuit = fun(EquipId, Acc) -> 
				#item{type = Type} = fun_item_api:get_item_by_id(Uid, EquipId),
				case data_item_suit:get_suit(Type) of
					0 -> Acc;
					SuitId ->
						case lists:keyfind(SuitId, 1, Acc) of
							{SuitId, Val} -> lists:keystore(SuitId, 1, Acc, {SuitId, Val + 1});
							_ -> [{SuitId, 1} | Acc]
						end
				end
			end,
			SuitList = lists:foldl(FunSuit, [], EquipmentList),
			case SuitList of
				[] -> {[], []};
				_ ->
					Fun1 = fun({SuitId, Num}, {Acc, AccAttr}) ->
						{SuitAttrId, AttrList} = data_item_suit:get_attr(SuitId, Num),
						case SuitAttrId of
							0 -> {Acc, AccAttr};
							_ -> {[SuitAttrId | Acc], AttrList ++ AccAttr}
						end
					end,
					lists:foldl(Fun1, {[], []}, SuitList)
			end;
		_ -> {[], []}
	end.

check_and_trigger_suit_add_prop(Uid, EntourageId) ->
	case get({hero_equip_suit, EntourageId}) of
		undefined -> 
			fun_agent_property:add_prop(Uid, EntourageId, prop_class_item_suit);
		{OldActivatedSuits, _} -> 
			{NewActivatedSuits, Attrs} = get_activated_suits(Uid, EntourageId),
			case lists:sort(NewActivatedSuits) == lists:sort(OldActivatedSuits) of
				true -> skip;
				_ -> 
					put({hero_equip_suit, EntourageId}, {NewActivatedSuits, Attrs}),
					fun_agent_property:add_prop(Uid, EntourageId, prop_class_item_suit)
			end
	end.