%% @doc 活动副本，包含：金币挑战、勇者挑战、英雄挑战
-module (fun_activity_copy).
-include("common.hrl").
-export ([
	req_copy_times/3, req_copy_enter/4, req_fast_copy/5, refresh_times/1,
	req_buy_times/4, req_active_copy/4, handle/1, req_set_on_battles/5
]).

-define (DEFAULT_TIMES, 3).

%% ================================= 数据操作 ==================================
get_data(Uid) -> 
	case mod_role_tab:lookup(Uid, t_activity_copy) of
		[] -> #t_activity_copy{uid = Uid};
		[Rec] -> Rec
	end.

set_data(Uid, Rec) ->
	mod_role_tab:insert(Uid, Rec).

get_copy_maps(Uid, CopyType) ->
	Rec = get_data(Uid),
	case lists:keyfind(CopyType, 1, Rec#t_activity_copy.datas) of
		false -> #{};
		{_, Maps} -> Maps 
	end.

set_copy_maps(Uid, CopyType, Maps) ->
	Rec = get_data(Uid),
	Rec2 = Rec#t_activity_copy{
		datas = lists:keystore(CopyType, 1, Rec#t_activity_copy.datas, {CopyType, Maps})
	},
	set_data(Uid, Rec2).
%% ================================= 数据操作 ==================================

get_left_times(CopyType, Maps) -> 
	case maps:get(left_times, Maps, undefined) of
		undefined -> 
			data_activity_copy:get_free_times(CopyType);
		T -> T
	end.

refresh_times(Uid) -> 
	Rec = get_data(Uid),
	Fun = fun({CopyType, Maps}) ->
		Maps2 = Maps#{
			left_times => max(?DEFAULT_TIMES, get_left_times(CopyType, Maps)),
			buy_times => 0
		},
		{CopyType, Maps2}
	end,
	List = [Fun(M) || M <- Rec#t_activity_copy.datas],
	set_data(Uid, Rec#t_activity_copy{datas = List}).


req_copy_times(Uid, Sid, Seq) ->
	Fun = fun(CopyType) ->
		Maps = get_copy_maps(Uid, CopyType),
		#pt_public_act_copy{
			copy_type = CopyType,
			activated_copy_id = get_activated_copy_id(CopyType, Maps),
			win_copy_id = maps:get(win_copy_id, Maps, 0),
			left_times = get_left_times(CopyType, Maps),
			buy_times = maps:get(buy_times, Maps, 0),
			max_kill_num = maps:get(max_kill_num, Maps, 0)
		}
	end,
	List = [Fun(T) || T <- ?ALL_ACT_COPYS],
	Pt = #pt_act_copy_info{datas = List},
	?send(Sid, proto:pack(Pt, Seq)).


req_copy_enter(Uid, Sid, Seq, CopyId) ->
	case check_enter(Uid, CopyId) of
		{error, Reason} -> ?error_report(Sid, Reason);
		{ok, CopyType, Scene} ->
			case CopyType of
				1 -> fun_count:on_count_event(Uid, Sid, ?TASK_COPY_ONE, 0, 1);
				2 -> fun_count:on_count_event(Uid, Sid, ?TASK_COPY_TWE, 0, 1);
				3 -> fun_count:on_count_event(Uid, Sid, ?TASK_COPY_THREE, 0, 1);
				_ -> skip
			end,
			mod_scene_api:enter_activity_copy(Uid, Sid, Seq, CopyId, Scene)
	end.


check_enter(Uid, CopyId) ->
	#st_activity_copy{
		type    = CopyType, 
		need_lv = NeedLv, 
		scene   = Scene
	} = data_activity_copy:get_copy(CopyId),
	Maps = get_copy_maps(Uid, CopyType),
	case get_left_times(CopyType, Maps) > 0 of
		true -> 
			case get_activated_copy_id(CopyType, Maps) >= CopyId of
				true -> 
					case util:get_lev_by_uid(Uid) >= NeedLv of
						true -> {ok, CopyType, Scene};
						_ -> {error, "error_common_lv_not_match"}
					end;
				_ -> {error, "error_copy_not_activated"}
			end;
		_ -> 
			{error, "error_no_enter_times"}
	end.


get_activated_copy_id(CopyType, Maps) ->
	case maps:get(activated_copy_id, Maps, 0) of
		0 -> 
			data_activity_copy:get_first_copy(CopyType);
		ActivatedCopyId -> 
			ActivatedCopyId
	end.


req_fast_copy(Uid, Sid, Seq, CopyId, _) ->
	case check_sweep(Uid, CopyId) of
		{error, Reason} -> ?error_report(Sid, Reason);
		{ok, Reward, Maps, CopyType} -> 
			Succ = fun() -> 
				Maps2 = Maps#{
					left_times => get_left_times(CopyType, Maps) - 1
				},
				set_copy_maps(Uid, CopyType, Maps2),
				req_copy_times(Uid, Sid, Seq),
				fun_item_api:send_show_fetched_reward(Uid, Sid, ?SHOW_REWARD_COMMON, Reward)
			end,
			Args = #api_item_args{
				way      = ?ITEM_WAY_FAST_COPY,
				add      = Reward,
				succ_fun = Succ
			},
			fun_item_api:add_items(Uid, Sid, Seq, Args)
	end.

check_sweep(Uid, CopyId) ->
	#st_activity_copy{type = CopyType} = data_activity_copy:get_copy(CopyId),
	Maps = get_copy_maps(Uid, CopyType),
	Reward = maps:get(best_rewards, Maps, []),
	case Reward /= [] of
		true -> 
			case get_left_times(CopyType, Maps) > 0 of
				true ->
					{ok, Reward, Maps, CopyType};
				_ -> 
					{error, "error_no_enter_times"}
			end;
		_ -> {error, "error_need_win_copy"}
	end.


req_buy_times(Uid, Sid, Seq, CopyId) ->
	case check_buy_times(Uid, CopyId) of
		{error, Reason} -> ?error_report(Sid, Reason);
		{ok, CopyType, Maps, Costs}  -> 
			Succ = fun() -> 
				Maps2 = Maps#{
					buy_times => maps:get(buy_times, Maps, 0) + 1,
					left_times => get_left_times(CopyType, Maps) + 1
				},
				set_copy_maps(Uid, CopyType, Maps2),
				req_copy_times(Uid, Sid, Seq)
			end,
			Args = #api_item_args{
				way      = ?ITEM_WAY_BUY_COPY_TIMES,
				spend    = Costs,
				succ_fun = Succ
			},
			fun_item_api:add_items(Uid, Sid, Seq, Args)
	end.

check_buy_times(Uid, CopyId) ->
	#st_activity_copy{type = CopyType} = data_activity_copy:get_copy(CopyId),
	Maps = get_copy_maps(Uid, CopyType),
	BuyTimes = maps:get(buy_times, Maps, 0),
	case BuyTimes > 10 of
		true -> {error, "error_no_buy_times"};
		_ -> 
			BuyType = case CopyType of
				?ACT_COPY_COIN -> ?BUY_ACT_COPY_COIN;
				?ACT_COPY_WARRIOR -> ?BUY_ACT_COPY_WARRIOR;
				?ACT_COPY_HERO -> ?BUY_ACT_COPY_HERO
			end,
			BuyTimes2 = min(BuyTimes, data_buy_time_price:get_max_times(BuyType)),
			#st_buy_time_price{cost = Costs} = data_buy_time_price:get_data(BuyType, BuyTimes2),
			{ok, CopyType, Maps, Costs} 
	end.


req_active_copy(Uid, Sid, Seq, CopyId) ->
	#st_activity_copy{type = CopyType, need_lv = NeedLv} = data_activity_copy:get_copy(CopyId),
	Maps = get_copy_maps(Uid, CopyType),
	WinCopyId = maps:get(win_copy_id, Maps, 0),
	case CopyId == WinCopyId + 1 of
		true -> 
			case util:get_lev_by_uid(Uid) >= NeedLv of
				true -> 
					Maps2 = Maps#{
						activated_copy_id => CopyId,
						max_kill_num => 0,
						best_rewards => []
					},
					set_copy_maps(Uid, CopyType, Maps2),
					req_copy_times(Uid, Sid, Seq);
				_ -> 
					?ERROR("Lv not match, cannot active")
			end;
		_ -> 
			?ERROR("Client send wrong copy id:~p, win_copy_id:WinCopyId", [CopyId, WinCopyId])
	end.


req_set_on_battles(Uid, Sid, Seq, EntourageList, ShenqiId) -> 
	EntourageList2 = util_entourage:make_entourage_list(Uid, EntourageList),
	mod_entourage_data:set_entourage_data(Uid, EntourageList2, ShenqiId, ?ON_BATTLE_ACT_COPY),
	mod_entourage_data:send_on_battle_heros(Uid, Sid, Seq, ?ON_BATTLE_ACT_COPY).


%% from scene
%% 副本胜利结算
handle({copy_result, Result, CopyId, AddItems, KillNum}) ->
	Uid = get(uid),
	Sid = get(sid),
	Succ = fun() -> 
		#st_activity_copy{type = CopyType} = data_activity_copy:get_copy(CopyId),
		Maps = get_copy_maps(Uid, CopyType),
		OldReward = maps:get(best_rewards, Maps, []),
		NewReward = case is_reward_better(AddItems, OldReward) of
			true -> AddItems;
			_    -> OldReward
		end,
		NewWinCopyId = case Result of
			?COPY_LOSE -> maps:get(win_copy_id, Maps, 0);
			?COPY_WIN -> max(CopyId, maps:get(win_copy_id, Maps, 0))
		end,

		Maps2 = Maps#{
			left_times   => get_left_times(CopyType, Maps) - 1,
			win_copy_id  => NewWinCopyId,
			max_kill_num => max(KillNum, maps:get(max_kill_num, Maps, 0)),
			best_rewards => NewReward
		},
		set_copy_maps(Uid, CopyType, Maps2),
		req_copy_times(Uid, Sid, 0)
	end,
	Args = #api_item_args{
		way      = ?ITEM_WAY_COPY_RESULT,
		add      = AddItems,
		succ_fun = Succ
	},
	fun_item_api:add_items(Uid, Sid, 0, Args).


is_reward_better(Reward1, Reward2) ->
	S1 = lists:sum([N || {_, N} <- Reward1]),
	S2 = lists:sum([N || {_, N} <- Reward2]),
	S1 > S2.
