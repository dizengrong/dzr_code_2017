-module(fun_maze).
-include("common.hrl").
-export ([handle/1]).
-export ([refresh_data/1,refresh_daily_data/1,send_ranklist/1]).
-export ([get_intrusion_info/1,get_intrusion_info_result/1,get_intrusion_info_to_target_server/1,get_intrusion_fight_info_result/1,on_complex_arena_result/1,get_maze_fight_result/1]).
-export ([req_maze_info/3,req_buy_maze_times/3,req_buy_maze_inspare/3,req_maze_explore/3,req_maze_explore_event/4,req_maze_settle/3,req_maze_revenge/5,req_maze_step_reward/3,req_maze_ranklist_info/3]).

-define(OUT_MAZE, 0).
-define(IN_MAZE,  1).

-define(MONSTER_FIGHT, 0).
-define(MONSTER_SWEEP, 1).

-define(GUARD_REVENGE,    2).
-define(GUARD_INSTRUSION, 3).

-define(REWARD_EVENT,    1).
-define(MONSTER_EVENT,   101).
-define(BOX_EVENT,   	 201).
-define(BADAGE_EVENT,    301).
-define(INTRUSION_EVENT, 401).
-define(NONE_EVENT,   	 501).

-define(MAX_LENGTH, util:get_data_para_num(1182)).

init_data(Uid) ->
	#usr_maze{
		uid = Uid,
		power = util:get_data_para_num(1176)
	}.

get_data(Uid) ->
	case db:dirty_get(usr_maze, Uid, #usr_maze.uid) of
		[Rec = #usr_maze{}] ->
			Rec#usr_maze{
				monster_record = util:string_to_term(util:to_list(Rec#usr_maze.monster_record)),
				rewards 	   = util:string_to_term(util:to_list(Rec#usr_maze.rewards)),
				records 	   = util:string_to_term(util:to_list(Rec#usr_maze.records))
			};
		_ -> init_data(Uid)
	end.

set_data(Rec) ->
	NewRec = Rec#usr_maze{
		monster_record = util:term_to_string(Rec#usr_maze.monster_record),
		rewards 	   = util:term_to_string(Rec#usr_maze.rewards),
		records 	   = util:term_to_string(lists:sublist(Rec#usr_maze.records, 30))
	},
	case NewRec#usr_maze.id of
		0 -> db:insert(NewRec);
		_ -> db:dirty_put(NewRec)
	end.

add_reward({Uid, Sid, Rewards, Id, Time}) ->
	Rec = get_data(Uid),
	MonsterRecord = case Time =< util:get_data_para_num(1179) of
		true ->
			case lists:keyfind(Id, 1, Rec#usr_maze.monster_record) of
				false -> [{Id,1} | Rec#usr_maze.monster_record];
				_ ->
					fun_item_api:send_show_fetched_reward(Uid, Sid, ?SHOW_REWARD_COMMON, Rewards),
					Rec#usr_maze.monster_record
			end;
		_ -> Rec#usr_maze.monster_record
	end,
	NewRec = Rec#usr_maze{
		rewards = util_list:add_and_merge_list(Rec#usr_maze.rewards, Rewards, 1, 2),
		monster_record = MonsterRecord
	},
	set_data(NewRec),
	send_info_to_client(Uid, Sid, 0).

handle({add_reward, Uid, Sid, Rewards, Id, Time}) ->
	add_reward({Uid, Sid, Rewards, Id, Time});

handle({add_instrusion_reward, Uid, Sid, Rewards}) ->
	Rec = get_data(Uid),
	NewRec = Rec#usr_maze{
		rewards = util_list:add_and_merge_list(Rec#usr_maze.rewards, Rewards, 1, 2)
	},
	set_data(NewRec),
	send_info_to_client(Uid, Sid, 0);

handle({add_revenge_reward, Uid, Sid, Rewards, TargetUid}) ->
	Rec = get_data(Uid),
	Record = Rec#usr_maze.records,
	{TargetUid, Name, ServerId, ServerName, _, Time, Result, LostList} = lists:keyfind(TargetUid, 1, Record),
	NewRecord = lists:keystore(TargetUid, 1, Record, {TargetUid, Name, ServerId, ServerName, ?CANNOT_REVENGE, Time, Result, LostList}),
	NewRec = Rec#usr_maze{
		rewards = util_list:add_and_merge_list(Rec#usr_maze.rewards, Rewards, 1, 2),
		records = NewRecord
	},
	set_data(NewRec),
	send_info_to_client(Uid, Sid, 0);

handle({put_maze_data, TargetUid, Sid, Data}) ->
	Rec = get_data(TargetUid),
	case Rec#usr_maze.status of
		?IN_MAZE ->
			{Uid, Name, ServerId, ServerName, Type, Time, Result, LostList, NewReward} = Data,
			NewType = case Type of
				instrusion ->
					case Result of
						lose -> ?GUARD_INSTRUSION;
						_ -> ?CAN_REVENGE
					end;
				_ -> ?GUARD_REVENGE
			end,
			NewRecords = [{Uid, Name, ServerId, ServerName, NewType, Time, Result, LostList} | Rec#usr_maze.records],
			NewRec = Rec#usr_maze{
				rewards = NewReward,
				records = NewRecords
			},
			set_data(NewRec),
			send_info_to_client(Uid, Sid, 0);
		_ -> skip
	end;

handle({put_intrusion_info, TargetUid, TargetServerId}) ->
	put(intrusion_info, {TargetUid, TargetServerId});

handle({do_lucky_ranklist, Uid, Lucky, Time}) ->
	do_lucky_ranklist(Uid, Lucky, Time).

fix_data(undefined, Acc) -> Acc;
fix_data([Rec | undefined], Acc) -> 
	lists:reverse([Rec | Acc]);
fix_data([Rec | Rest], Acc) ->
	fix_data(Rest, [Rec | Acc]);
fix_data([], Acc) -> 
	lists:reverse(Acc).

refresh_data(Uid) ->
	Rec = get_data(Uid),
	{AddTimes,NewStartTime} = get_reply_time(Rec#usr_maze.re_time),
	NewTimes = case Rec#usr_maze.power >= util:get_data_para_num(1176) of
		true -> Rec#usr_maze.power;
		_ ->
			case Rec#usr_maze.power + AddTimes >= util:get_data_para_num(1176) of
				true -> util:get_data_para_num(1176);
				_ -> Rec#usr_maze.power + AddTimes
			end
	end,
	StartTime = min(NewStartTime, util_time:unixtime()),
	NewRec = Rec#usr_maze{
		power = NewTimes,
		re_time = StartTime,
		rewards = fix_data(Rec#usr_maze.rewards, []),
		records = fix_data(Rec#usr_maze.records, [])
	},
	set_data(NewRec).

refresh_daily_data(Uid) ->
	Rec = get_data(Uid),
	NewRec = Rec#usr_maze{
		buy_times = 0,
		has_settled = 0
	},
	set_data(NewRec).

req_maze_ranklist_info(Uid, Sid, Seq) ->
	send_ranklist_info(Uid, Sid, Seq).

req_maze_info(Uid, Sid, Seq) ->
	refresh_data(Uid),
	send_info_to_client(Uid, Sid, Seq).

req_buy_maze_times(Uid, Sid, Seq) ->
	Rec = get_data(Uid),
	MaxTimes = fun_vip:get_privilege_added(maze_times, Uid),
	case Rec#usr_maze.buy_times < MaxTimes of
		true ->
			NewBuyTimes = Rec#usr_maze.buy_times + 1,
			#st_buy_time_price{cost=Cost} = data_buy_time_price:get_data(?BUY_MAZE, min(NewBuyTimes, data_buy_time_price:get_max_times(?BUY_MAZE))),
			SpendItems = [{?ITEM_WAY_MAZE, T, N} || {T, N} <- Cost],
			Succ = fun() ->
				NewRec = Rec#usr_maze{
					power = Rec#usr_maze.power + util:get_data_para_num(1178),
					buy_times = NewBuyTimes
				},
				set_data(NewRec),
				send_info_to_client(Uid, Sid, Seq)
			end,
			fun_item_api:check_and_add_items(Uid, Sid, SpendItems, [], Succ, undefined);
		_ -> ?error_report(Sid, "maze01", Seq)
	end.

req_buy_maze_inspare(Uid, Sid, Seq) ->
	Rec = get_data(Uid),
	InspireLev = Rec#usr_maze.inspare,
	case check_buy_inspire(InspireLev) of
		{error, Reason} -> ?error_report(Sid, Reason);
		{ok, NewInspire, Costs} ->
			SpendItems = [{?ITEM_WAY_MAZE, I, N} || {I, N} <- Costs],
			Succ = fun() ->
				NewRec = Rec#usr_maze{
					inspare = NewInspire
				},
				set_data(NewRec),
				send_info_to_client(Uid, Sid, Seq)
			end,
			fun_item_api:check_and_add_items(Uid, Sid, SpendItems, [], Succ, undefined)
	end.

req_maze_explore(Uid, Sid, Seq) ->
	Rec = get_data(Uid),
	Power = Rec#usr_maze.power,
	case Power > 0 of
		true ->
			NewPower = Power - 1,
			StartTime = case Power == util:get_data_para_num(1176) of
				true -> util_time:unixtime();
				_ -> Rec#usr_maze.re_time
			end,
			NewRec = Rec#usr_maze{
				status  = ?IN_MAZE,
				power   = NewPower,
				re_time = StartTime,
				lucky   = Rec#usr_maze.lucky + 1
			},
			mod_msg:handle_to_agnetmng(?MODULE, {do_lucky_ranklist, Uid, Rec#usr_maze.lucky + 1, util_time:unixtime()}),
			do_maze_event(Uid, Sid, Seq),
			set_data(NewRec),
			send_info_to_client(Uid, Sid, Seq);
		_ -> ?error_report(Sid, "maze03", Seq)
	end.

req_maze_explore_event(Uid, Sid, Seq, Id) ->
	case get(maze_event) of
		Id ->
			Rec = get_data(Uid),
			#st_maze_event{type = Type} = data_maze_event:get_data(Id),
			case Type of
				?REWARD_EVENT -> 	do_reward_event(Uid, Sid, Seq, Id, Rec);
				?MONSTER_EVENT -> 	do_monster_event(Uid, Sid, Seq, Id, Rec);
				?BOX_EVENT -> 		do_box_event(Uid, Sid, Seq, Id, Rec);
				?BADAGE_EVENT -> 	do_badage_event(Uid, Sid, Seq, Id, Rec);
				?INTRUSION_EVENT -> do_instrusion_event(Uid, Sid, Seq, Id, Rec);
				_ -> skip
			end;
		_ -> skip
	end.

req_maze_step_reward(Uid, Sid, Seq) ->
	Rec = get_data(Uid),
	case data_maze:get_luckyaward(Rec#usr_maze.step + 1) of
		{Need, BagLev, Rewards} ->
			case Rec#usr_maze.lucky >= Need of
				true ->
					AddItems = [{?ITEM_WAY_MAZE, T, N} || {T, N} <- Rewards],
					Succ = fun() ->
						NewRec = Rec#usr_maze{
							step = Rec#usr_maze.step + 1,
							bagdge = max(Rec#usr_maze.bagdge, BagLev)
						},
						set_data(NewRec),
						fun_item_api:send_show_fetched_reward(Uid, Sid, ?SHOW_REWARD_COMMON, Rewards),
						send_info_to_client(Uid, Sid, Seq)
					end,
					fun_item_api:check_and_add_items(Uid, Sid, [], AddItems, Succ, undefined);
				_ -> skip
			end;
		_ -> skip
	end.

req_maze_settle(Uid, Sid, Seq) ->
	Rec = get_data(Uid),
	case data_maze:get_settle_cost(min(Rec#usr_maze.has_settled+1, data_maze:max_settle_times())) of
		{Cost} ->
			BagLev = Rec#usr_maze.bagdge,
			case data_maze:get_backpack(BagLev) of
				{_, Percent} ->
					Fun = fun({T,N}) -> {T,util:ceil(N*(Percent/100))} end,
					SpendItems = [{?ITEM_WAY_MAZE, T1, N1} || {T1,N1} <- Cost],
					Rewards = lists:map(Fun, Rec#usr_maze.rewards),
					AddItems = [{?ITEM_WAY_MAZE, Type, Num} || {Type, Num} <- Rewards],
					Succ = fun() ->
						NewRec = Rec#usr_maze{
							status 			= ?OUT_MAZE,
							has_settled 	= Rec#usr_maze.has_settled+1,
							bagdge 			= 0,
							inspare 		= 0,
							monster_record  = [],
							rewards 		= [],
							records 		= []
						},
						set_data(NewRec),
						fun_item_api:send_show_fetched_reward(Uid, Sid, ?SHOW_REWARD_COMMON, Rewards),
						send_info_to_client(Uid, Sid, Seq)
					end,
					fun_item_api:check_and_add_items(Uid, Sid, SpendItems, AddItems, Succ, undefined);
				_ -> skip
			end;
		_ -> skip
	end.

req_maze_revenge(Uid, _Sid, _Seq, TargetUid, TargetServerId) ->
	Rec = get_data(Uid),
	Record = Rec#usr_maze.records,
	case lists:keyfind(TargetUid, 1, Record) of
		{TargetUid, _, TargetServerId, _, Type, _, _, _} ->
			case Type of
				?CAN_REVENGE ->
					Msg = {find_intrusion_info_target_server, revenge, Uid, TargetUid, TargetServerId},
					gen_server:cast({global, global_client}, Msg);
				_ -> skip
			end;
		_ -> skip
	end.

send_event_to_client(Uid, Sid, Seq, Id) ->
	Rec = get_data(Uid),
	#st_maze_event{type = Type} = data_maze_event:get_data(Id),
	case Type of
		?INTRUSION_EVENT -> find_info_from_global(Uid, Sid, Seq, Id);
		?MONSTER_EVENT ->
			MonsterType = case lists:keyfind(Id, 1, Rec#usr_maze.monster_record) of
				{Id, _} -> 1;
				_ -> 0
			end,
			Pt = #pt_maze_event{id = Id, monster_type = MonsterType},
			?send(Sid, proto:pack(Pt, Seq));
		_ ->
			Pt = #pt_maze_event{id = Id},
			?send(Sid, proto:pack(Pt, Seq))
	end.

find_info_from_global(Uid, _Sid, _Seq, Id) ->
	Msg = {find_intrusion_info, Id, Uid, mod_scene_lev:get_curr_scene_lv(Uid), db:get_all_config(serverid)},
	gen_server:cast({global, global_client}, Msg).

send_info_to_client(Uid, Sid, Seq) ->
	Rec = get_data(Uid),
	NextTime = case Rec#usr_maze.power >= util:get_data_para_num(1176) of
		true -> 0;
		_ -> Rec#usr_maze.re_time + (util:get_data_para_num(1177) * 60)
	end,
	Pt = #pt_maze_info{
		state 		= Rec#usr_maze.status,
		has_settled = Rec#usr_maze.has_settled,
		power 		= Rec#usr_maze.power,
		buy_times 	= Rec#usr_maze.buy_times,
		lucky 		= Rec#usr_maze.lucky,
		bagdge 		= Rec#usr_maze.bagdge,
		inspare 	= Rec#usr_maze.inspare,
		re_time 	= NextTime,
		step 		= Rec#usr_maze.step,
		rewards 	= fun_item_api:make_item_pt_list(Rec#usr_maze.rewards),
		records 	= make_record_pt(Rec#usr_maze.records, [])
	},
	?send(Sid, proto:pack(Pt, Seq)).

send_ranklist_info(Uid, Sid, Seq) ->
	RankList = fun_agent_mng:get_global_value(maze_ranklist, []),
	{MyRank, MyLucky, PtRankList} = make_ranklist_pt(RankList, Uid, 0, 0, [], 1),
	Pt = #pt_maze_ranklist{
		my_rank  = MyRank,
		my_lucky = MyLucky,
		list 	 = PtRankList
	},
	?send(Sid, proto:pack(Pt, Seq)).

do_maze_event(Uid, Sid, Seq) ->
	Rec = get_data(Uid),
	Lucky = Rec#usr_maze.lucky,
	Type = get_usage_type(Lucky),
	Event = get_usage_event(Type, Lucky),
	put(maze_event, Event),
	send_event_to_client(Uid, Sid, Seq, Event).

get_reply_time(StartTime) ->
	Now = util_time:unixtime(),
	Time = Now - StartTime,
	case Time div (util:get_data_para_num(1177) * 60) of
		N when N > 0 ->
			NewStartTime = StartTime + N * (util:get_data_para_num(1177) * 60),
			{N, NewStartTime};
		_ -> {0, StartTime}
	end.

make_record_pt([], Acc) -> Acc;
make_record_pt([undefined | Rest], Acc) -> make_record_pt(Rest, Acc);
make_record_pt([{Uid, Name, ServerId, ServerName, Type, Time, Result, LostList} | Rest], Acc) ->
	Result1 = get_my_result(Result),
	Pt = #pt_public_maze_record{
		uid 		= Uid,
		name 		= util:to_list(Name),
		server_id 	= ServerId,
		server_name = util:to_list(ServerName),
		type 		= Type,
		time 		= Time,
		result 		= Result1,
		lost_list 	= fun_item_api:make_item_pt_list(LostList)
	},
	make_record_pt(Rest, [Pt | Acc]).

check_buy_inspire(InspireLev) ->
	case data_worldboss:get_inspire(InspireLev + 1, 3) of
		{} -> {error, "error_inspire_full"};
		{_, _} -> 
			{Costs, _} = data_worldboss:get_inspire(InspireLev,3),
			{ok, InspireLev + 1, Costs}
	end.

get_usage_type(Lucky) ->
	TypeList = get_type_list(Lucky),
	Fun = fun(Id, Acc) ->
		#st_maze{prob = Prob} = data_maze:get_data(Id),
		Acc + Prob
	end,
	AllProb = lists:foldl(Fun, 0, TypeList),
	Rand = util:rand(1, AllProb),
	Type = find_id(Rand, TypeList, 0, 0, false),
	Type.

get_usage_event(Type, Lucky) ->
	List = data_maze_event:get_event(Type),
	Fun = fun(Id) ->
		case data_maze_event:get_data(Id) of
			#st_maze_event{need = Need} ->
				if
					Lucky >= Need -> true;
					true -> false
				end;
			_ -> false
		end
	end,
	NewList = lists:filter(Fun, List),
	#st_maze_event{prob = Prob} = data_maze_event:get_data(lists:last(NewList)),
	Rand = util:rand(1, Prob),
	Event = find_event_id(Rand, NewList, 0, false),
	Event.

get_type_list(Lucky) ->
	List = data_maze:get_all(),
	Fun = fun(Id) ->
		case data_maze:get_data(Id) of
			#st_maze{need = Need} ->
				if
					Lucky >= Need -> true;
					true -> false
				end;
			_ -> false
		end
	end,
	lists:filter(Fun, List).

find_id(_Rand, _List, Id, _Interval, true) -> Id;
find_id(Rand, [Id | Rest], ReplaceId, Interval, false) ->
	#st_maze{prob = Prob, type = Type} = data_maze:get_data(Id),
	case Interval + Prob >= Rand of
		true -> find_id(Rand, Rest, Type, Interval + Prob, true);
		_ -> find_id(Rand, Rest, ReplaceId, Interval + Prob, false)
	end.

find_event_id(_Rand, _List, Id, true) -> Id;
find_event_id(Rand, [Id | Rest], ReplaceId, false) ->
	#st_maze_event{prob = Prob} = data_maze_event:get_data(Id),
	case Prob >= Rand of
		true -> find_event_id(Rand, Rest, Id, true);
		_ -> find_event_id(Rand, Rest, ReplaceId, false)
	end.

get_intrusion_info({EventId, FromUid, NeedSceneLev, FromServerId}) ->
	List1 = db:dirty_match(usr, #usr{_='_'}),
	List2 = db:dirty_match(usr_maze, #usr_maze{status = ?IN_MAZE, _='_'}),
	Msg = case get_list(List1, List2, NeedSceneLev, util:get_data_para_num(1182), 0) of
		#usr_maze{uid = Uid} ->
			case Uid == FromUid of
				true -> {send_maze_result_to_from, false, EventId, FromUid, FromServerId, {}};
				_ ->
					[#usr{name = Name, lev = Lev, paragon_level = LegendaryLev, vip_lev = VipLev}] = db:dirty_get(usr, Uid),
					Data = {
						Uid,
						Name,
						fun_property:get_usr_fighting(Uid),
						Lev + LegendaryLev,
						VipLev,
						fun_usr_head:get_headid(Uid),
						db:get_all_config(serverid),
						db:get_all_config(servername)
					},
					{send_maze_result_to_from, true, EventId, FromUid, FromServerId, Data}
			end;
		_ -> {send_maze_result_to_from, false, EventId, FromUid, FromServerId, {}}
	end,
	gen_server:cast({global, global_client}, Msg).


get_list(_List1, _List2, _NeedSceneLev, _Max, 10) -> [];
get_list(List1, List2, NeedSceneLev, Max, Sign) ->
	Fun2 = fun(#usr_maze{uid = Uid}) ->
		case lists:keyfind(Uid, #usr.id, List1) of
			false -> false;
			_ -> true
		end
	end,
	NewList2 = lists:filter(Fun2, List2),
	case NewList2 of
		[] -> get_list(List1, List2, NeedSceneLev, Max * 2, Sign + 1);
		_ ->
			Rand = util:rand(1, length(NewList2)),
			lists:last(lists:sublist(NewList2, Rand))
	end.

get_intrusion_info_result({Result, EventId, Uid, Data}) ->
	case db:dirty_get(ply, Uid) of
		[#ply{sid = Sid, agent_hid = Hid}] ->
			case Result of
				true ->
					{TargetUid,TargetName,TargetFighting,TargetLev,TargetVipLev,TargetHeadId,TargetServerId,TargetServerName} = Data,
					Pt = #pt_maze_event{
						id 			= EventId,
						name 		= util:to_list(TargetName),
						lev 		= TargetLev,
						fighting 	= TargetFighting,
						vip_lev 	= TargetVipLev,
						head_id 	= TargetHeadId,
						server_id 	= TargetServerId,
						servername 	= util:to_list(TargetServerName)
					},
					mod_msg:handle_to_agent(Hid, ?MODULE, {put_intrusion_info, TargetUid, TargetServerId}),
					?send(Sid, proto:pack(Pt));
				_ ->
					Rec = get_data(Uid),
					Event = get_usage_event(501, Rec#usr_maze.lucky),
					send_event_to_client(Uid, Sid, 0, Event)
			end;
		_ -> skip
	end.

do_reward_event(Uid, Sid, Seq, Id, Rec) ->
	#st_maze_event{reward = Rewards} = data_maze_event:get_data(Id),
	NewRec = Rec#usr_maze{
		rewards = util_list:add_and_merge_list(Rec#usr_maze.rewards, Rewards, 1, 2)
	},
	fun_item_api:send_show_fetched_reward(Uid, Sid, ?SHOW_REWARD_COMMON, Rewards),
	set_data(NewRec),
	send_info_to_client(Uid, Sid, Seq).

do_monster_event(Uid, Sid, _Seq, Id, Rec) ->
	#st_maze_event{monster = Monster, reward = Rewards} = data_maze_event:get_data(Id),
	case lists:keyfind(Id, 1, Rec#usr_maze.monster_record) of
		{Id, _} -> add_reward({Uid, Sid, Rewards, Id, 0});
		_ ->
			case data_scene_config:get_scene(?COMPLEX_ARENA_SCENE) of
				#st_scene_config{sort=?SCENE_SORT_COMPLEX_ARENA,points = PointList} ->
					fun_arena:save_usr_pos(Uid),
					put(scene_info, monster),
					UsrInfoList=[{Uid,0,lists:nth(2, PointList),#ply_scene_data{sid = Sid}}],
					SceneData={complex_arena_scene,monster,{Id, Monster},lists:nth(3, PointList)},
					gen_server:cast({global, scene_mng}, {start_fly, UsrInfoList, ?COMPLEX_ARENA_SCENE, SceneData});
				_ -> skip
			end
	end.

do_box_event(Uid, Sid, Seq, Id, Rec) ->
	#st_maze_event{cost = Cost, box = Box} = data_maze_event:get_data(Id),
	SpendItems = [{?ITEM_WAY_MAZE, T, N} || {T, N} <- Cost],
	Succ = fun() ->
		ItemList1 = fun_draw:box(Box, util:get_prof_by_uid(Uid)),
		ItemList = [{T, N} || {T, N, _} <- ItemList1],
		NewRec = Rec#usr_maze{
			rewards = util_list:add_and_merge_list(Rec#usr_maze.rewards, ItemList, 1, 2)
		},
		set_data(NewRec),
		fun_item_api:send_show_fetched_reward(Uid, Sid, ?SHOW_REWARD_COMMON, ItemList),
		send_info_to_client(Uid, Sid, Seq)
	end,
	fun_item_api:check_and_add_items(Uid, Sid, SpendItems, [], Succ, undefined).

do_badage_event(Uid, Sid, Seq, Id, Rec) ->
	#st_maze_event{box = Box} = data_maze_event:get_data(Id),
	case Rec#usr_maze.bagdge >= Box of
		true -> skip;
		_ ->
			NewRec = Rec#usr_maze{
				bagdge = Box
			},
			set_data(NewRec),
			send_info_to_client(Uid, Sid, Seq)
	end.

do_instrusion_event(Uid, _Sid, _Seq, _Id, _Rec) ->
	case get(intrusion_info) of
		{TargetUid, TargetServerId} ->
			?debug("Info = ~p~n",[get(intrusion_info)]),
			put(scene_info, instrusion),
			Msg = {find_intrusion_info_target_server, instrusion, Uid, TargetUid, TargetServerId},
			gen_server:cast({global, global_client}, Msg),
			erase(intrusion_info);
		_ -> skip
	end.

get_intrusion_info_to_target_server({Type, FromUid, FromServerId, Uid, ServerId}) ->
	Msg = case db:dirty_get(usr_maze, Uid, #usr_maze.uid) of
		[#usr_maze{inspare = Inspare, status = Status, rewards = List}] ->
			case Status of
				?IN_MAZE ->
					Rewards = util:string_to_term(util:to_list(List)),
					{find_intrusion_arena_result, ok, Type, FromUid, FromServerId, {Uid, util:get_name_by_uid(Uid), ServerId, fun_arena:get_ply_data(Uid), Rewards, Inspare}};
				_ -> {find_intrusion_arena_result, error, Type, FromUid, FromServerId, {}}
			end;
		_ ->
			case db:get_usr_maze(Uid, ?TRUE) of
				[#usr_maze{inspare = Inspare, status = Status, rewards = List}] ->
					case Status of
						?IN_MAZE ->
							Rewards = util:string_to_term(util:to_list(List)),
							{find_intrusion_arena_result, ok, Type, FromUid, FromServerId, {Uid, util:get_name_by_uid(Uid), ServerId, fun_arena:get_ply_data(Uid), Rewards, Inspare}};
						_ -> {find_intrusion_arena_result, error, Type, FromUid, FromServerId, {}}
					end;
				_ -> {find_intrusion_arena_result, error, Type, FromUid, FromServerId, {}}
			end
	end,
	gen_server:cast({global, global_client}, Msg).

get_intrusion_fight_info_result({Result, Type, Uid, Data}) ->
	case db:dirty_get(ply, Uid) of
		[#ply{sid = Sid}] ->
			case Result of
				ok ->
					{TargetUid, Name, TargetServerId, {Robot,EntourageData},Rewards,TargetInspare} = Data,
					case data_scene_config:get_scene(?COMPLEX_ARENA_SCENE) of
						#st_scene_config{sort=?SCENE_SORT_COMPLEX_ARENA,points = PointList} ->
							Rec = get_data(Uid),
							Inspare = Rec#usr_maze.inspare,
							fun_arena:save_usr_pos(Uid),
							UsrInfoList=[{Uid,0,lists:nth(2, PointList),#ply_scene_data{sid = Sid}}],
							SceneData={complex_arena_scene,Type,{TargetUid,Name,TargetServerId,Robot,EntourageData,Rewards,Inspare,TargetInspare},lists:nth(3, PointList)},
							gen_server:cast({global, scene_mng}, {start_fly, UsrInfoList, ?COMPLEX_ARENA_SCENE, SceneData});
						_ -> skip
					end;
				_ -> ?error_report(Sid, "maze02")
			end;
		_ -> skip
	end.

on_complex_arena_result({Result, Uid, Type, Data, Time}) ->
	case db:dirty_get(ply, Uid) of
		[#ply{sid = Sid, agent_hid = Hid}] ->
			ItemList = case Type of
				monster ->
					case Result of
						win ->
							Id = Data,
							#st_maze_event{reward = Rewards} = data_maze_event:get_data(Id),
							mod_msg:handle_to_agent(Hid, ?MODULE, {add_reward, Uid, Sid, Rewards, Id, Time}),
							Rewards;
						_ -> []
					end;
				instrusion ->
					{TargetUid, TargetServerId, Rewards} = Data,
					{Lost, NewReward} = case Result of
						win ->
							{GetList, LostList} = get_rewards_list(Rewards, (util:get_data_para_num(1184) / 100)),
							mod_msg:handle_to_agent(Hid, ?MODULE, {add_instrusion_reward, Uid, Sid, GetList}),
							{GetList, LostList};
						_ ->
							send_info_to_client(Uid, Sid, 0),
							{[], Rewards}
					end,
					Msg = {send_maze_fight_result, TargetUid, TargetServerId, {Uid, util:get_name_by_uid(Uid), db:get_all_config(serverid), db:get_all_config(servername), Type, util_time:unixtime(), Result, Lost, NewReward}},
					gen_server:cast({global, global_client}, Msg),
					Lost;
				revenge ->
					{TargetUid, TargetServerId, Rewards} = Data,
					{Lost, NewReward} = case Result of
						win ->
							{GetList, LostList} = get_rewards_list(Rewards, (util:get_data_para_num(1185) / 100)),
							mod_msg:handle_to_agent(Hid, ?MODULE, {add_revenge_reward, Uid, Sid, GetList, TargetUid}),
							{GetList, LostList};
						_ ->
							mod_msg:handle_to_agent(Hid, ?MODULE, {add_revenge_reward, Uid, Sid, [], TargetUid}),
							{[], Rewards}
					end,
					Msg = {send_maze_fight_result, TargetUid, TargetServerId, {Uid, util:get_name_by_uid(Uid), db:get_all_config(serverid), db:get_all_config(servername), Type, util_time:unixtime(), Result, Lost, NewReward}},
					gen_server:cast({global, global_client}, Msg),
					Lost
			end,
			Result1 = get_result(Result),
			Pt = #pt_global_arena_result{
				type = ?GLOBAL_ARNEA_MAZE,
				win_lose = Result1,
				item_list = fun_item_api:make_item_pt_list(ItemList)
			},
			?send(Sid, proto:pack(Pt));
		_ -> skip
	end.

get_result(Result) ->
	case Result of
		win -> ?ARENA_WIN;
		_ -> ?ARENA_LOSE
	end.

get_my_result(Result) ->
	case Result of
		lose -> ?ARENA_WIN;
		_ -> ?ARENA_LOSE
	end.

get_rewards_list(Rewards, Percent) ->
	Fun = fun({T,N},{Acc1,Acc2}) ->
		Num1 = util:ceil(N * Percent),
		Num2 = N - Num1,
		List1 = [{T, Num1} | Acc1],
		case Num2 == 0 of
			true -> List2 = Acc2;
			_ -> List2 = [{T, Num2} | Acc2]
		end,
		{List1, List2}
	end,
	lists:foldl(Fun, {[], []}, Rewards).

get_maze_fight_result({TargetUid, Data}) ->
	case db:dirty_get(ply, TargetUid) of
		[#ply{sid = Sid, agent_hid = Hid}] -> mod_msg:handle_to_agent(Hid, ?MODULE, {put_maze_data, TargetUid, Sid, Data});
		_ ->
			{Uid, Name, ServerId, ServerName, Type, Time, Result, LostList, NewReward} = Data,
			case db:get_usr_maze(TargetUid, ?TRUE) of
				[Rec = #usr_maze{status = Status, records = List}] ->
					case Status of
						?IN_MAZE ->
							Records = util:string_to_term(util:to_list(List)),
							NewType = case Type of
								instrusion ->
									case Result of
										lose -> ?GUARD_INSTRUSION;
										_ -> ?CAN_REVENGE
									end;
								_ -> ?GUARD_REVENGE
							end,
							NewRecords = [{Uid, Name, ServerId, ServerName, NewType, Time, Result, LostList} | Records],
							NewRec = Rec#usr_maze{
								records = util:term_to_string(NewRecords),
								rewards = util:term_to_string(NewReward)
							},
							db:dirty_put(NewRec);
						_ -> skip
					end;
				_ -> skip
			end
	end.

do_lucky_ranklist(Uid, Lucky, Time) ->
	RankList = case fun_agent_mng:get_global_value(maze_ranklist, []) of
		undefined -> [];
		List -> List
	end,
	NewRankList1 = case lists:keyfind(Uid, 1, RankList) of
		{_, {OldLucky, _}} ->
			case Lucky >= OldLucky of
				true -> lists:keystore(Uid, 1, RankList, {Uid, {Lucky, -Time}});
				_ -> RankList
			end;
		_ -> lists:keystore(Uid, 1, RankList, {Uid, {Lucky, -Time}})
	end,
	NewRankList = lists:sublist(lists:reverse(lists:keysort(2, NewRankList1)), 20),
	fun_agent_mng:set_global_value(maze_ranklist, NewRankList).

send_ranklist(_Now) ->
	case util_time:weekday() of
		1 ->
			Fun = fun({Uid, _}, Acc) ->
				case data_maze:get_ranklist(Acc) of
					{_, Rewards} ->
						#mail_content{mailName = Title, text = Content} = data_mail:data_mail(maze_award),
						Content2 = util:format_lang(util:to_binary(Content), [Acc]),
						mod_mail_new:sys_send_personal_mail(Uid, Title, Content2, Rewards, ?MAIL_TIME_LEN);
					_ -> skip
				end,
				Acc + 1
			end,
			lists:foldl(Fun, 1, fun_agent_mng:get_global_value(maze_ranklist, [])),
			[del_data(Rec) || Rec <- db:dirty_match(usr_maze, #usr_maze{_='_'})],
			fun_agent_mng:set_global_value(maze_ranklist, []);
		_ -> skip
	end.

make_ranklist_pt([], _Uid, Acc1, Acc2, Acc3, _Acc4) -> {Acc1, Acc2, Acc3};
make_ranklist_pt([{TUid, {Lucky, _}} | Rest], Uid, Acc1, Acc2, Acc3, Acc4) ->
	Pt = #pt_public_maze_ranklist{
		name  = util:to_list(util:get_name_by_uid(TUid)),
		lucky = Lucky,
		rank  = Acc4
	},
	case Uid == TUid of
		true -> make_ranklist_pt(Rest, Uid, Acc4, Lucky, [Pt | Acc3], Acc4 + 1);
		_ -> make_ranklist_pt(Rest, Uid, Acc1, Acc2, [Pt | Acc3], Acc4 + 1)
	end.

del_data(Rec = #usr_maze{}) ->
	NewRec = Rec#usr_maze{
		status 			= ?OUT_MAZE,
		has_settled 	= 0,
		lucky 			= 0,
		bagdge 			= 0,
		inspare 		= 0,
		step	 		= 0,
		monster_record  = [],
		rewards 		= [],
		records 		= []
	},
	set_data(NewRec).