%% 转盘
-module(mod_turntable).
-include("common.hrl").
-export([req_normal_turntable_info/3,req_refresh_turntable/3,req_draw_high_turntable/3]).
-export([req_draw_normal_turntable/4]).

-define(DRAW_ONE, 1).

%% =============================================================================
get_data(Uid) ->
	case mod_role_tab:lookup(Uid, t_role_turntable) of
		[] -> init_data(Uid);
		[Rec] -> Rec
	end.

set_data(Rec) ->
	mod_role_tab:insert(Rec#t_role_turntable.uid, Rec).

init_data(Uid) ->
	List = init_data_help([], 1),
	Rec = #t_role_turntable{uid = Uid, normal_record = List},
	set_data(Rec),
	Rec.

init_data_help(Acc, 9) -> Acc;
init_data_help(Acc, Num) ->
	{ItemType, ItemNum, ItemVal} = hd(fun_draw:box(data_turn_table:get_normal_box(Num))),
	init_data_help([{Num, {ItemType, ItemNum, ItemVal}, data_turn_table:get_normal_limit(Num)} | Acc], Num + 1).
%% =============================================================================

req_normal_turntable_info(Uid, Sid, Seq) ->
	Rec = get_data(Uid),
	Pt = #pt_turntable_info{
		energy     = Rec#t_role_turntable.energy,
		free_time  = Rec#t_role_turntable.free_time,
		table_list = [#pt_public_turntable_list{position = Position, times = Times, item = fun_item_api:make_item_pt_list([{ItemType, ItemNum, ItemVal}])} || {Position, {ItemType, ItemNum, ItemVal}, Times} <- Rec#t_role_turntable.normal_record]
	},
	?send(Sid, proto:pack(Pt, Seq)).

req_draw_normal_turntable(Uid, Sid, Seq, Type) ->
	Rec = get_data(Uid),
	{Times, CostNum} = case Type of
		?DRAW_ONE -> {1, data_para:get_data(19)};
		_ -> {10, data_para:get_data(20)}
	end,
	SpendItems = [{100021, CostNum}],
	FunFilter = fun({_, _, Times1}) ->
		Times1 /= 0
	end,
	List = lists:filter(FunFilter, Rec#t_role_turntable.normal_record),
	ItemList = normal_draw_help([], Times, List),
	{Position, _} = hd(ItemList),
	ShowItems = [{ItemType, ItemNum, ItemVal} || {_, {ItemType, ItemNum, ItemVal}} <- ItemList],
	AddItems = [{ItemType, ItemNum, [{strengthen_lev, ItemVal}]} || {ItemType, ItemNum, ItemVal} <- ShowItems],
	Succ = fun() ->
		NewList = make_new_record(ItemList, Rec#t_role_turntable.normal_record),
		NewRec = Rec#t_role_turntable{energy = Rec#t_role_turntable.energy + Times, normal_record = NewList},
		Fun = fun({Position1, _}) ->
			case data_turn_table:get_normal_record(Position1) of
				1 -> true;
				_ -> false
			end
		end,
		RecordList = [{ItemType, ItemNum, ItemVal} || {_, {ItemType, ItemNum, ItemVal}} <- lists:filter(Fun, ItemList)],
		mod_draw_record:add_record(Uid, RecordList, ?LOW_TURNTABLE),
		Pt = #pt_normal_turntable_result{
			position = Position,
			items    = fun_item_api:make_item_pt_list(ShowItems)
		},
		set_data(NewRec),
		fun_count:on_count_event(Uid, Sid, ?TASK_TURNTABLE, 0, Times),
		?send(Sid, proto:pack(Pt, Seq)),
		req_normal_turntable_info(Uid, Sid, Seq)
	end,
	Args = #api_item_args{
		way      = ?ITEM_WAY_NORMAL_TURNTABLE,
		spend    = SpendItems,
		add      = AddItems,
		succ_fun = Succ
	},
	fun_item_api:add_items(Uid, Sid, Seq, Args).

req_refresh_turntable(Uid, Sid, Seq) ->
	Rec = get_data(Uid),
	Now = agent:agent_now(),
	{SpendItems, NewTime} = case Now >= Rec#t_role_turntable.free_time of
		true -> {[], Now + data_para:get_data(23) * 60};
		_ -> {[{?RESOUCE_COIN_NUM, data_para:get_data(22)}], Rec#t_role_turntable.free_time}
	end,
	Succ = fun() ->
		NewRec = Rec#t_role_turntable{free_time = NewTime, normal_record = init_data_help([], 1)},
		set_data(NewRec),
		req_normal_turntable_info(Uid, Sid, Seq)
	end,
	Args = #api_item_args{
		way      = ?ITEM_WAY_NORMAL_TURNTABLE,
		spend    = SpendItems,
		succ_fun = Succ
	},
	fun_item_api:add_items(Uid, Sid, Seq, Args).

req_draw_high_turntable(Uid, Sid, Seq) ->
	Rec = get_data(Uid),
	case Rec#t_role_turntable.energy >= data_para:get_data(21) of
		true ->
			List = init_high_data([], 1),
			{Position, _} = util_list:random_from_tuple_weights(List, 2),
			ItemList = fun_draw:box(data_turn_table:get_high_box(Position)),
			AddItems = [{ItemType, ItemNum, [{strengthen_lev, ItemVal}]} || {ItemType, ItemNum, ItemVal} <- ItemList],
			Succ = fun() ->
				NewRec = Rec#t_role_turntable{energy = Rec#t_role_turntable.energy - data_para:get_data(21)},
				case data_turn_table:get_high_record(Position) of
					1 -> mod_draw_record:add_record(Uid, ItemList, ?HIGH_TURNTABLE);
					_ -> skip
				end,
				Pt = #pt_high_turntable_result{
					energy     = NewRec#t_role_turntable.energy,
					position   = Position,
					table_list = make_high_data([], Position, ItemList, 1)
				},
				set_data(NewRec),
				?send(Sid, proto:pack(Pt, Seq))
			end,
			Args = #api_item_args{
				way      = ?ITEM_WAY_HIGH_TURNTABLE,
				add      = AddItems,
				succ_fun = Succ
			},
			fun_item_api:add_items(Uid, Sid, Seq, Args);
		_ -> skip
	end.

make_new_record([], Acc) -> Acc;
make_new_record([{Position, Item} | Rest], Acc) ->
	{Position, Item, Times} = lists:keyfind(Position, 1, Acc),
	if
		Times > 0 -> make_new_record(Rest, lists:keystore(Position, 1, Acc, {Position, Item, Times - 1}));
		true -> make_new_record(Rest, Acc)
	end.

normal_draw_help(Acc, 0, _List) -> Acc;
normal_draw_help(Acc, Times, List) ->
	{Position, NewList} = make_position(List),
	{Position, Item, _} = lists:keyfind(Position, 1, List),
	normal_draw_help([{Position, Item} | Acc], Times - 1, NewList).

make_position(List) ->
	List1 = [{Position, data_turn_table:get_normal_rate(Position)} || {Position, _, _} <- List],
	{NewPosition, _} = util_list:random_from_tuple_weights(List1, 2),
	{NewPosition, Item, Times} = lists:keyfind(NewPosition, 1, List),
	NewList = case Times > 0 of
		true ->
			if
				Times - 1 == 0 -> lists:keydelete(NewPosition, 1, List);
				true -> lists:keystore(NewPosition, 1, List, {NewPosition, Item, Times - 1})
			end;
		_ -> List
	end,
	{NewPosition, NewList}.

init_high_data(Acc, 9) -> Acc;
init_high_data(Acc, Num) ->
	init_high_data([{Num, data_turn_table:get_high_rate(Num)} | Acc], Num + 1).

make_high_data(Acc, _Position, _AddItems, 9) -> Acc;
make_high_data(Acc, Position, AddItems, Num) ->
	if
		Position == Num -> make_high_data([#pt_public_turntable_list{position = Position, item = fun_item_api:make_item_pt_list(AddItems)} | Acc], Position, AddItems, Num + 1);
		true ->
			Items = fun_draw:box(data_turn_table:get_high_box(Num)),
			Ptm = #pt_public_turntable_list{
				position = Num,
				item     = fun_item_api:make_item_pt_list(Items)
			},
			make_high_data([Ptm | Acc], Position, AddItems, Num + 1)
	end.