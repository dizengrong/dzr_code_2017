-module (fun_artifact_fast).
-include("common.hrl").
-export([req_info/3,req_buy/3]).
-export([init_data/1,refresh_data/1,setup_artifact_fast/1]).

-define(ARTIFACT_FAST_NO,0).
-define(ARTIFACT_FAST_YES,1).

get_data(Uid) ->
	fun_usr_misc:get_misc_data(Uid, fast_artifact).

set_data(Uid, Val) ->
	fun_usr_misc:set_misc_data(Uid, fast_artifact, Val).

req_info(Uid, Sid, Seq) ->
	send_info_to_client(Uid, Sid, Seq).

req_buy(Uid, Sid, Seq) ->
	{BuyTimes,EndTime} = get_data(Uid),
	BuyTimes1 = case BuyTimes == 0 of
		true -> BuyTimes + 1;
		_ -> BuyTimes
	end,
	Now = util_time:unixtime(),
	NewEndTime = case EndTime >= Now of
		true -> EndTime + util:get_data_para_num(1086);
		_ -> Now + util:get_data_para_num(1086)
	end,
	NewBuyTimes = min(BuyTimes1, data_buy_time_price:get_max_times(?BUY_ARTIFACT_FAST)),
	NewBuyTimes1 = case NewBuyTimes + 1 >= data_buy_time_price:get_max_times(?BUY_ARTIFACT_FAST) of
		true -> data_buy_time_price:get_max_times(?BUY_ARTIFACT_FAST);
		_ -> NewBuyTimes + 1
	end,
	case data_buy_time_price:get_data(?BUY_ARTIFACT_FAST,NewBuyTimes) of
		#st_buy_time_price{cost = Cost} ->
			SpendItems = [{?ITEM_WAY_ARTIFACT_FAST, T, N} || {T, N} <- Cost],
			Succ = fun() ->
				set_data(Uid, {NewBuyTimes1, NewEndTime}),
				send_info_to_client(Uid, Sid, Seq),
				erlang:start_timer((NewEndTime - Now + 1) * 1000, self(), {?MODULE, setup_artifact_fast, {Uid, Sid, Seq}}),
				?error_report(Sid, "shenqijiasuqi2", Seq)
			end,
			fun_item_api:check_and_add_items(Uid, Sid, SpendItems, [], Succ, undefined);
		_ -> skip
	end.

setup_artifact_fast({Uid, Sid, Seq}) ->
	% ?error_report(Sid, "shenqijiasuqi1", Seq),
	send_info_to_client(Uid, Sid, Seq).

send_info_to_client(Uid, Sid, Seq) ->
	{BuyTimes,EndTime} = get_data(Uid),
	Now = util_time:unixtime(),
	BuyTimes1 = case BuyTimes == 0 of
		true -> BuyTimes + 1;
		_ -> BuyTimes
	end,
	Status = case EndTime >= Now of
		true -> ?ARTIFACT_FAST_YES;
		_ -> ?ARTIFACT_FAST_NO
	end,
	Pt = #pt_artifact_fast{
		time = EndTime,
		status = Status,
		buy_times = BuyTimes1
	},
	?send(Sid, proto:pack(Pt, Seq)).

init_data(Uid) ->
	{BuyTimes,EndTime} = get_data(Uid),
	case BuyTimes == 0 of
		true -> set_data(Uid, {1,EndTime});
		_ -> skip
	end.

refresh_data(Uid) ->
	{_,EndTime} = get_data(Uid),
	set_data(Uid, {1,EndTime}).