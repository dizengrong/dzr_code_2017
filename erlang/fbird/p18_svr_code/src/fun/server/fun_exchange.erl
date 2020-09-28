-module(fun_exchange).
-include("common.hrl").
-export([req_exchange/5]).

req_exchange(Uid, Sid, Id, Num, Seq) ->
	case data_item_exchange:get_data(Id) of
		#st_item_exchange{item = Item, cost = Cost} ->
			SpendItems = [{?ITEM_WAY_ITEM_EXCHANGE, T, N * Num} || {T, N} <- Cost],
			AddItems = [{?ITEM_WAY_ITEM_EXCHANGE, T, N * Num} || {T, N} <- Item],
			Succ = fun() ->
				?error_report(Sid, "exchange_succ", Seq)
			end,
			fun_item_api:check_and_add_items(Uid, Sid, SpendItems, AddItems, Succ, undefined);
		_ -> skip
	end.