%% @doc 神装物品处理
-module (fun_item_god_costume).
-include("common.hrl").
% -export([req_god_costume_info/3,req_active_god_costume_pos/3,req_upgrade_god_costume_stage/3]).
% -export([req_active_god_costume_illustration/4]).
% -export([req_dress_god_costume/5,req_upgrade_god_costume/5,req_god_costume_draw/5]).
% -export([get_property/1,get_fighting/1]).
% -export([check_equ_num/3]).
% -export([is_god_custume/1,get_pos_num/1,get_all_items_in_bag/1,get_backpack_lev/1]).
% -export([init_god_wings/2,fix_bag_data/2]).
% %
% -define(ONE_TIME, 1). %% 单抽
% -define(TEN_TIME, 2). %% 十连

% -define(MAX_GOD_COSTUME_NUM, 12). %% 最大神装数

% init_data(Uid) ->
% 	#usr_god_costume{
% 		uid 		 = Uid,
% 		position_num = init_position(Uid, 0)
% 	}.

% get_data(Uid) ->
% 	case fun_agent_ets:lookup(Uid, usr_god_costume) of
% 		[Rec = #usr_god_costume{}] ->
% 			Rec#usr_god_costume{
% 				illustration 	  = util:string_to_term(util:to_list(Rec#usr_god_costume.illustration)),
% 				illustration_suit = util:string_to_term(util:to_list(Rec#usr_god_costume.illustration_suit))
% 			};
% 		_ -> init_data(Uid)
% 	end.

% set_data(Rec) ->
% 	NewRec = Rec#usr_god_costume{
% 		illustration 	  = util:term_to_string(Rec#usr_god_costume.illustration),
% 		illustration_suit = util:term_to_string(Rec#usr_god_costume.illustration_suit)
% 	},
% 	fun_agent_ets:insert(NewRec#usr_god_costume.uid, NewRec).

% init_god_wings(Uid, Sid) ->
% 	case fun_item:get_item_by_pos(Uid, ?EQU_WING) of
% 		#item{} -> skip;
% 		_ -> init_god_wings_help(Uid, Sid)
% 	end.

% init_god_wings_help(Uid, Sid) ->
% 	Rec = get_data(Uid),
% 	case Rec#usr_god_costume.stage_lev > 0 of
% 		true -> make_god_wing(Uid, Sid, Rec#usr_god_costume.stage_lev);
% 		_ -> skip
% 	end.

% fix_bag_data(Uid, Sid) ->
% 	List = fun_item_api:get_all_items_in_bag(Uid),
% 	Fun = fun(#item{id = Id, type = Type, lev = Lev}, {Acc1, Acc2}) ->
% 		case is_god_custume(Type) of
% 			true ->
% 				{[{?ITEM_WAY_GOD_COSTUME, {item_id, Id}, 1} | Acc1], [{?ITEM_WAY_GOD_COSTUME, Type, 1, [{strengthen_lev, Lev}]} | Acc2]};
% 			_ -> {Acc1, Acc2}
% 		end
% 	end,
% 	{SpendItems, AddItems} = lists:foldl(Fun, {[], []}, List),
% 	fun_item_api:check_and_add_items(Uid, Sid, SpendItems, AddItems).

% make_god_wing(Uid, Sid, Stagelev) ->
% 	Type = data_god_costume:get_stage_wing(Stagelev),
% 	case fun_item:get_item_by_pos(Uid, ?EQU_WING) of
% 		#item{type = OldType} when OldType == Type -> skip;
% 		#item{id = Id} ->
% 			SpendItems = [{?ITEM_WAY_GOD_COSTUME, {item_id, Id}, 1}],
% 			Succ = fun() ->
% 				make_god_wing_help(Uid, Sid, Type)
% 			end,
% 			fun_item_api:check_and_add_items(Uid, Sid, SpendItems, [], Succ, undefined);
% 		_ -> make_god_wing_help(Uid, Sid, Type)
% 	end.

% make_god_wing_help(Uid, Sid, Type) ->
% 	Item = #item{type = Type, pid = Uid,pos = ?EQU_WING},
% 	[NewItem] = fun_agent_ets:insert(Uid, Item),
% 	fun_item:send_items_to_sid(Sid,[NewItem]),
% 	fun_item:send_all_usr_items_to_sid(Sid, Uid, [{Type,1}]),
% 	EquipList = fun_item:get_equipment_item_type(Uid),
% 	fun_agent:send_to_scene({update_equip_list, Uid,EquipList}).

% init_position(Uid, Acc) ->
% 	case data_god_costume:get_pos_num(Acc + 1) of
% 		{0, _} -> init_position(Uid, Acc + 1);
% 		_ -> Acc
% 	end.

% req_god_costume_info(Uid, Sid, Seq) ->
% 	send_info_to_client(Uid, Sid, Seq),
% 	send_illustration_info_to_client(Uid, Sid, Seq).

% req_active_god_costume_pos(Uid, Sid, Seq) ->
% 	Rec = get_data(Uid),
% 	case check_active_pos(Uid, Rec#usr_god_costume.position_num) of
% 		true ->
% 			NewRec = Rec#usr_god_costume{position_num = Rec#usr_god_costume.position_num + 1},
% 			set_data(NewRec),
% 			send_info_to_client(Uid, Sid, Seq);
% 		_ -> skip
% 	end.

% req_upgrade_god_costume_stage(Uid, Sid, Seq) ->
% 	Rec = get_data(Uid),
% 	case get_min_god_costume_lev(Uid) > Rec#usr_god_costume.stage_lev andalso length(get_god_costume_item(Uid)) == ?MAX_GOD_COSTUME_NUM of
% 		true ->
% 			SpendItems = [{?ITEM_WAY_GOD_COSTUME, T, N} || {T, N} <- data_god_costume:get_stage_cost(Rec#usr_god_costume.stage_lev)],
% 			case Rec#usr_god_costume.stage_lev == 0 orelse (Rec#usr_god_costume.stage_lev > 0 andalso length(SpendItems) > 0) of
% 				true ->
% 					Succ = fun() ->
% 						NewRec = Rec#usr_god_costume{stage_lev = Rec#usr_god_costume.stage_lev + 1},
% 						set_data(NewRec),
% 						fun_property:updata_fighting(Uid),
% 						make_god_wing(Uid, Sid, Rec#usr_god_costume.stage_lev + 1),
% 						send_info_to_client(Uid, Sid, Seq)
% 					end,
% 					fun_item_api:check_and_add_items(Uid, Sid, SpendItems, [], Succ, undefined);
% 				_ -> skip
% 			end;
% 		_ -> skip
% 	end.

% % req_buy_god_bag_lev(Uid, Sid, Seq) ->
% % 	MaxLev = util:get_data_para_num(1247),
% % 	Lev = get_backpack_lev(Uid),
% % 	if
% % 		Lev >= MaxLev -> 
% % 			?error_report(Sid,"bag_maxCount");
% % 		true ->
% % 			SpendItems = [{?ITEM_WAY_GOD_COSTUME,?RESOUCE_COIN_NUM,util:get_data_para_num(1245)}],
% % 			Succ = fun() ->
% % 				fun_usr_misc:set_misc_data(Uid, god_bag_lev, Lev + 1),
% % 				Pt = pt_backpack_upgrade_d140:new(),
% % 				Pt1 = Pt#pt_backpack_upgrade{backpack_lev = util:get_bag_lev(Uid), ex_backpack_lev = fun_item:get_card_add_bag(Uid), god_bag_lev = Lev + 1},
% % 				?send(Sid,pt_backpack_upgrade_d140:to_binary(Pt1)),
% % 				?error_report(Sid,"buy_ok",Seq)
% % 			end,
% % 			fun_item_api:check_and_add_items(Uid, Sid, SpendItems, [], Succ, undefined)
% % 	end.

% req_active_god_costume_illustration(Uid, Sid, Id, Seq) ->
% 	Rec = get_data(Uid),
% 	case data_god_costume:get_single_illustration(Id) of
% 		{Cost, SuitId} ->
% 			case check_illustration(Uid, Rec, Cost, Id) of
% 				{ok, SpendItems} ->
% 					Succ = fun() ->
% 						NewRec = Rec#usr_god_costume{illustration = [Id | Rec#usr_god_costume.illustration]},
% 						set_data(NewRec),
% 						case active_illustration(Uid, Sid, SuitId, Seq) of
% 							ok -> skip;
% 							_ ->
% 								fun_property:updata_fighting(Uid),
% 								send_illustration_info_to_client(Uid, Sid, Seq)
% 						end
% 					end,
% 					fun_item_api:check_and_add_items(Uid, Sid, SpendItems, [], Succ, undefined);
% 				_ -> skip
% 			end;
% 		_ -> skip
% 	end.

% req_god_costume_draw(Uid, Sid, Seq, Type, BoxList) ->
% 	case BoxList of
% 		[] -> skip;
% 		_ ->
% 			Multi = case data_god_costume_draw:get_draw_multi(length(BoxList)) of
% 				{Rand, Mul} ->
% 					R = util:rand(1, 10000),
% 					if
% 						Rand >= R -> Mul;
% 						true -> 1
% 					end;
% 				_ -> 1
% 			end,
% 			Times = case Type of
% 				?ONE_TIME -> 1;
% 				?TEN_TIME -> 10;
% 				_ -> 0
% 			end,
% 			Times1 = case Type of
% 				?ONE_TIME -> 1;
% 				?TEN_TIME -> 9;
% 				_ -> 0
% 			end,
% 			Prof = util:get_prof_by_uid(Uid),
% 			Cost1 = [{T, N * Times1} || {T, N} <- data_god_costume_draw:get_position_price(length(data_god_costume_draw:get_box_list())-length(BoxList))],
% 			Cost = lists:append(data_god_costume_draw:get_draw_price(Type), Cost1),
% 			?debug("Cost = ~p",[Cost]),
% 			SpendItems = [{?ITEM_WAY_GOD_COSTUME, T, N} || {T, N} <- Cost],
% 			DrawList = make_draw_list(Times, BoxList, 0, []),
% 			Fun = fun(BoxId, Acc) ->
% 				lists:append(fun_draw:box(BoxId, Prof, false), Acc)
% 			end,
% 			ItemList1 = lists:foldl(Fun, [], DrawList),
% 			ItemList = [{T, N * Multi, L} || {T, N, L} <- ItemList1],
% 			AddItems = [{?ITEM_WAY_GOD_COSTUME, T, N, [{strengthen_lev, L}]} || {T, N, L} <- ItemList],
% 			?debug("AddItems = ~p",[AddItems]),
% 			Succ = fun() ->
% 				send_draw_info_to_client(Uid, Sid, Seq, Multi, ItemList)
% 			end,
% 			fun_item_api:check_and_add_items(Uid, Sid, SpendItems, AddItems, Succ, undefined)
% 	end.

% active_illustration(Uid, Sid, SuitId, Seq) ->
% 	Rec = get_data(Uid),
% 	case data_god_costume:get_illustration(SuitId) of
% 		[] -> skip;
% 		List ->
% 			case lists:member(SuitId, Rec#usr_god_costume.illustration_suit) of
% 				false ->
% 					Fun = fun(Id) ->
% 						lists:member(Id, Rec#usr_god_costume.illustration)
% 					end,
% 					case lists:all(Fun, List) of
% 						true ->
% 							NewRec = Rec#usr_god_costume{illustration_suit = [SuitId | Rec#usr_god_costume.illustration_suit]},
% 							set_data(NewRec),
% 							fun_property:updata_fighting(Uid),
% 							send_illustration_info_to_client(Uid, Sid, Seq),
% 							ok;
% 						_ -> skip
% 					end;
% 				_ -> skip
% 			end
% 	end.

% req_dress_god_costume(Uid, Sid, Seq, ItemId, ItemPos) ->
% 	case check_item(Uid, ItemId, ItemPos) of
% 		{ok, ItemList} ->
% 			[fun_agent_ets:insert(Uid, Item) || Item <- ItemList],
% 			fun_item:send_items_to_sid(Sid,ItemList,Seq),
% 			fun_property:updata_fighting(Uid),
% 			fun_item:send_backpack_is_full_bank(Uid);
% 		_ -> skip
% 	end.

% req_upgrade_god_costume(Uid, Sid, Seq, ItemId, ItemList) ->
% 	NewItemList = make_item_list(Uid, ItemList),
% 	?debug("NewItemList = ~p",[NewItemList]),
% 	case check_upgrade(Uid, ItemId, NewItemList) of
% 		{ok, NewItem, SpendItems} ->
% 			SpendItem = [{?ITEM_WAY_GOD_COSTUME, {item_id, Id}, 1} || Id <- SpendItems],
% 			?debug("SpendItem = ~p",[SpendItem]),
% 			Succ = fun() ->
% 				fun_agent_ets:insert(Uid, NewItem),
% 				fun_property:updata_fighting(Uid),
% 				fun_item:send_items_to_sid(Sid, [NewItem], Seq)
% 			end,
% 			fun_item_api:check_and_add_items(Uid, Sid, SpendItem, [], Succ, undefined);
% 		_ -> ?error_report(Sid, "error_common_not_enough_material") 
% 	end.

% check_active_pos(Uid, PosNum) ->
% 	case data_god_costume:get_pos_num(PosNum + 1) of
% 		{0, _} -> true;
% 		{1, NeedScene} ->
% 			case PosNum >= ?MAX_GOD_COSTUME_NUM of
% 				false -> mod_scene_lev:get_curr_scene_lv(Uid) >= NeedScene;
% 				_ -> false
% 			end;
% 		_ -> false
% 	end.

% check_item(Uid, ItemId, Pos) ->
% 	case fun_item_api:get_item_by_id(Uid, ItemId) of
% 		Item = #item{type = Type, pid = Uid, pos = ItemPos} ->
% 			case is_god_custume(Type) == true andalso has_position(Uid) == true of
% 				true ->
% 					NewItem = Item#item{pos = Pos},
% 					case fun_item:get_item_by_pos(Uid, Pos) of
% 						OldItem = #item{type = OldType} ->
% 							NewOldItem = OldItem#item{pos = ItemPos},
% 							case OldType == Type orelse get_item_sort(OldType) == get_item_sort(Type) orelse has_dress_same(Uid, Type) == false of
% 								true -> {ok, [NewItem, NewOldItem]};
% 								_ -> skip
% 							end;
% 						_ ->
% 							case has_dress_same(Uid, Type) of
% 								false -> {ok, [NewItem]};
% 								_ -> skip
% 							end
% 					end;
% 				_ -> skip
% 			end;
% 		_ -> skip
% 	end.

% get_item_sort(ItemType) -> 
% 	#st_item_type{sort = Sort} = data_item:get_data(ItemType),
% 	Sort.

% check_upgrade(Uid, ItemId, ItemList) ->
% 	case fun_item_api:get_item_by_id(Uid, ItemId) of
% 		Item = #item{type = Type, pid = Uid, lev = Lev} ->
% 			case is_god_custume(Type) == true andalso can_upgrade(Type, Lev) == true of
% 				true ->
% 					case data_god_costume:get_upgrade_data(Type, Lev) of
% 						#st_god_costume_upgrade{nece_cost = Must, non_cost = NonMust} ->
% 							case get_must_cost(ItemList, Must, []) of
% 								{SpendItems1, ItemList1} ->
% 									case get_non_cost(ItemList1, NonMust, []) of
% 										{SpendItems2} ->
% 											SpendItems = lists:append(SpendItems1, SpendItems2),
% 											NewItem = Item#item{lev = Lev + 1},
% 											{ok, NewItem, SpendItems};
% 										_ -> skip
% 									end;
% 								_ -> skip
% 							end;
% 						_ -> skip
% 					end;
% 				_ -> skip
% 			end;
% 		_ -> skip
% 	end.

% can_upgrade(Type, Lev) ->
% 	case data_god_costume:get_data(Type) of
% 		#st_god_costume{limit = Limit} -> Limit > Lev;
% 		_ -> false
% 	end.

% check_illustration(Uid, Rec, Cost, Id) ->
% 	case lists:member(Id, Rec#usr_god_costume.illustration) of
% 		false ->
% 			List = get_item_in_bag(Uid),
% 			case make_illustration_cost(Cost, List, []) of
% 				{ok, SpendItems} -> {ok, SpendItems};
% 				_ -> skip
% 			end;
% 		_ -> skip
% 	end.

% check_equ_num(Uid, NeedLev, NeedNum) ->
% 	List = get_god_costume_item(Uid),
% 	Fun = fun(#item{lev = Lev}) ->
% 		Lev >= NeedLev
% 	end,
% 	length(lists:filter(Fun, List)) >= NeedNum.

% is_god_custume(Type) ->
% 	case data_item:get_data(Type)of
% 		#st_item_type{sort=Sort} -> lists:member(Sort, ?GOD_COSTUME);
% 		_ -> false
% 	end.

% has_position(Uid) ->
% 	Rec = get_data(Uid),
% 	List = get_god_costume_item(Uid),
% 	Rec#usr_god_costume.position_num >= length(List). 

% has_dress_same(Uid, Type) ->
% 	case data_item:get_data(Type) of
% 		#st_item_type{sort = Sort} ->
% 			List = get_god_costume_item(Uid),
% 			Fun = fun(#item{type = Type1}) ->
% 				case data_item:get_data(Type1) of
% 					#st_item_type{sort = Sort} -> true;
% 					_ -> false
% 				end
% 			end,
% 			length(lists:filter(Fun, List)) > 0;
% 		_ -> false
% 	end.

% make_illustration_cost([], _List, Acc) -> {ok, Acc};
% make_illustration_cost([{NeedType, NeedLev} | Rest], List, Acc) ->
% 	case make_illustration_cost_help(List, NeedType, NeedLev, [], []) of
% 		{ok, NewList, SpendItems} ->
% 			make_illustration_cost(Rest, NewList, lists:append(SpendItems, Acc));
% 		_ -> skip
% 	end.

% make_illustration_cost_help([], _NeedType, _NeedLev, _Acc1, _Acc2) -> skip;
% make_illustration_cost_help([Item = #item{id = Id, type = Type, lev = Lev} | Rest], NeedType, NeedLev, Acc1, Acc2) ->
% 	if
% 		Type == NeedType andalso Lev == NeedLev ->
% 			{ok, lists:append(Acc1, Rest), [{?ITEM_WAY_GOD_COSTUME, {item_id, Id}, 1} | Acc2]};
% 		true ->
% 			make_illustration_cost_help(Rest, NeedType, NeedLev, [Item | Acc1], Acc2)
% 	end.

% make_item_list(Uid, ItemList) ->
% 	List = [fun_item_api:get_item_by_id(Uid, ItemId) || ItemId <- ItemList],
% 	Fun = fun(#item{id = Id, type = Type, lev = Lev}, Acc) ->
% 		[{Type, Lev, Id} | Acc]
% 	end,
% 	lists:foldl(Fun, [], List).

% make_id_list_pt([], Acc) -> Acc;
% make_id_list_pt([Id | Rest], Acc) ->
% 	Ptm1 = pt_public_class:id_list_new(),
% 	Ptm = Ptm1#pt_public_id_list{id = Id},
% 	make_id_list_pt(Rest, [Ptm | Acc]).

% make_draw_list(Times, _BoxList, Times, Acc) -> Acc;
% make_draw_list(Times, BoxList, Acc1, Acc2) ->
% 	Rand = util:rand(1, length(BoxList)),
% 	Id = lists:last(lists:sublist(BoxList, Rand)),
% 	make_draw_list(Times, BoxList, Acc1 + 1, [data_god_costume_draw:get_draw_box(Id) | Acc2]).

% get_god_costume_item(Uid)->
% 	List = fun_item_api:get_all_items(Uid),
% 	lists:filter(fun(#item{pos=Pos}) -> Pos >= ?GOD_COSTUME_START andalso Pos =< ?GOD_COSTUME_END end, List).

% get_item_in_bag(Uid)->
% 	List = fun_item_api:get_all_items(Uid),
% 	lists:filter(fun(#item{pos=Pos}) -> Pos =< ?Eqp_BASE end, List).

% get_min_god_costume_lev(Uid) ->
% 	List = get_god_costume_item(Uid),
% 	Fun = fun(#item{lev = Lev}) -> Lev end,
% 	lists:min(lists:map(Fun, List)).

% get_suit_list(Uid) ->
% 	List = get_god_costume_item(Uid),
% 	Fun = fun(#item{type = Type},Acc) ->
% 		Suit = get_suit_id(Type),
% 		case data_god_costume:get_suit(Suit) of
% 			[] -> Acc;
% 			List1 ->
% 				Fun1 = fun(Id1) ->
% 					lists:keyfind(Id1, #item.type, List) /= false
% 				end,
% 				List2 = lists:filter(Fun1, List1),
% 				case length(List1) == length(List2) andalso lists:member(Suit, Acc) == false of
% 					true -> [Suit | Acc];
% 					_ -> Acc
% 				end
% 		end
% 	end,
% 	lists:foldl(Fun, [], List).

% get_must_cost(ItemList, [], Acc) -> {Acc, ItemList};
% get_must_cost(ItemList, [{NeedType, NeedNum, NeedLev} | Rest], Acc) ->
% 	case get_must_cost_help(ItemList, NeedType, NeedNum, NeedLev, [], [], 0) of
% 		{NewItemList, SpendItems} ->
% 			get_must_cost(NewItemList, Rest, lists:append(SpendItems, Acc));
% 		_ -> false
% 	end.

% get_must_cost_help([], _NeedType, NeedNum, _NeedLev, _Acc1, _Acc2, Acc3) when Acc3 < NeedNum -> false;
% get_must_cost_help([{Type, Lev, Id} | Rest], NeedType, NeedNum, NeedLev, Acc1, Acc2, Acc3) ->
% 	if
% 		Type == NeedType andalso Lev == NeedLev ->
% 			if
% 				Acc3 + 1 == NeedNum ->
% 					{lists:append(Rest, Acc1), [Id | Acc2]};
% 				true ->
% 					get_must_cost_help(Rest, NeedType, NeedNum, NeedLev, Acc1, [Id | Acc2], Acc3 + 1)
% 			end;
% 		true ->
% 			get_must_cost_help(Rest, NeedType, NeedNum, NeedLev, [{Type, Lev, Id} | Acc1], Acc2, Acc3)
% 	end.

% get_non_cost(_ItemList, [], Acc) -> {Acc};
% get_non_cost(ItemList, [{NeedSort, NeedSuit, NeedNum, NeedLev} | Rest], Acc) ->
% 	case get_non_cost_help(ItemList, NeedSort, NeedSuit, NeedNum, NeedLev, [], [], 0) of
% 		{NewItemList, SpendItems} ->
% 			get_non_cost(NewItemList, Rest, lists:append(SpendItems, Acc));
% 		_ -> false
% 	end.

% get_non_cost_help([], _NeedSort, _NeedSuit, NeedNum, _NeedLev, _Acc1, _Acc2, Acc3) when Acc3 < NeedNum -> false;
% get_non_cost_help([{Type, Lev, Id} | Rest], NeedSort, NeedSuit, NeedNum, NeedLev, Acc1, Acc2, Acc3) ->
% 	Suit = get_suit_id(Type),
% 	Sort = get_sort(Type),
% 	if
% 		(Sort == NeedSort orelse NeedSort == 0) andalso (Suit == NeedSuit orelse NeedSuit == 0) andalso Lev == NeedLev ->
% 			if
% 				Acc3 + 1 == NeedNum ->
% 					{lists:append(Rest, Acc1), [Id | Acc2]};
% 				true ->
% 					get_non_cost_help(Rest, NeedSort, NeedSuit, NeedNum, NeedLev, Acc1, [Id | Acc2], Acc3 + 1)
% 			end;
% 		true ->
% 			get_non_cost_help(Rest, NeedSort, NeedSuit, NeedNum, NeedLev, [{Type, Lev, Id} | Acc1], Acc2, Acc3)
% 	end.

% get_sort(Type) ->
% 	case data_item:get_data(Type) of
% 		#st_item_type{sort = Sort} -> Sort;
% 		_ -> 0
% 	end.

% get_suit_id(Type) ->
% 	case data_god_costume:get_data(Type) of
% 		#st_god_costume{suit = Suit} -> Suit;
% 		_ -> 0
% 	end.

% send_info_to_client(Uid, Sid, Seq) ->
% 	Rec = get_data(Uid),
% 	Pt1 = pt_god_costume_info_f070:new(),
% 	Pt = Pt1#pt_god_costume_info{
% 		position_num = Rec#usr_god_costume.position_num,
% 		stage_lev 	 = Rec#usr_god_costume.stage_lev
% 	},
% 	?send(Sid, pt_god_costume_info_f070:to_binary(Pt, Seq)).

% send_illustration_info_to_client(Uid, Sid, Seq) ->
% 	Rec = get_data(Uid),
% 	Pt1 = pt_god_costume_illustration_info_f071:new(),
% 	Pt = Pt1#pt_god_costume_illustration_info{
% 		illustration_list 		= make_id_list_pt(Rec#usr_god_costume.illustration, []),
% 		illustration_suit_list 	= make_id_list_pt(Rec#usr_god_costume.illustration_suit, [])
% 	},
% 	?send(Sid, pt_god_costume_illustration_info_f071:to_binary(Pt, Seq)).

% send_draw_info_to_client(_Uid, Sid, Seq, Multi, ItemList) ->
% 	Pt1 = pt_god_costume_draw_f072:new(),
% 	Pt = Pt1#pt_god_costume_draw{
% 		multi_num = Multi,
% 		item_list = fun_item_api:make_item_pt_list(ItemList)
% 	},
% 	?send(Sid, pt_god_costume_draw_f072:to_binary(Pt, Seq)).

% get_property(Uid) ->
% 	Rec = get_data(Uid),
% 	ItemList = get_god_costume_item(Uid),
% 	FunItem = fun(#item{type = Type, lev = Lev}, Acc) ->
% 		lists:append(data_god_costume:get_item_prop(Type, Lev), Acc)
% 	end,
% 	ItemProp = lists:foldl(FunItem, [], ItemList),
% 	StageProp = data_god_costume:get_stage_prop(Rec#usr_god_costume.stage_lev),
% 	SuitList = get_suit_list(Uid),
% 	FunSuit = fun(SuitId, Acc) ->
% 		lists:append(data_god_costume:get_suit_prop(SuitId), Acc)
% 	end,
% 	SuitProp = lists:foldl(FunSuit, [], SuitList),
% 	FunIllustration = fun(IllustrationId, Acc) ->
% 		lists:append(data_god_costume:get_single_illustration_prop(IllustrationId), Acc)
% 	end,
% 	IllustrationProp = lists:foldl(FunIllustration, [], Rec#usr_god_costume.illustration),
% 	FunIllustrationSuit = fun(IllustrationSuitId, Acc) ->
% 		lists:append(data_god_costume:get_illustration_prop(IllustrationSuitId), Acc)
% 	end,
% 	IllustrationSuitProp = lists:foldl(FunIllustrationSuit, [], Rec#usr_god_costume.illustration_suit),
% 	ItemProp ++ StageProp ++ SuitProp ++ IllustrationProp ++ IllustrationSuitProp.

% get_fighting(Uid) ->
% 	Rec = get_data(Uid),
% 	ItemList = get_god_costume_item(Uid),
% 	FunItem = fun(#item{type = Type, lev = Lev}, Acc) ->
% 		data_god_costume:get_item_gs(Type, Lev) + Acc
% 	end,
% 	ItemGs = lists:foldl(FunItem, 0, ItemList),
% 	StageGs = data_god_costume:get_stage_gs(Rec#usr_god_costume.stage_lev),
% 	SuitList = get_suit_list(Uid),
% 	FunSuit = fun(SuitId, Acc) ->
% 		data_god_costume:get_suit_gs(SuitId) + Acc
% 	end,
% 	SuitGs = lists:foldl(FunSuit, 0, SuitList),
% 	FunIllustration = fun(IllustrationId, Acc) ->
% 		data_god_costume:get_single_illustration_gs(IllustrationId) + Acc
% 	end,
% 	IllustrationGs = lists:foldl(FunIllustration, 0, Rec#usr_god_costume.illustration),
% 	FunIllustrationSuit = fun(IllustrationSuitId, Acc) ->
% 		data_god_costume:get_illustration_gs(IllustrationSuitId) + Acc
% 	end,
% 	IllustrationSuitGs = lists:foldl(FunIllustrationSuit, 0, Rec#usr_god_costume.illustration_suit),
% 	ItemGs + StageGs + SuitGs + IllustrationGs + IllustrationSuitGs.

% get_pos_num(Uid) ->
% 	BackpackLev = get_backpack_lev(Uid),
% 	Initial = util:get_data_para_num(1244),%%初始背包格子数
% 	GridBase = util:get_data_para_num(1246),
% 	Initial + (BackpackLev * GridBase) + ?BAG_GOD_COSTUME_START - 1.

% get_backpack_lev(Uid) ->
% 	fun_usr_misc:get_misc_data(Uid, god_bag_lev).

% get_all_items_in_bag(Uid) ->
% 	Items = fun_agent_ets:lookup(Uid, item),
% 	Fun   = fun(Item) -> Item#item.pos >= ?BAG_GOD_COSTUME_START andalso Item#item.pos =< ?BAG_GOD_COSTUME_END end,
% 	lists:filter(Fun, Items).