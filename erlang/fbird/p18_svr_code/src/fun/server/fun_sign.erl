%% @doc 签到
-module(fun_sign).
-include("common.hrl").
-export([refresh_data/1]).
-export([send_info_to_client/3, req_sign/3]).
-export([gm_sign/3]).

refresh_data(Uid) ->
	{_SignState, SignData, FetchedData} = fun_usr_misc:get_misc_data(Uid, sign),
	fun_usr_misc:set_misc_data(Uid, sign, {?REWARD_STATE_CAN_FETCH, SignData, FetchedData}),
	send_info_to_client(Uid, get(sid), 0),
	ok.

send_info_to_client(Uid, Sid, Seq) ->
	{SignState, SignData, FetchedData} = fun_usr_misc:get_misc_data(Uid, sign),
	Pt = #pt_return_sign{
		signe_state  = SignState,
		sign_data    = SignData,
		fetched_data = FetchedData
	},
	?send(Sid, proto:pack(Pt, Seq)).

% send_day_info_to_client(_Uid, Sid, Seq, DayNum) ->
% 	Pt = #pt_sign_day{
% 		day_num = DayNum
% 	},
% 	?send(Sid, proto:pack(Pt, Seq)).

%%请求签到
req_sign(Uid, Sid, Seq)->
	{SignState, SignData, FetchedData} = fun_usr_misc:get_misc_data(Uid, sign),
	case SignState of 
		?REWARD_STATE_CAN_FETCH  ->
			SignList = data_sign:get_sign_reward(SignData),
			{NewSignState, NewSignData, NewFetchData} = case lists:keyfind(FetchedData + 1, 1, SignList) of
				{_, _, _} -> {?REWARD_STATE_NOT_REACHED, SignData, FetchedData + 1};
				_ -> {?REWARD_STATE_FETCHED, data_sign:get_next(SignData), 1}
			end,
			{_, ItemType, ItemNum} = lists:keyfind(FetchedData, 1, SignList),
			AddItems = [{ItemType, ItemNum}],
			SuccCallBack = fun() ->
				fun_usr_misc:set_misc_data(Uid, sign, {NewSignState, NewSignData, NewFetchData}),
				fun_item_api:send_show_fetched_reward(Uid, Sid, ?SHOW_REWARD_COMMON, AddItems),
				send_info_to_client(Uid, Sid, Seq),
				ok
			end,
			Args = #api_item_args{
				way      = ?ITEM_WAY_SIGN,
				add      = AddItems,
				succ_fun = SuccCallBack
			},
			fun_item_api:add_items(Uid, Sid, Seq, Args);
		_ -> skip
	end.

gm_sign(Uid, Sid, NewSignDates) ->
	fun_usr_misc:set_misc_data(Uid, sign, {?REWARD_STATE_CAN_FETCH, NewSignDates, []}),
	send_info_to_client(Uid, Sid, 0).