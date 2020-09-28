%% @doc 采矿服务进程
-module (fun_mining_service).
-include ("common.hrl").
-export([init/0, handle_call/1, handle_msg/1, terminate/0, do_loop/1]).
-export([add_mining/1, req_mining_list/3, handle_grab_result/4, add_protect/3]).
-export([refresh_daily_data/1]).


refresh_daily_data(Uid) ->
	gen_server:cast({global, ?MODULE}, {refresh_daily_data, Uid}).


handle_grab_result(Uid, BeGrabbedUid, Result, CurrentGain) ->
	gen_server:cast({global, ?MODULE}, {grab_result, Uid, BeGrabbedUid, Result, CurrentGain}).

req_mining_list(Uid, Sid, Seq) ->
	gen_server:cast({global, ?MODULE}, {req_mining_list, Uid, Sid, Seq}).

add_protect(Uid, Sid, Length) ->
	gen_server:cast({global, ?MODULE}, {add_protect, Uid, Sid, Length}).

add_mining(Uid) ->
	gen_server:cast({global, ?MODULE}, {add_mining, Uid}).


init() -> 
	% List = db:dirty_select(mining, [{#mining{_ = '_', end_time = '$1', uid = '$2'}, [{'>', '$1', 0}], ['$2']}]),
	% put(mining_list, List),
	ok.


handle_call(Request) ->
	?log_error("~p recieve call:~p, but not handled!", [?MODULE, Request]),
	not_handled.


handle_msg({refresh_daily_data, Uid}) -> 
	refresh_daily_data2(Uid);

handle_msg({add_protect, Uid, Sid, Length}) -> 
	add_protect2(Uid, Sid, Length);

handle_msg({grab_result, Uid, BeGrabbedUid, Result, CurrentGain}) -> 
	do_grab_result(Uid, BeGrabbedUid, Result, CurrentGain);

handle_msg({req_mining_list, Uid, Sid, Seq}) ->
	send_mining_list(Uid, Sid, Seq);

handle_msg({add_mining, Uid}) ->
	add_2_mining_list(Uid);

handle_msg(Msg) ->
	?log_error("~p recieve msg:~p, but not handled!", [?MODULE, Msg]),
	ok.


terminate() -> 
	ok.


do_loop(Now) -> 
	LeftList = do_loop_help(Now, get_mining_list(), []),
	put(mining_list, LeftList),
	ok.


do_loop_help(Now, [Uid | Rest], Acc) ->
	case db:dirty_get(mining, Uid, #mining.uid) of
		[] -> 
			do_loop_help(Now, Rest, Acc);
		[Rec = #mining{end_time = EndTime}] -> 
			if 
				EndTime > 0 andalso EndTime =< Now ->
					do_mining_over(Uid, Rec),
					do_loop_help(Now, Rest, Acc);
				EndTime == 0 -> 
					do_loop_help(Now, Rest, Acc);
				true -> 
					do_loop_help(Now, Rest, [Uid | Acc])
			end
	end;
do_loop_help(_Now, [], Acc) -> Acc.


do_mining_over(Uid, Rec) ->  
	Num = data_mining:minging_len() div data_mining:gain_num_per(),
	Num2 = case Rec#mining.gain + Num > data_mining:max_gain() of
		true -> data_mining:max_gain() - Rec#mining.gain;
		_ -> Num
	end,
	Rec2 = Rec#mining{
		end_time = 0, 
		gain = Rec#mining.gain + Num2
	},
	fun_mining:set_data(Rec2),

	#mail_content{mailName = Title, text = Content} = data_mail:data_mail(mining_award),
	Rewards = [{?ITEM_SECRET_SILVER, Num2}],
	mod_mail_new:sys_send_personal_mail(Uid, Title, Content, Rewards, ?MAIL_TIME_LEN),
	ok.


add_2_mining_list(Uid) -> 
	List = get_mining_list(),
	case lists:member(Uid, List) of
		true -> skip;
		_    -> put(mining_list, [Uid | List])
	end.


get_mining_list() ->
	List = get(mining_list),
	case List of
		undefined -> [];
		_ -> List
	end.

del_minig(Uid) ->
	List = lists:delete(Uid, get_mining_list()),
	put(mining_list, List).


add_protect2(Uid, Sid, Length) ->
	Rec = fun_mining:get_data(Uid),
	Now = util_time:unixtime(),
	LastProtectTime = Rec#mining.protect_over_time,
	NewProtectTime = ?_IF(LastProtectTime > Now, LastProtectTime, Now),
	Rec2 = Rec#mining{
		protect_over_time = NewProtectTime + Length
	},
	fun_mining:set_data(Rec2),
	fun_mining:send_info_to_client(Uid, Sid, 0).


refresh_daily_data2(Uid) ->
	Rec = fun_mining:get_data(Uid),
	case util_time:weekday() == 7 of
		true -> DefendRecords = "[]";
		_ -> DefendRecords = Rec#mining.defend_records
	end,
	Rec2 = Rec#mining{
		gain           = 0,
		grab           = 0,
		graped_times   = 0,
		grap_buy_times = 0,
		inspire        = 0,
		exchange_times = "[]",
		defend_records = DefendRecords
	},
	case Rec2 /= Rec of
		true -> fun_mining:set_data(Rec2);
		_ -> skip
	end,
	ok.


send_mining_list(Uid, Sid, Seq) ->
	List = random_mining_list(lists:delete(Uid, get_mining_list())),
	Now = util_time:unixtime(),
	Pt = #pt_mining_list{
		datas = [make_mining_list_pt(U, Now) || U <- List]
	},
	?send(Sid, proto:pack(Pt, Seq)).


random_mining_list(List) when length(List) =< 5 -> 
	List;
random_mining_list(List) ->
	random_mining_list2(List, []).

random_mining_list2(List, Acc) when length(Acc) < 5 ->
	Index = util:rand(1, length(List)),
	E = lists:nth(Index, List),
	random_mining_list2(lists:delete(E, List), [E | Acc]);
random_mining_list2(_List, Acc) -> Acc.
	
make_mining_list_pt(Uid, Now) ->
	[#usr{lev = Lv, paragon_level = PraLev, name = Name}] = db:dirty_get(usr, Uid),
	Rec = fun_mining:get_data(Uid),
	#pt_public_mining_list_des{
		uid        = Uid,
		name       = Name,
		gain       = fun_mining:get_current_gain(Rec, Now),
		lv         = Lv + PraLev,
		in_protect = ?_IF(Rec#mining.protect_over_time > Now, 1, 0),
		head_id    = fun_usr_head:get_headid(Uid)
	}.


do_grab_result(Uid, BeGrabbedUid, Result, _CurrentGain) when Result == lose -> 
	add_grab_times(Uid),
	add_defend_record(BeGrabbedUid, Result, Uid, 0),
	ok;
do_grab_result(Uid, BeGrabbedUid, Result, CurrentGain) when Result == win -> 
	LostAmount = util:floor(CurrentGain * data_mining:grab_ratio() / 100),
	LeftAmount = CurrentGain - LostAmount,
	handle_atker_reward(Uid, LostAmount),
	?debug("LostAmount:~p", [LostAmount]),
	?debug("LeftAmount:~p", [LeftAmount]),
	case fun_mining:get_data(BeGrabbedUid) of 
		#mining{end_time = EndTime} when EndTime > 0 -> 
			del_minig(BeGrabbedUid),
			handle_defender_reward(BeGrabbedUid, LeftAmount, Uid, LostAmount);
		_ -> 
			skip
	end,
	ok.


add_grab_times(Uid) ->
	Rec = fun_mining:get_data(Uid),
	fun_mining:set_data(Rec#mining{graped_times = Rec#mining.graped_times + 1}),
	ok.


add_defend_record(BeGrabbedUid, Result, Uid, LostAmount) ->
	case lists:member(BeGrabbedUid, get_mining_list()) of
		true -> 
			[Rec] = db:dirty_get(mining, BeGrabbedUid, #mining.uid),
			db:dirty_put(add_defend_record2(Rec, Result, Uid, LostAmount)),
			ok;
		_ -> skip
	end.

add_defend_record2(Rec, Result, Uid, LostAmount) ->
	List2 = util:string_to_term(util:to_list(Rec#mining.defend_records)),
	Result2 = ?_IF(Result == win, 0, 1),
	List3 = lists:sublist([{Result2, Uid, util_time:unixtime(), LostAmount} | List2], 30),
	Rec#mining{
		defend_records = util:term_to_string(List3)
	}.


handle_atker_reward(Uid, Amount) -> 
	Rec = fun_mining:get_data(Uid),
	Amount2 = case Rec#mining.grab + Amount > data_mining:max_grab() of
		true -> data_mining:max_grab() - Rec#mining.grab;
		_ -> Amount
	end,
	Rec2 = Rec#mining{
		grab         = Rec#mining.grab + Amount2,
		graped_times = Rec#mining.graped_times + 1
	},
	fun_mining:set_data(Rec2),
	case db:dirty_get(ply, Uid) of
		[#ply{agent_hid = AgentPid}] -> 
			mod_msg:handle_to_agent(AgentPid, fun_mining, {gain_grab_item, Amount2});
		_ -> skip
	end,
	ok.


handle_defender_reward(Uid, LeftAmount, AtkerUid, LostAmount) ->
	Rec = fun_mining:get_data(Uid),
	Rec2 = Rec#mining{
		end_time = 0, 
		gain     = Rec#mining.gain + LeftAmount
	},
	fun_mining:set_data(add_defend_record2(Rec2, win, AtkerUid, LostAmount)),

	#mail_content{mailName = Title, text = Content} = data_mail:data_mail(mining_rob),
	Rewards     = [{?ITEM_SECRET_SILVER, LeftAmount}],
	Content2    = util:format_lang(Content, [util:get_name_by_uid(AtkerUid), LostAmount]),
	mod_mail_new:sys_send_personal_mail(Uid, Title, Content2, Rewards, ?MAIL_TIME_LEN),

	case db:dirty_get(ply, Uid) of
		[#ply{sid = Sid}] ->
			fun_mining:send_info_to_client(Uid, Sid, 0);
		_ -> skip
	end,
	ok.

