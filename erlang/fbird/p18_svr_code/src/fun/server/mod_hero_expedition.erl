%% @doc 英雄远征
-module (mod_hero_expedition).
-include("common.hrl").
-export([init/0, handle_call/1, handle_msg/1, terminate/0, do_loop/1]).
-export ([
	req_info/3, req_set_on_battles/5, req_do_event/3, req_enter/3, 
	req_give_up_event/3, req_unlock_next_pos/4, handle/1, get_left_hp_rate/2
]).
-export([test_reset/0]).

%% =============================== 全局服务进程 ================================
init() -> 
	do_setup_timer(),
	ok.

do_setup_timer() ->
	case is_in_open_time() of
		{true, NextCloseSecs} -> 
			case util_server:get_share_data(hero_expedition_events, undefined) of
				undefined -> 
					before_open(),
					erlang:send(self(), do_open);
				_ -> skip
			end,
			erlang:send_after((NextCloseSecs + 60) * 1000, self(), do_close);
		{false, NextOpenSecs, NextCloseSecs} -> 
			case NextOpenSecs < 60 of
				true -> 
					before_open();
				false -> 
					erlang:send_after((NextOpenSecs - 60) * 1000, self(), before_open)
			end,
			erlang:send_after(NextOpenSecs * 1000, self(), do_open),
			erlang:send_after((NextCloseSecs + 60) * 1000, self(), do_close)
	end.

before_open() ->
	Events = rand_events(),
	util_server:set_share_data(hero_expedition_events, Events),
	%% 开始之前清理掉数据
	db_api:dirty_delete_all_object(t_role_expedition),
	ok.

is_in_open_time() ->
	{OpenWeeks, _} = data_sys_open:get_open_time(7),
	{BeginWeekDay, EndWeekDay} = hd(OpenWeeks),
	OpenWeeks2 = OpenWeeks ++ [{BeginWeekDay + 7, EndWeekDay + 7}],
	WeekDay = util_time:weekday(),
	CurTime = erlang:time(),
	is_in_open_time(WeekDay, CurTime, OpenWeeks2).

is_in_open_time(WeekDay, CurTime, [{BeginWeekDay, EndWeekDay} | Rest]) ->
	if 
		WeekDay < BeginWeekDay -> 
			NextOpenSecs = (BeginWeekDay - WeekDay) * ?ONE_DAY_SECONDS - calendar:time_to_seconds(CurTime),
			NextCloseSecs = NextOpenSecs + (EndWeekDay - BeginWeekDay) * ?ONE_DAY_SECONDS,
			{false, NextOpenSecs, NextCloseSecs};
		WeekDay >= BeginWeekDay andalso WeekDay =< EndWeekDay ->
			NextCloseSecs = (EndWeekDay - WeekDay + 1) * ?ONE_DAY_SECONDS - calendar:time_to_seconds(CurTime),
			{true, NextCloseSecs};
		true ->
			is_in_open_time(WeekDay, CurTime, Rest)
	end.
% is_in_open_time(WeekDay, CurTime, []) -> ok. 按实现方式不会走到这里的

rand_events() ->
	PosList = data_hero_expedition:get_all_pos(),
	rand_events(PosList, []).

rand_events([Pos | Rest], Acc) ->
	{EventId, _} = util_list:random_from_tuple_weights(data_hero_expedition:get_pos_event_ids(Pos), 2),
	rand_events(Rest, [{Pos, EventId} | Acc]);
rand_events([], Acc) -> 
	lists:reverse(Acc).

handle_call(Request) ->
	?ERROR("~p recieve call:~p, but not handled!", [?MODULE, Request]),
	not_handled.

handle_msg(before_open) -> 
	before_open();

handle_msg(do_open) -> 
	ok;

handle_msg(do_close) -> 
	%% 清理数据
	util_server:set_share_data(hero_expedition_events, undefined),
	AllUidList = db_api:dirty_all_keys(usr),
	[begin 
		mod_entourage_data:clear_entourage_data(Uid, ?ON_BATTLE_EXPEDITION),
		delete_data(Uid)
	 end || Uid <- AllUidList],
	util_server:broadcast_msg_to_online_usr_process({handle_msg,?MODULE,do_close}),
	do_setup_timer();

handle_msg(Msg) ->
	?ERROR("~p recieve msg:~p, but not handled!", [?MODULE, Msg]),
	ok.

terminate() -> 
	ok.


do_loop(_Now) ->
	ok.


is_open() -> 
	util_server:get_share_data(hero_expedition_events, undefined) /= undefined.

get_pos_event_id(Pos) -> 
	List = util_server:get_share_data(hero_expedition_events, undefined),
	{_, EventId} = lists:keyfind(Pos, 1, List),
	EventId.


test_reset() -> 
	util_server:set_share_data(hero_expedition_events, undefined),
	db_api:dirty_delete_all_object(t_role_expedition),
	ok.

%% =============================== 全局服务进程 ================================
%% =============================================================================

%% =============================================================================
%% =============================== 玩家进程逻辑 ================================

%% ============================== 玩家数据操作 =================================
get_data(Uid) -> 
	case mod_role_tab:lookup(Uid, t_role_expedition) of
		[] -> undefined;
		[Rec] -> Rec
	end.

set_data(Uid, Rec) ->
	mod_role_tab:insert(Uid, Rec).

delete_data(Uid) ->
	case mod_role_tab:lookup(Uid, t_role_expedition) of
		[] -> skip;
		[Rec] -> 
			mod_role_tab:delete(Uid, Rec)
	end.


init_data(Uid) ->
	Pos = hd(data_hero_expedition:get_all_pos()),
	Rec = #t_role_expedition{
		uid = Uid,
		datas = rand_pos_event(Pos, #{walked_pos_list => []})
	},
	set_data(Uid, Rec),
	Rec.
%% ============================== 玩家数据操作 =================================
rand_pos_event(Pos, Maps) -> 
	MainEventId = get_pos_event_id(Pos),
	MainEventData = rand_main_event_data(MainEventId),
	SubEvent = 1, %% 目前只固定为宝物
	case data_hero_expedition:get_rand_treasure(Pos) of
		[] -> 
			SubEventData = undefined,
			SubEventState = ?EVENT_STATE_FINISHED;
		List ->
			{TreasureId, _} = util_list:random_from_tuple_weights(List, 2),
			SubEventData = lists:keyfind(TreasureId, 1, data_hero_expedition:get_box_event()),
			SubEventState = ?EVENT_STATE_DOING
	end,
	Maps#{
		pos => Pos,
		main_event => MainEventId,
		main_event_data => MainEventData,
		main_event_state => ?EVENT_STATE_DOING,
		sub_event => SubEvent,
		sub_event_data => SubEventData,
		sub_event_state => SubEventState
	}.

rand_main_event_data(MainEventId) ->
	List = case data_hero_expedition:get_event_type(MainEventId) of
		?EXPEDTION_EVENT_FIGHTING -> 
			data_hero_expedition:get_boss_event();
		?EXPEDTION_EVENT_STORE -> 
			data_hero_expedition:get_store_event();
		?EXPEDTION_EVENT_REST -> 
			data_hero_expedition:get_rest_event();
		?EXPEDTION_EVENT_KEY -> 
			data_hero_expedition:get_key_event()
	end,
	util_list:rand(List).

get_event_data_for_client(undefined) -> 0;
get_event_data_for_client(EventsData) ->
	element(1, EventsData). 


make_pos_pt_list(WalkedList) ->
	List = util_server:get_share_data(hero_expedition_events, []),
	[#pt_public_expedition_pos{
		pos = Pos, 
		event_id = EventId, 
		walked = ?_IF(lists:member(Pos, WalkedList), 1, 0)
	 } || {Pos, EventId} <- List].

make_history_sub_events_pt_list(List) -> 
	List2 = util_list:add_and_merge_list([], [{E, 1} || E <- List], 1, 2),
	[#pt_public_expedition_sub_event{event_id = EventId, num = N} || {EventId, N} <- List2].


req_info(Uid, Sid, Seq) -> 
	case check_info(Uid) of
		{error, Reason} -> ?error_report(Sid, Reason, Seq);
		Rec ->
			Pt = #pt_hero_expedition_info{
				pos                = maps:get(pos, Rec#t_role_expedition.datas),
				main_event         = maps:get(main_event, Rec#t_role_expedition.datas),
				main_event_data    = get_event_data_for_client(maps:get(main_event_data, Rec#t_role_expedition.datas)),
				main_event_state   = maps:get(main_event_state, Rec#t_role_expedition.datas),
				sub_event          = maps:get(sub_event, Rec#t_role_expedition.datas),
				sub_event_data     = get_event_data_for_client(maps:get(sub_event_data, Rec#t_role_expedition.datas)),
				sub_event_state    = maps:get(sub_event_state, Rec#t_role_expedition.datas),
				pos_list           = make_pos_pt_list(maps:get(walked_pos_list, Rec#t_role_expedition.datas, [])),
				history_sub_events = make_history_sub_events_pt_list(maps:get(history_sub_events, Rec#t_role_expedition.datas, []))
			},
			?send(Sid, proto:pack(Pt, Seq))
	end.

check_info(Uid) ->
	case get_data(Uid) of
		undefined -> 
			case is_open() of
				true -> %% 第一次初始化
					init_data(Uid);
				false -> 
					{error, "error_act_not_open"}
			end;
		Rec -> Rec
	end.

req_enter(Uid, Sid, Seq) -> 
	case check_info(Uid) of 
		{error, Reason} -> ?error_report(Sid, Reason, Seq);
		Rec -> 
			InScenePos = data_hero_expedition:get_scene_pos(maps:get(pos, Rec#t_role_expedition.datas)),
			Scene = data_hero_expedition:get_scene(),
			fun_count:on_count_event(Uid, Sid, ?TASK_EXPEDITION, 0, 1),
			mod_scene_api:enter_hero_expedition(Uid, Sid, Seq, Scene, InScenePos)
	end.

req_set_on_battles(Uid, Sid, Seq, EntourageList, ShenqiId) -> 
	EntourageList2 = util_entourage:make_entourage_list(Uid, EntourageList),
	mod_entourage_data:set_entourage_data(Uid, EntourageList2, ShenqiId, ?ON_BATTLE_EXPEDITION),
	mod_entourage_data:send_on_battle_heros(Uid, Sid, Seq, ?ON_BATTLE_EXPEDITION).

req_unlock_next_pos(Uid, Sid, Seq, NextPos) ->
	Rec = get_data(Uid),
	Maps = Rec#t_role_expedition.datas,
	Pos = maps:get(pos, Rec#t_role_expedition.datas, 0),
	case lists:member(NextPos, data_hero_expedition:get_next_pos(Pos)) of
		true -> 
			Maps2 = rand_pos_event(NextPos, Maps),
			Maps3 = Maps2#{
				walked_pos_list => [Pos | maps:get(walked_pos_list, Maps2, [])]
			},
			set_data(Uid, Rec#t_role_expedition{datas = Maps3}),
			req_info(Uid, Sid, Seq),
			InScenePos = data_hero_expedition:get_scene_pos(NextPos),
			fun_agent:handle_to_scene(fun_scene_hero_expedition, {move, Uid, InScenePos});
		_ -> skip
	end.

req_give_up_event(Uid, Sid, Seq) ->
	Rec = get_data(Uid),
	MainEventId = maps:get(main_event, Rec#t_role_expedition.datas, 0),
	EventType = data_hero_expedition:get_event_type(MainEventId),
	Maps = Rec#t_role_expedition.datas,
	case maps:get(main_event_state, Maps, 0) /= ?EVENT_STATE_FINISHED 
		 andalso EventType == ?EXPEDTION_EVENT_STORE of
		true -> 
			Maps2 = Maps#{
				main_event_state => ?EVENT_STATE_FINISHED
			},
			set_data(Uid, Rec#t_role_expedition{datas = Maps2});
		false -> 
			case maps:get(sub_event_state, Maps, 0) /= ?EVENT_STATE_FINISHED of
				true ->
					Maps2 = Maps#{
						sub_event_state => ?EVENT_STATE_FINISHED
					},
					set_data(Uid, Rec#t_role_expedition{datas = Maps2});
				_ -> skip
			end
	end,
	?send(Sid, proto:pack(#pt_hero_expedition_succ{}, Seq)),
	req_info(Uid, Sid, Seq).


req_do_event(Uid, Sid, Seq) ->
	Rec = get_data(Uid),
	case is_all_finished(Rec#t_role_expedition.datas) of
		true -> 
			?error_report(Sid, "check_data_error", Seq);
		_ ->
			case is_all_hero_die(maps:get(saved_hp_list, Rec#t_role_expedition.datas, [])) of
				true -> 
					?error_report(Sid, "error_all_heor_die", Seq);
				_ -> 
					case maps:get(main_event_state, Rec#t_role_expedition.datas, 0) of
						?EVENT_STATE_FINISHED -> 
							do_sub_event(Uid, Sid, Seq, Rec);
						_ -> 
							MainEventId = maps:get(main_event, Rec#t_role_expedition.datas, 0),
							EventType = data_hero_expedition:get_event_type(MainEventId),
							do_event(Uid, Sid, Seq, Rec, MainEventId, EventType)
					end
			end
	end.

is_all_hero_die([]) -> false;
is_all_hero_die(SavedHpList) -> 
	lists:sum([H || {_, H} <- SavedHpList]) == 0.

do_sub_event(Uid, Sid, Seq, Rec) ->
	Maps = Rec#t_role_expedition.datas,
	{SubEventId, Buffs} = maps:get(sub_event_data, Maps),
	Maps2 = Maps#{
		sub_event_state => ?EVENT_STATE_FINISHED,
		history_sub_events => [SubEventId | maps:get(history_sub_events, Rec#t_role_expedition.datas, [])]
	},
	set_data(Uid, Rec#t_role_expedition{datas = Maps2}),
	fun_agent:handle_to_scene(fun_scene_hero_expedition, {add_buff, Uid, Buffs}),
	req_info(Uid, Sid, Seq).


get_defender_by_rank(Rank) ->
	MaxRank = db_api:size(?T_RANK_ARENA),
	Rank2 = ?_IF(Rank > MaxRank, MaxRank, Rank),
	#ranklist_arena{uid = Uid} = mod_rank_service:get_data_by_rank(?T_RANK_ARENA, Rank2),
	Uid.


do_event(_Uid, Sid, Seq, Rec, MainEventId, ?EXPEDTION_EVENT_FIGHTING) ->
	{FromRank, ToRank} = data_hero_expedition:get_defender_rank(MainEventId),
	Rank = util:rand(FromRank, ToRank),
	{_, ChallObjData} = util_pk:get_robot_data(get_defender_by_rank(Rank)),
	{_, AttrAdd, Rewards} = maps:get(main_event_data, Rec#t_role_expedition.datas),
	fun_agent:handle_to_scene(fun_scene_hero_expedition, {begin_fight, ChallObjData, {all,AttrAdd}, Rewards}),
	?send(Sid, proto:pack(#pt_hero_expedition_succ{}, Seq));

do_event(Uid, Sid, Seq, Rec, _MainEventId, ?EXPEDTION_EVENT_STORE) -> 
	{_, Item, Costs} = maps:get(main_event_data, Rec#t_role_expedition.datas),
	Succ = fun() -> 
		Maps = Rec#t_role_expedition.datas,
		Maps2 = Maps#{
			main_event_state => ?EVENT_STATE_FINISHED
		},
		set_data(Uid, Rec#t_role_expedition{datas = Maps2}),
		?send(Sid, proto:pack(#pt_hero_expedition_succ{}, Seq)),
		req_info(Uid, Sid, Seq)
	end,
	Args = #api_item_args{
		way      = ?ITEM_WAY_EXPEDITION,
		add      = [{Item, 1}],
		spend    = Costs,
		succ_fun = Succ
	},
	fun_item_api:add_items(Uid, Sid, Seq, Args);

do_event(Uid, Sid, Seq, Rec, _MainEventId, ?EXPEDTION_EVENT_REST) -> 
	{_, AddRate} = maps:get(main_event_data, Rec#t_role_expedition.datas),
	Maps = Rec#t_role_expedition.datas,
	Maps2 = Maps#{
		main_event_state => ?EVENT_STATE_FINISHED,
		saved_hp_list => [{Id, ?_IF(LeftRate > 0, LeftRate + AddRate, 0)} || {Id, LeftRate} <- maps:get(saved_hp_list, Maps, [])]
	},
	set_data(Uid, Rec#t_role_expedition{datas = Maps2}),
	?send(Sid, proto:pack(#pt_hero_expedition_succ{}, Seq)),
	req_info(Uid, Sid, Seq);

do_event(Uid, Sid, Seq, Rec, _MainEventId, ?EXPEDTION_EVENT_KEY) -> 
	{_, AddItems} = maps:get(main_event_data, Rec#t_role_expedition.datas),
	Succ = fun() -> 
		Maps = Rec#t_role_expedition.datas,
		Maps2 = Maps#{
			main_event_state => ?EVENT_STATE_FINISHED
		},
		set_data(Uid, Rec#t_role_expedition{datas = Maps2}),
		?send(Sid, proto:pack(#pt_hero_expedition_succ{}, Seq)),
		req_info(Uid, Sid, Seq)
	end,
	Args = #api_item_args{
		way      = ?ITEM_WAY_EXPEDITION,
		add      = AddItems,
		succ_fun = Succ
	},
	fun_item_api:add_items(Uid, Sid, Seq, Args).


is_all_finished(MapsData) -> 
	maps:get(pos, MapsData, 0) == data_hero_expedition:max_pos() andalso
	maps:get(main_event_state, MapsData, 0) == ?EVENT_STATE_FINISHED andalso
	maps:get(sub_event_state, MapsData, 0) == ?EVENT_STATE_FINISHED.


get_sub_events_buffs([SubEvent | Rest], Acc) -> 
	Acc2 = case lists:keyfind(SubEvent, 1, data_hero_expedition:get_box_event()) of
		false -> Acc;
		{_, Buffs} -> Buffs ++ Acc
	end,
	get_sub_events_buffs(Rest, Acc2);
get_sub_events_buffs([], Acc) -> 
	Acc. 

%% agent消息
handle({entered_scene}) -> 
	Uid = get(uid),
	Sid = get(sid),
	Rec = get_data(Uid),
	Maps = Rec#t_role_expedition.datas,
	Pt = #pt_hero_expedition_hero_hp{
		list = [#pt_public_left_hp{oid = Oid, hp = LeftRate} || {Oid,LeftRate} <- maps:get(saved_hp_list, Maps, [])]
	},
	?send(Sid, proto:pack(Pt)),

	SubEventIds = maps:get(history_sub_events, Maps, []),
	Buffs = get_sub_events_buffs(SubEventIds, []),
	fun_agent:handle_to_scene(fun_scene_hero_expedition, {add_buff, Uid, Buffs}),
	ok;

handle({entourage_die, Eid}) -> 
	Uid = get(uid),
	Rec = get_data(Uid),
	Maps = Rec#t_role_expedition.datas,
	SavedHpList = maps:get(saved_hp_list, Maps, []),
	SavedHpList2 = lists:keystore(Eid, 1, SavedHpList, {Eid, 0}), 
	Maps2 = Maps#{
		saved_hp_list => SavedHpList2
	},
	set_data(Uid, Rec#t_role_expedition{datas = Maps2});

handle(do_close) ->
	Uid = get(uid),
	fun_agent:handle_to_scene(fun_scene_hero_expedition, {do_close, Uid});

handle(manual_kick_out) ->
	mod_scene_lev:req_copy_out(get(uid), get(sid), 0);

handle({copy_result, Result, AddItems, LeftHpRateList}) ->
	Uid = get(uid),
	Sid = get(sid),
	Rec = get_data(Uid),
	Maps = Rec#t_role_expedition.datas,
	MainEventId = maps:get(main_event, Rec#t_role_expedition.datas),
	EventType = data_hero_expedition:get_event_type(MainEventId),
	case EventType of
		?EXPEDTION_EVENT_FIGHTING -> 
			case Result of
				?COPY_WIN -> 
					Maps2 = Maps#{
						main_event_state => ?EVENT_STATE_FINISHED,
						saved_hp_list => save_left_hp(LeftHpRateList, maps:get(saved_hp_list, Maps, []))
					},
					set_data(Uid, Rec#t_role_expedition{datas = Maps2}),
					Args = #api_item_args{
						way = ?ITEM_WAY_EXPEDITION,
						add = AddItems
					},
					fun_item_api:add_items(Uid, Sid, 0, Args);
				_ -> 
					Maps2 = Maps#{
						saved_hp_list => save_left_hp(LeftHpRateList, maps:get(saved_hp_list, Maps, []))
					},
					set_data(Uid, Rec#t_role_expedition{datas = Maps2})
			end,
			req_info(Uid, Sid, 0);
		_ -> 
			?ERROR("this should not hanppen! maps:~p", [Maps])
	end,
	ok.


save_left_hp([T = {HeroId, _LeftHpRate} | Rest], Acc) ->
	Acc2 = lists:keystore(HeroId, 1, Acc, T),
	save_left_hp(Rest, Acc2);
save_left_hp([], Acc) -> 
	Acc.


get_left_hp_rate(Uid, HeroItemId) ->
	case check_info(Uid) of
		{error, _} -> 0;
		Rec -> 
			Maps = Rec#t_role_expedition.datas,
			SavedHpList = maps:get(saved_hp_list, Maps, []),
			case lists:keyfind(HeroItemId, 1, SavedHpList) of
				{_, LeftRate} -> 
					LeftRate; 
				_ -> 
					10000
			end
	end.

