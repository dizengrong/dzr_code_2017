-module(fun_store).
-include("common.hrl").
-export([refresh_data/1]).
-export([req_store_info/3,req_refresh_store/4,req_buy_cell/5]).

-export([init_data_help/1]).

-define(NONE_REFRESH,  0). %% 不刷新
-define(DAILY_REFRESH, 1). %% 每天刷新
-define(CLICK_REFRESH, 2). %% 手动刷新

-define(NONE_NEED,    "NO"). %% 没有需求
-define(NEED_LEV,     "LV"). %% 需求等级
-define(NEED_VIP_LEV, "VIP"). %% 需求VIP等级

% ============================= 数据操作 ======================================
init_data(Uid) ->
	StoreList = data_store_config:get_all_store(),
	Fun = fun(Store, Acc) ->
		#st_store_config{cells = CellList} = data_store_config:get_store_data(Store),
		Tuple = {Store, [init_data_help(Cell) || Cell <- CellList]},
		[Tuple | Acc]
	end,
	Rec = #t_role_store{uid = Uid, stores = lists:foldl(Fun, [], StoreList)},
	set_data(Uid, Rec),
	Rec.

init_data_help(Cell) ->
	#st_cell_config{item_id = ItemId, item_num = ItemNum} = data_store_config:get_cell_data(Cell),
	case ItemNum of
		0 ->
			{ItemId1, ItemNum1, _} = hd(fun_draw:box(ItemId)),
			{Cell, ItemId1, ItemNum1};
		_ -> {Cell, ItemId, ItemNum}
	end.

get_data(Uid) -> 
	case mod_role_tab:lookup(Uid, t_role_store) of
		[] -> init_data(Uid);
		[Rec] -> Rec
	end.

set_data(Uid, Rec) -> 
	mod_role_tab:insert(Uid, Rec).
%% ============================= 数据操作 ======================================

req_store_info(Uid, Sid, Seq) ->
	Rec = get_data(Uid),
	FunStore = fun({Store, CellList}) ->
		#pt_public_store_info{
			store_id  = Store,
			cell_list = [#pt_public_cell_info{cell_id = Cell, item_list = [fun_item_api:make_item_get_pt(ItemType, ItemNum)]} || {Cell, ItemType, ItemNum} <- CellList]
		}
	end,
	FunUsr = fun({Cell, BuyTimes}) ->
		#pt_public_usr_buy_cell_info{
			cell_id   = Cell,
			buy_times = BuyTimes
		}
	end,
	Pt = #pt_store_info{
		store_list = lists:map(FunStore, Rec#t_role_store.stores),
		info_list  = [FunUsr(I) || I <- Rec#t_role_store.buy_times]
	},
	?send(Sid, proto:pack(Pt, Seq)).

req_buy_cell(Uid, Sid, Seq, Store, Cell) ->
	Rec = get_data(Uid),
	case check_buy(Uid, Rec, Store, Cell) of
		{ok, NewRec, Cost, Items} ->
			Succ = fun() ->
				set_data(Uid, NewRec),
				fun_item_api:send_show_fetched_reward(Uid, Sid, ?SHOW_REWARD_COMMON, Items),
				req_store_info(Uid, Sid, Seq)
			end,
			Args = #api_item_args{
				way             = ?ITEM_WAY_STORE,
				spend           = Cost,
				add             = Items,
				succ_fun        = Succ
			},
			fun_item_api:add_items(Uid, Sid, Seq, Args);
		{error, Reason} -> ?error_report(Sid, Reason, Seq)
	end.

check_buy(Uid, Rec, Store, Cell) ->
	Lev = util:get_lev_by_uid(Uid),
	VipLev = fun_vip:get_vip_lev(Uid),
	#st_cell_config{cost = Cost, limit = Limit, need = Need, need_lev = NeedLev} = data_store_config:get_cell_data(Cell),
	if
		Need == ?NEED_LEV andalso Lev < NeedLev -> {error, "store_lv"};
		Need == ?NEED_VIP_LEV andalso VipLev < NeedLev -> {error, "store_vip"};
		true ->
			{Store, CellList} = lists:keyfind(Store, 1, Rec#t_role_store.stores),
			{Cell, ItemType, ItemNum} = lists:keyfind(Cell, 1, CellList),
			if
				Limit == 0 ->
					{ok, Rec, Cost, [{ItemType, ItemNum}]};
				true ->
					case lists:keyfind(Cell, 1, Rec#t_role_store.buy_times) of
						{Cell, BuyTimes} ->
							if
								BuyTimes >= Limit -> {error, "store_number"};
								true ->
									NewList = lists:keystore(Cell, 1, Rec#t_role_store.buy_times, {Cell, BuyTimes + 1}),
									NewRec = Rec#t_role_store{buy_times = NewList},
									{ok, NewRec, Cost, [{ItemType, ItemNum}]}
							end;
						_ ->
							NewList = [{Cell, 1} | Rec#t_role_store.buy_times],
							NewRec = Rec#t_role_store{buy_times = NewList},
							{ok, NewRec, Cost, [{ItemType, ItemNum}]}
					end
			end
	end.

req_refresh_store(Uid, Sid, Seq, Store) ->
	case data_store_config:get_store_data(Store) of
		#st_store_config{cells = CellList, refresh = ?CLICK_REFRESH, refresh_cost = Cost} ->
			Succ = fun() ->
				Rec = get_data(Uid),
				StoreCellList = [init_data_help(Cell) || Cell <- CellList],
				NewList = lists:keystore(Store, 1, Rec#t_role_store.stores, {Store, StoreCellList}),
				NewBuyList = refresh_buy_data(Rec#t_role_store.buy_times, CellList),
				NewRec = Rec#t_role_store{stores = NewList, buy_times = NewBuyList},
				set_data(Uid, NewRec),
				?error_report(Sid, "refresh_Success", Seq),
				req_store_info(Uid, Sid, Seq)
			end,
			Args = #api_item_args{
				way             = ?ITEM_WAY_STORE_REFRESH,
				spend           = Cost,
				succ_fun        = Succ
			},
			fun_item_api:add_items(Uid, Sid, Seq, Args);
		_ -> skip
	end.

refresh_data(Uid) ->
	Rec = get_data(Uid),
	List = Rec#t_role_store.stores,
	StoreList = data_store_config:get_all_store(),
	{NewCellList, NewBuyList} = refresh_data_help(List, StoreList, [], Rec#t_role_store.buy_times),
	NewRec = Rec#t_role_store{stores = NewCellList, buy_times = NewBuyList},
	set_data(Uid, NewRec).

refresh_data_help(_List, [], Acc1, Acc2) -> {Acc1, Acc2};
refresh_data_help(List, [Store | Rest], Acc1, Acc2) ->
	case data_store_config:get_store_data(Store) of
		#st_store_config{cells = CellList, refresh = ?DAILY_REFRESH} ->
			Tuple = {Store, [init_data_help(Cell) || Cell <- CellList]},
			NewBuyList = refresh_buy_data(Acc2, CellList),
			refresh_data_help(List, Rest, [Tuple | Acc1], NewBuyList);
		_ ->
			{Store, StoreCellList} = lists:keyfind(Store, 1, List),
			refresh_data_help(List, Rest, [{Store, StoreCellList} | Acc1], Acc2)
	end.

refresh_buy_data(List, CellList) ->
	Fun = fun(CellId, Acc) ->
		lists:keydelete(CellId, 1, Acc)
	end,
	lists:foldl(Fun, List, CellList).