%% @doc 成长基金
-module (fun_grow_fund).
-include("common.hrl").
-export([req_info/3, req_buy/3, req_fetch/3]).
-export([on_pass_barrirer/2]).
-export([check_data/1,req_refresh/3]).

check_data(Uid) ->
	case fun_usr_misc:get_misc_data(Uid, grow_fund) of
		{Have, FetchedId} -> 
			Step = case Have of
				false -> 0;
				true -> 1
			end,
			fun_usr_misc:set_misc_data(Uid, grow_fund, {Have, Step, FetchedId});
		_ -> skip
	end.

on_pass_barrirer(Uid, Sid) ->
	case check_fetch(Uid) of
		{ok, _, _} -> 
			send_info_to_client(Uid, Sid, 0);
		_ -> skip
	end.


req_info(Uid, Sid, Seq) ->
	send_info_to_client(Uid, Sid, Seq).

%% 购买成长基金
req_buy(Uid, Sid, Seq) ->
	case  check_buy(Uid, Seq) of
		{error, Reason} -> ?error_report(Sid, Reason);
		{error, Reason, Seq, Num} -> ?error_report(Sid, Reason, Seq, [Num]);
		{ok, Cost, NewData} ->
			SpendItems = [{?ITEM_WAY_BUY_GROW_FUND, T, N} || {T, N} <- Cost],
			SuccCallBack = fun() ->
				fun_usr_misc:set_misc_data(Uid, grow_fund, NewData),
				send_info_to_client(Uid, Sid, Seq)
			end,
			fun_item_api:check_and_add_items(Uid, Sid, SpendItems, [], SuccCallBack, undefined)
	end,
	ok.

check_buy(Uid, Seq) ->
	case fun_usr_misc:get_misc_data(Uid, grow_fund) of
		{Have, Step, FetchedId} ->
			Max_step = data_grow_fund:get_max_step(),
			if
				Have -> {error, "check_data_error"};
				Step > Max_step -> {error, "max_step"};
				true ->
					case data_grow_fund:get_reward(FetchedId+1) of
						#st_grow_fund{need = {_, NeedVipLev}, cost = Cost} ->
							VipLv = fun_vip:get_vip_lev(Uid),
							case VipLv >= NeedVipLev of
								true -> 
									NewStep = case Step == 0 of
										true -> 1;
										_ -> Step
									end,
									{ok, Cost, {true, NewStep, FetchedId}};
								_ -> {error, "error_common_need_vip", Seq, NeedVipLev}
							end;
						_ -> {error, "error"}
					end
			end;
		_ -> skip
	end.


send_info_to_client(Uid, Sid, Seq) ->
	{Have, Step, FetchedId} = fun_usr_misc:get_misc_data(Uid, grow_fund),
	WinBarrierId = mod_scene_lev:get_winned_scene_lv(Uid),
	CanFetchToId = data_grow_fund:can_fetch_to_id(WinBarrierId),
	Pt = #pt_grow_fund_info{
		have         = ?_IF(Have, 1, 0),
		step 		 = Step,
		fetched_id   = FetchedId,
		can_fetch_id = CanFetchToId
	},
	?send(Sid, proto:pack(Pt, Seq)),
	ok.


%% 请求领取奖励
req_fetch(Uid, Sid, Seq) ->
	case check_fetch(Uid) of
		{error, Reason} -> ?error_report(Sid, Reason);
		{ok, NewData, Rewards} ->
			SuccCallBack = fun() ->
				fun_usr_misc:set_misc_data(Uid, grow_fund, NewData),
				send_info_to_client(Uid, Sid, Seq)
			end,
			AddItems = [{?ITEM_WAY_FETCH_GROW_FUND, T, N} || {T, N} <- Rewards],
			fun_item_api:check_and_add_items(Uid, Sid, [], AddItems, SuccCallBack, undefined)
	end,
	ok.

check_fetch(Uid) ->
	{Have, Step, FetchedId} = fun_usr_misc:get_misc_data(Uid, grow_fund),
	case Step == 0 of
		true -> {error, "check_data_error"};
		_ ->
			WinBarrierId = mod_scene_lev:get_winned_scene_lv(Uid),
			CanFetchToId = min(data_grow_fund:can_fetch_to_id(WinBarrierId), hd(data_grow_fund:get_all(Step))),
			NewFetchedId = FetchedId + 1,
			MaxId = data_grow_fund:get_max_id(),
			if
				not Have -> {error, "check_data_error"};
				FetchedId >= MaxId -> {error, "check_data_error"};
				NewFetchedId > CanFetchToId -> {error, "error_fetch_reward_not_reached"};
				true ->
					#st_grow_fund{reward = Reward} = data_grow_fund:get_reward(NewFetchedId),
					{ok, {Have, Step, NewFetchedId}, Reward}
			end
	end.

req_refresh(Uid, Sid, Seq) ->
	case check_refresh(Uid) of
		{error, Reason} -> ?error_report(Sid, Reason);
		{ok, NewData} ->
			fun_usr_misc:set_misc_data(Uid, grow_fund, NewData),
			send_info_to_client(Uid, Sid, Seq)
	end.

check_refresh(Uid) ->
	{Have, Step, FetchedId} = fun_usr_misc:get_misc_data(Uid, grow_fund),
	MaxStepId = hd(data_grow_fund:get_all(Step)),
	MaxStep = data_grow_fund:get_max_step(),
	if 
		not Have -> {error, "check_data_error"};
		FetchedId /= MaxStepId -> {error, "error_fetch_reward_not_reached"};
		Step >= MaxStep -> {error, "check_data_error"};
		true ->
			{ok, {false, Step + 1, FetchedId}}
	end.