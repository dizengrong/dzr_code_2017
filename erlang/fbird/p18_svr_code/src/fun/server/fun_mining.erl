%% @doc 挖矿系统
%% 基于策划的需求和实现的简单性，可以一个人被多个人同时抢夺
-module (fun_mining).
-include("common.hrl").
-export([get_data/1, set_data/1]).
-export([refresh_daily_data/1, handle/1, get_current_gain/2]).
-export([req_mining/3, send_info_to_client/3, req_grab/4, req_exchange/4, req_inspire/3]).
-export([req_bug_grab_times/3]).


%% =============================================================================
get_data(Uid) ->
	case db:dirty_get(mining, Uid, #mining.uid) of
		[] -> #mining{uid = Uid};
		[Rec] -> Rec
	end.

set_data(Rec) -> 
	case element(2, Rec) of
		0 -> db:insert(Rec);
		_ -> db:dirty_put(Rec)
	end.
%% =============================================================================

handle({gain_grab_item, Amount}) -> 
	AddItems = [{?ITEM_WAY_MINING_GRAB, ?ITEM_SECRET_SILVER, Amount}],
	FailFun = fun() ->
		#mail_content{mailName = Title, text = Content} = data_mail:data_mail(mining_overflow),
		mod_mail_new:sys_send_personal_mail(get(uid), Title, Content, [{?ITEM_SECRET_SILVER, Amount}], ?MAIL_TIME_LEN)
	end,
	fun_item_api:check_and_add_items(get(uid), get(sid), [], AddItems, undefined, FailFun).


refresh_daily_data(Uid) -> 
	fun_mining_service:refresh_daily_data(Uid).
	

send_info_to_client(Uid, Sid, Seq) ->
	Rec = get_data(Uid),
	send_info_to_client(Uid, Sid, Seq, Rec).
send_info_to_client(_Uid, Sid, Seq, Rec) -> 
	Now = util_time:unixtime(),
	Pt = #pt_mining_info{
		status               = ?_IF(Rec#mining.end_time > 0, 1, 0),
		mining_left_seconds  = max(0, Rec#mining.end_time - Now),
		protect_left_seconds = max(0, Rec#mining.protect_over_time - Now),
		cur_gain             = get_current_gain(Rec, Now),
		cur_max_gain         = max_gain(),
		gain                 = Rec#mining.gain,
		grab                 = Rec#mining.grab,
		graped_times         = Rec#mining.graped_times,
		grap_buy_times       = Rec#mining.grap_buy_times,
		inspire       		 = Rec#mining.inspire,
		exchange_times       = make_exchange_pt(Rec#mining.exchange_times),
		defend_records       = make_defend_list(Rec#mining.defend_records)
	},
	?send(Sid, proto:pack(Pt, Seq)).


get_current_gain(#mining{gain = CurrentGain, end_time = EndTime}, Now) ->
	Num = max_gain() - max(0, (EndTime - Now) div (data_mining:gain_num_per() * 60)),
	case Num + CurrentGain > data_mining:max_gain() of
		true -> data_mining:max_gain() - CurrentGain;
		_ -> Num
	end.


max_gain() ->
	data_mining:minging_len() div data_mining:gain_num_per().

make_exchange_pt(List) ->
	List2 = util:string_to_term(util:to_list(List)),
	[make_exchange_pt(Id, Times) || {Id, Times} <- List2].
make_exchange_pt(Id, Times) ->
	#pt_public_property_list{
		propertyId = Id, 
		propertyVal = Times
	}.

make_defend_list(List) -> 
	List2 = util:string_to_term(util:to_list(List)),
	[make_defend_pt(D) || D <- List2].


make_defend_pt({Result, GrabberUid, Time, Lost}) ->
	#pt_public_mining_defend_des{
		result      = Result,
		grabber     = util:get_name_by_uid(GrabberUid),
		time        = Time,
		failed_lost = Lost
	}.


req_mining(Uid, Sid, Seq) -> 
	case check_mining(Uid) of
		{error, Reason} -> 
			?error_report(Sid, Reason);
		{ok, Rec} ->
			Now = util_time:unixtime(),
			LastProtectTime = Rec#mining.protect_over_time,
			NewProtectTime = ?_IF(LastProtectTime > Now, LastProtectTime, Now),
			Rec2 = Rec#mining{
				end_time = Now + data_mining:minging_len()*60,
				protect_over_time = data_mining:base_protect_time()*60 + NewProtectTime
			},
			set_data(Rec2),
			send_info_to_client(Uid, Sid, Seq, Rec2),
			fun_mining_service:add_mining(Uid)
	end.


check_mining(Uid) ->
	Rec = get_data(Uid),
	case Rec#mining.end_time > 0 of
		true -> {error, "error_mining_doing"};
		_ ->
			case Rec#mining.gain >= data_mining:max_gain() of
				true -> {error, "error_mining_gain_full"};
				_ ->
					{ok, Rec}
			end
	end.


req_grab(Uid, Sid, Seq, Who) -> 
	case check_grab(Uid, Who) of
		{error, Reason} -> 
			?error_report(Sid, Reason);
		{ok, CurrentGain, MyInspire, OtherInspire} ->
			#st_scene_config{points = PointList} = data_scene_config:get_scene(?MINING_GRAB_SCENE_ID),
			InPos = hd(PointList),
			UsrInfoList = [{Uid,Seq,InPos,#ply_scene_data{sid = Sid}}],
			{Rec, EntourageData} = fun_arena:get_ply_data(Who),
			SceneData = {Uid, CurrentGain, MyInspire, Who, Rec, EntourageData, OtherInspire},
			gen_server:cast({global, scene_mng}, {start_fly, UsrInfoList, ?MINING_GRAB_SCENE_ID, SceneData})
	end,
	ok.


check_grab(Uid, Who) ->
	Now      = util_time:unixtime(),
	Rec      = get_data(Uid),
	OtherRec = get_data(Who),
	case OtherRec of
		#mining{end_time = EndTime} when EndTime > 0 andalso EndTime - Now > 180 ->
			MaxGrabAmount = data_mining:max_grab(),
			LeftGrabTimes = data_mining:free_grab_times() + Rec#mining.grap_buy_times - Rec#mining.graped_times,
			if
				OtherRec#mining.protect_over_time > Now ->
					{error, "error_mining_in_protection"};
				Rec#mining.grab >= MaxGrabAmount -> 
					{error, "error_mining_grab_full"};
				LeftGrabTimes =< 0 -> 
					{error, "error_mining_no_grab_times"};
				true -> 
					CurrentGain = get_current_gain(OtherRec, Now),
					{ok, CurrentGain, Rec#mining.inspire, OtherRec#mining.inspire}
			end;
		_ -> {error, "error_mining_soon_over"}
	end.


req_exchange(Uid, Sid, Seq, Id) ->
	?debug("----"),
	case check_exchange(Uid, Id) of
		{error, Reason} -> 
			?error_report(Sid, Reason);
		{ok, NewRec, CostNum, Items} ->
			SuccCallBack = fun() ->
				set_data(NewRec),
				fun_item_api:send_show_fetched_reward(Uid, Sid, ?SHOW_REWARD_COMMON, Items),
				send_info_to_client(Uid, Sid, Seq) 
			end,
			Costs = [{?ITEM_WAY_MINING_EXCHANGE, ?ITEM_SECRET_SILVER, CostNum}],
			AddItems = [{?ITEM_WAY_MINING_EXCHANGE, I, N} || {I, N} <- Items],
			fun_item_api:check_and_add_items(get(uid), get(sid), Costs, AddItems, SuccCallBack, undefined)
	end,
	ok.

check_exchange(Uid, Id) ->
	Rec = get_data(Uid),
	List2 = util:string_to_term(util:to_list(Rec#mining.exchange_times)),
	case lists:keyfind(Id, 1, List2) of
		false -> 
			{CostNum, Items} = data_mining:get_data(Id),
			Rec2 = Rec#mining{
				exchange_times = util:term_to_string(lists:keystore(Id, 1, List2, {Id, 1}))
			},
			{ok, Rec2, CostNum, Items};
		_ -> {error, "error_mining_no_exchange_times"}
	end.

req_inspire(Uid, Sid, Seq) -> 
	Rec = get_data(Uid),
	case Rec#mining.inspire >= data_inspire:get_max(?MINING_INSPIRE) of
		true -> 
			?error_report(Sid, "error_inspire_full");
		_ -> 
			SuccCallBack = fun() ->
				Rec2 = Rec#mining{inspire = Rec#mining.inspire + 1},
				set_data(Rec2),
				send_info_to_client(Uid, Sid, Seq)
			end,
			#st_inspire{cost = Costs} = data_inspire:get_data(Rec#mining.inspire, ?MINING_INSPIRE),
			Costs2 = [{?ITEM_WAY_MINING_INSPIRE, I, N} || {I, N} <- Costs],
			fun_item_api:check_and_add_items(Uid, Sid, Costs2, [], SuccCallBack, undefined)
			
	end.

req_bug_grab_times(Uid, Sid, Seq) -> 
	Rec = get_data(Uid),
	NewBuyTime = Rec#mining.grap_buy_times + 1,
	NewBuyTime2 = min(NewBuyTime, data_buy_time_price:get_max_times(?BUY_GRAB_TIMES)),
	case data_buy_time_price:get_data(?BUY_GRAB_TIMES,NewBuyTime2) of
		#st_buy_time_price{cost = Cost} ->
			SpendItems = [{?ITEM_WAY_MINING_BUY_GRAB_TIMES, T, N} || {T, N} <- Cost],
			Succ = fun() -> 
				Rec2 = Rec#mining{grap_buy_times = NewBuyTime},
				set_data(Rec2),
				send_info_to_client(Uid, Sid, Seq)
			end,
			fun_item_api:check_and_add_items(Uid, Sid, SpendItems, [], Succ, undefined);
		_ -> skip
	end.


