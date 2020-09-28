%% 竞技场排行榜及相关功能
-module(mod_arena_ranklist).
-include("common.hrl").
-export([init/0]).
-export([handle/1]).
-export([get_win_point_change/3,get_lose_point_change/2]).
-export([get_rank_by_uid/2,get_value_by_uid/2,get_last_rank/2]).
-export([get_chall_info/2]).
-export([do_send_arena_daily_reward/1,do_send_arena_week_reward/1,do_arena_start/1]).

%% =============================================================================
get_data(Uid) ->
	case db_api:dirty_read(t_last_ranklist, Uid) of
		[] -> #t_last_ranklist{uid = Uid};
		[Rec] -> Rec
	end.

set_data(Rec) ->
	db_api:dirty_write(Rec).

%% =============================================================================

get_ranklist_type(?PERSONAL_ARENA) -> ?T_RANK_ARENA;
get_ranklist_type(_) -> no.

init() ->
	{_, [{StartTime, EndTime}]} = data_sys_open:get_open_time(?PERSONAL_ARENA),
	SH = StartTime div 100,
	SM = StartTime rem 100,
	EH = EndTime div 100,
	EM = EndTime rem 100,
	{HH,MM,_} = util_time:get_now_time(),
	if
		(HH > SH andalso HH < EH) orelse (HH == SH andalso MM >= SM) orelse (HH == EH andalso MM < EM) -> put(personal_arena, 1);
		true -> put(personal_arena, 0)
	end,
	Day1 = util_time:next_day_zero_left_secs() - ((24-EH)*3600),
	Week1 = util_time:next_week_zero_clock_left_secs() - ((24-EH)*3600),
	{Day, Week} = if
		Day1 > 0 ->
			if
				Week1 > 0 -> {Day1, Week1};
				true -> {Day1, Week1 + util_time:one_week_seconds()}
			end;
		true -> 
			if
				Week1 > 0 -> {Day1 + util_time:one_day_seconds(), Week1};
				true -> {Day1 + util_time:one_day_seconds(), Week1 + util_time:one_week_seconds()}
			end
	end,
	srv_loop:add_callback(Day, ?MODULE, do_send_arena_daily_reward, {}),
	srv_loop:add_callback(Week, ?MODULE, do_send_arena_week_reward, {}),
	case db_api:size(?T_RANK_ARENA) == 0 of
		true -> init_ranklist();
		_ -> skip
	end,
	ok.

handle({Uid, ChallUid, UsrChange, ChallChange, Reward, Result}) ->
	mod_rank_service:update_arena(UsrChange, Uid, util:get_name_by_uid(Uid), util:get_lev_by_uid(Uid)),
	case fun_arena:is_robot(ChallUid) of
		true ->
			#st_robot{level = Lev} = data_robot:get_data(ChallUid),
			Name = util_lang:get_robot_name(ChallUid),
			mod_rank_service:update_arena(ChallChange, ChallUid, Name, Lev);
		_ -> mod_rank_service:update_arena(ChallChange, ChallUid, util:get_name_by_uid(ChallUid), util:get_lev_by_uid(ChallUid))
	end,
	Args = #api_item_args{
		way = ?ITEM_WAY_ARENA,
		add = Reward
	},
	fun_arena:arena_end_help(Uid, ChallUid, UsrChange, ChallChange, Result, Args),
	ok;

handle(Msg) -> ?log_error("~p unhandled message:~p", [?MODULE, Msg]).

init_ranklist() ->
	FunRobot = fun(Id) ->
		#st_robot{level = Lev} = data_robot:get_data(Id),
		Name = util_lang:get_robot_name(Id),
		mod_rank_service:update_arena(0, Id, Name, Lev)
	end,
	[FunRobot(Id) || Id <- data_robot:get_all()],
	FunUsr = fun(Uid) ->
		case fun_arena:get_all_on_battled_heros(Uid) of
			EL when length(EL) > 0 ->
				mod_rank_service:update_arena(0, Uid, util:get_name_by_uid(Uid), util:get_lev_by_uid(Uid));
			_ -> skip
		end
	end,
	[FunUsr(Uid) || Uid <-  db_api:dirty_all_keys(t_arena_info)].

do_arena_start(_) ->
	put(personal_arena, 1).

do_send_arena_daily_reward(_) ->
	put(personal_arena, 0),
	Day1 = util_time:next_day_zero_left_secs() - 7200,
	Day = if
		Day1 > 0 -> Day1;
		true -> Day1 + util_time:one_day_seconds()
	end,
	srv_loop:add_callback(Day, ?MODULE, do_send_arena_daily_reward, {}),
	add_daily_reward_to_ranklist(),
	{_, [{StartTime, _}]} = data_sys_open:get_open_time(?PERSONAL_ARENA),
	SH = StartTime div 100,
	SM = StartTime rem 100,
	{HH,MM,_} = util_time:get_now_time(),
	Time = util_time:one_day_seconds() - util_time:diff_secs_by_time({HH,MM,0}, {SH,SM,0}),
	srv_loop:add_callback(Time, ?MODULE, do_arena_start, {}),
	ok.

do_send_arena_week_reward(_) ->
	Week1 = util_time:next_week_zero_clock_left_secs() - 7200,
	Week = if
		Week1 > 0 -> Week1;
		true -> Week1 + util_time:one_week_seconds()
	end,
	srv_loop:add_callback(Week, ?MODULE, do_send_arena_week_reward, {}),
	add_week_reward_to_ranklist(),
	ok.

add_daily_reward_to_ranklist() ->
	Fun=fun(#ranklist_arena{uid = Uid, rank = Rank}) ->
		case fun_arena:is_robot(Uid) of
			true -> skip;
			_ -> add_daily_reward(Uid,Rank)
		end
	end,
	db_api:dirty_map(Fun, ranklist_arena).

add_daily_reward(Uid,Rank) ->
	Reward = data_arena_reward:get_daily_reward(?PERSONAL_ARENA, Rank),
	if
		Reward == [] -> skip;
		true ->	
			{Title, Content} = util_lang:get_mail(3),
			Content2 = util_str:format_string(Content, [Rank]),
			mod_mail_new:sys_send_personal_mail(Uid, Title, Content2, Reward,?MAIL_TIME_LEN)
	end.

add_week_reward_to_ranklist() ->
	Fun=fun(#ranklist_arena{key = {Point, _}, uid = Uid, rank = Rank}) ->
		case fun_arena:is_robot(Uid) of
			true ->
				#st_robot{level = Lev} = data_robot:get_data(Uid),
				Name = util_lang:get_robot_name(Uid),
				set_last_rank(Uid, Rank, ?PERSONAL_ARENA),
				mod_rank_service:update_arena(1000 - Point, Uid, Name, Lev);
			_ ->
				mod_rank_service:update_arena(1000 - Point, Uid, util:get_name_by_uid(Uid), util:get_lev_by_uid(Uid)),
				add_week_reward(Uid,Rank)
		end
	end,
	db_api:dirty_map(Fun, ranklist_arena).

add_week_reward(Uid,Rank) ->
	Reward = data_arena_reward:get_season_reward(?PERSONAL_ARENA, Rank),
	if
		Reward == [] -> skip;
		true ->
			{Title, Content} = util_lang:get_mail(4),
			Content2 = util_str:format_string(Content, [Rank]),
			mod_mail_new:sys_send_personal_mail(Uid, Title, Content2, Reward,?MAIL_TIME_LEN)
	end.

get_chall_info(Rank, RankType) ->
	RankListType = get_ranklist_type(RankType),
	Fun = fun({Low, High}, Acc) ->
		Max = mod_rank_service:max_size(RankListType),
		TRank1 = util:rand(min(Max, Rank + Low), max(1, Rank - High)),
		TRank = case TRank1 == Rank of
			true ->
				if
					TRank1 - 1 < 1 -> 2;
					TRank1 + 1 > Max -> Max - 1;
					true -> TRank1 + 1
				end;
			_ -> TRank1
		end,
		case mod_rank_service:get_data_by_rank(RankListType, TRank) of
			#ranklist_arena{uid = Uid, name = Name} -> [{Uid, TRank, Name} | Acc];
			_ -> Acc
		end
	end,
	lists:foldl(Fun, [], data_arena:get_challenge_limit(RankType)).

get_win_point_change(Type, WinPoint, LosePoint) ->
	Dis = WinPoint - LosePoint,
	util:ceil(data_arena:get_fail_change(Type, LosePoint) / 10000 * data_arena:get_win_change(Type, Dis) / 10000 * LosePoint).

get_lose_point_change(Type, LosePoint) ->
	util:ceil(LosePoint * data_arena:get_fail_change(Type, LosePoint) / 10000).

get_rank_by_uid(Uid, Type) ->
	case db_api:dirty_index_read(Type, Uid, #ranklist_arena.uid) of
		[] -> data_para:get_data(6);
		[#ranklist_arena{rank = Rank}] -> Rank
	end.

get_value_by_uid(Uid, Type) ->
	case db_api:dirty_index_read(Type, Uid, #ranklist_arena.uid) of
		[] -> 0;
		[#ranklist_arena{key = {Value, _}}] -> Value
	end.

get_last_rank(Uid, RankType) ->
	Rec = get_data(Uid),
	case lists:keyfind(RankType, 1, Rec#t_last_ranklist.ranklist) of
		{RankType, Rank} -> Rank;
		_ -> 0
	end.

set_last_rank(Uid, Rank, RankType) ->
	Rec = get_data(Uid),
	case lists:keyfind(RankType, 1, Rec#t_last_ranklist.ranklist) of
		{RankType, OldRank} when Rank >= OldRank -> skip;
		_ ->
			NewList = lists:keystore(RankType, 1, Rec#t_last_ranklist.ranklist, {RankType, Rank}),
			NewRec = Rec#t_last_ranklist{ranklist = NewList},
			set_data(NewRec)
	end.