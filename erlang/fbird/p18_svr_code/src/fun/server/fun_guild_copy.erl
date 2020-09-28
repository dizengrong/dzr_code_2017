-module (fun_guild_copy).
-include("common.hrl").
-export([handle/1]).
-export([refresh_data/1]).
-export([req_guild_boss_copy_info/3, req_buy_inspire_times/3]).
-export([req_guild_copy_enter/4]).
-export([add_inspire_buff/2]).
-export([req_buy_times/3,check_copy_time/1]).
-export([updata_damage/1]).
-export([do_copy_end/2]).
-export([set_fast_data/3,set_progress_data/3,init_copy/1]).
-export([delay_kick_all_usr/1]).
-export([delay_kick_all_guild_copy/1,reset_buy_time/1]).
-export([init_copy_help_to_guild/2]).

-define(BOSS_CHALLENGE_NUM, util:get_data_para_num(1152)).
-define(GUILD_INSPIRE_BUFF, 7042).

-define(NOT_OPEN, 0).
-define(OPEN, 1).

get_data(Uid) ->
	case db:dirty_get(guild_boss_copy, Uid, #guild_boss_copy.uid) of
		[]    -> 
			#guild_boss_copy{
				uid               = Uid,
				challenge_num     = ?BOSS_CHALLENGE_NUM,
				buy_times 		  = 0,
				inspire_buy_times = 0
			};
		[Rec] -> 
			Rec#guild_boss_copy{}
	end.
set_data(Rec) ->
	case Rec#guild_boss_copy.id of
		0 -> db:insert(Rec);
		_ -> db:dirty_put(Rec)
	end.

init_copy(Now) ->
	[init_copy_help(Id, Now) || Id <- data_guild_copy:get_copy()].

init_copy_help(Id, Now) ->
	case data_guild_copy:get_data(Id) of
		#st_data_guild_copy{id = Id, open_time = {WeekDay,Time,Long}} ->
			NowWeekDay = util_time:weekday(Now),
			{Date, {Hour, Min, _}} = util_time:seconds_to_datetime(Now),
			HH = Time div 100,
			MM = Time rem 100,
			Day = (Long div 24) + ((HH + (Long rem 24)) div 24),
			% ?debug("Day = ~p",[Day]),
			EndDay = if
				WeekDay + Day > 7 -> (WeekDay + Day) - 7;
				true -> WeekDay + Day
			end,
			Is_open = if
				EndDay == WeekDay andalso Day > 1 -> true;
				NowWeekDay == WeekDay ->
					if
						Hour > HH -> true;
						Hour == HH andalso Min >= MM -> true;
						true -> false
					end;
				NowWeekDay == EndDay ->
					if
						Hour < ((HH + Long) rem 24) -> true;
						Hour == ((HH + Long) rem 24) andalso Min =< MM -> true;
						true -> false
					end;
				true ->
					if
						EndDay > WeekDay ->
							if
								NowWeekDay > WeekDay andalso NowWeekDay < EndDay -> true;
								true -> false
							end;
						true ->
							if
								NowWeekDay < WeekDay orelse NowWeekDay > EndDay -> true;
								true -> false
							end
					end
			end,
			% ?debug("Is Open ~p, Copy id ~p",[Is_open,Id]),
			case Is_open of
				true ->
					PassDay = case NowWeekDay >= WeekDay of
						true -> NowWeekDay - WeekDay;
						_ -> 7 - (WeekDay - NowWeekDay)
					end,
					OldNow = util_time:datetime_to_seconds({Date, {HH, MM, 0}}),
					put({copy_end, Id}, false),
					erase({fast_guild, Id}),
					erase({apply_for_guild_rank, Id}),
					put({endtime, Id}, OldNow + (Long - PassDay * 24) * 3600),
					[init_copy_help_to_guild(GuildId,Id) || #guild{id = GuildId} <- db:dirty_match(guild, #guild{_ ='_'})];
				_ -> skip
			end;
		_ -> skip
	end.

init_copy_help_to_guild(GuildId, Id) ->
	Now = util_time:unixtime(),
	case get({endtime, Id}) of
		undefined -> skip;
		_ ->
			case Now >= get({endtime, Id}) of
				true -> skip;
				_ -> 
					List = db:dirty_get(guild_boss_progress, GuildId, #guild_boss_progress.guild_id),
					case lists:keyfind(Id, #guild_boss_progress.copy_id, List) of
						#guild_boss_progress{wave = Wave} ->
							put({guild_progress, GuildId, Id}, {GuildId, (Wave * 100)}),
							case Wave > 0 of
								true -> put({is_kill_boss, Id, GuildId}, false);
								_ -> put({is_kill_boss, Id, GuildId}, true)
							end;
						_ ->
							put({is_kill_boss, Id, GuildId}, false),
							put({guild_progress, GuildId, Id}, {GuildId, 10000})
					end
			end
	end.
	

refresh_data(Uid) ->
	Rec = get_data(Uid),
	set_data(Rec#guild_boss_copy{challenge_num = ?BOSS_CHALLENGE_NUM, inspire_buy_times = 0, buy_times = 0}),
	ok.

handle({req_copy_enter, Uid, Sid, CopyId, Scenetype, Seq}) ->
	req_copy_enter(Uid, Sid, CopyId, Scenetype, Seq);

handle({req_guild_boss_copy_info, Uid, Sid, Seq}) ->
	req_guild_boss_copy_info(Uid,Sid,Seq);

handle({boss_die, Uid, SceneId, ScenePid}) ->
	case fun_guild:get_guild_baseinfo(Uid) of
		{ok,GuildId,_}->
			Id = hd(data_guild_copy:select(SceneId)),
			put({is_kill_boss, Id, GuildId}, true),
			set_progress_data(Uid,SceneId,0),
			Rank = get_rank(Id, GuildId),
			case data_guild_copy:get_data(Id) of
				#st_data_guild_copy{copy_name=CopyName} ->
					mod_msg:handle_to_chat_server({send_system_speaker, [integer_to_list(698),util:to_list(fun_guild:get_guild_name(GuildId)),util:to_list(CopyName)]});
				_ -> skip
			end,
			List1 = db:dirty_get(guild_damage, GuildId, #guild_damage.guild_id),
			FunFilter = fun(#guild_damage{copy_id = CopyId}) ->
				CopyId == Id
			end,
			List = lists:filter(FunFilter, List1),
			FunSort = fun(#guild_damage{damage = Damage1}, #guild_damage{damage = Damage2}) ->
				(Damage1 >= Damage2)
			end,
			RankList = lists:sort(FunSort, List),
			Fun = fun(Rec = #guild_damage{}, UsrRank) -> {Rec, UsrRank} end,
			NewList = lists:zipwith(Fun, RankList, lists:seq(1, length(RankList))),
			fun_guild_copy_progress:set_kill_info(0, GuildId, SceneId),
			erlang:start_timer(15000, self(), {?MODULE, delay_kick_all_usr, {ScenePid, SceneId}}),
			[send_win_reward(Rec, Rank, GuildId, Id) || Rec <- NewList];
		_ -> skip
	end.

delay_kick_all_usr({ScenePid, SceneId}) ->
	?debug("delay_kick_all_usr:~p", [SceneId]),
	fun_scene_mng:set_scene_to_kick_state(ScenePid),
	ok.

send_win_reward({#guild_damage{uid = Uid}, UsrRank}, Rank, _GuildId, CopyId) -> 
	case db:dirty_get(usr, Uid) of
		[] -> skip;
		_ ->
			case data_guild_copy:get_data(CopyId) of
				#st_data_guild_copy{copy_name=CopyName,first_struck=FirstReward,ranking=RankMultiList,normal_reward=NormalReward} ->
					Multi = case lists:keyfind(UsrRank, 1, RankMultiList) of
						{UsrRank, NewMulti} -> NewMulti;
						_ -> 1
					end,
					?debug("Rank = ~p",[Rank]),
					case Rank of
						1 ->
							#mail_content{mailName = Title1, text = Content1} = data_mail:data_mail(society3),
							Content12 = util:format_lang(util:to_binary(Content1), [util:to_binary(CopyName)]),
							NewRewardItems = [{T,N*Multi} || {T,N} <- FirstReward],
							mod_mail_new:sys_send_personal_mail(Uid, Title1, Content12, NewRewardItems, ?MAIL_TIME_LEN);
						_ -> 
							#mail_content{mailName = Title, text = Content} = data_mail:data_mail(society4),
							Content2 = util:format_lang(util:to_binary(Content), [util:to_binary(CopyName)]),
							NewRewardItems = [{T,N*Multi} || {T,N} <- NormalReward],
							mod_mail_new:sys_send_personal_mail(Uid, Title, Content2, NewRewardItems, ?MAIL_TIME_LEN)
					end;
				_ -> skip
			end
	end.

do_reduce_copy_times(Uid, _Sid) ->
	Rec = get_data(Uid),
	Rec2 = Rec#guild_boss_copy{challenge_num = max(0, Rec#guild_boss_copy.challenge_num - 1)},
	set_data(Rec2),
	ok.

%%请求公会boss信息
req_guild_boss_copy_info(Uid,Sid,Seq) ->
	case fun_guild:get_guild_baseinfo(Uid) of
		{ok,GuildId,_}->
			Rec = get_data(Uid),
			GuildCopyList = make_copy_list(Uid,GuildId),
			?debug("GuildCopyList:~p", [GuildCopyList]),
			Pt = #pt_guild_copy_list{
				challenge_times = Rec#guild_boss_copy.challenge_num,
				buy_times   	= Rec#guild_boss_copy.buy_times,
				guild_copy_list = GuildCopyList
			},
			?send(Sid, proto:pack(Pt, Seq)),
			update_inspire_buy_times(Sid,Seq,Rec#guild_boss_copy.inspire_buy_times);
		_ -> skip
	end.

%%更新鼓励次数
update_inspire_buy_times(Sid,Seq,Inspire_buy_times) ->
	Pt = #pt_update_guild_inspire_times{buy_times=Inspire_buy_times},
	?send(Sid,proto:pack(Pt, Seq)).

%%购买鼓励次数
req_buy_inspire_times(Uid,Sid,Seq) ->
	Rec = get_data(Uid),
	Num = Rec#guild_boss_copy.inspire_buy_times + 1,
	MaxTimes = data_inspire_config:max_times(),
	if
		Rec#guild_boss_copy.challenge_num =< 0 -> ?error_report(Sid, "dungeon_times");
		Num > MaxTimes -> ?error_report(Sid, "comeon_num");
		true -> 
			#st_inspire_config{
				currency_type =CostType,
				currency_num  =CostNum
			} = data_inspire_config:get_data(Num),
			SuccCallBack = fun() ->
				Rec2 = Rec#guild_boss_copy{inspire_buy_times = Num},
				set_data(Rec2),
				update_inspire_buy_times(Sid, Seq, Num)
			end,
			SpendItems = [{?ITEM_WAY_GUILD_INSPIRE,CostType,CostNum}],
		    fun_item_api:check_and_add_items(Uid, Sid, SpendItems, [], SuccCallBack, undefined)
	end.

%% 给玩家加鼓励buff
add_inspire_buff(Uid, _Scene) ->
	Rec = get_data(Uid),
	Times = Rec#guild_boss_copy.inspire_buy_times,
	case Times > 0 of
		true -> 
			#st_inspire_config{add_value = Power} = data_inspire_config:get_data(Times),
			fun_agent:send_to_scene({add_buff, Uid, ?GUILD_INSPIRE_BUFF, Power*100, 40000, Uid});
		_ -> 
			skip
	end.


%% 请求进入公会副本
req_guild_copy_enter(Uid,Sid,CopyId,Seq)->
	case fun_guild:get_guild_baseinfo(Uid) of
		{ok, GuildId, _}->
			req_guild_copy_enter2(Uid, Sid, Seq, GuildId, CopyId);
		_->skip
	end.
%%请求进入公会副本
req_guild_copy_enter2(Uid,Sid,Seq,GuildId,CopyId)->
	Rec = get_data(Uid),
	?debug("CopyId:~p", [CopyId]),
	case check_enter_copy(Uid, GuildId, CopyId, Rec) of
		{error, ErrorCode} -> ?debug("ErrorCode:~p",[ErrorCode]),
			?error_report(Sid, ErrorCode);
		true->
			Rec2 = Rec#guild_boss_copy{challenge_num = Rec#guild_boss_copy.challenge_num - 1},
			set_data(Rec2),
			SceneId = get_scene_id_by_copy_id(CopyId),
			#st_scene_config{points = PointList} = data_scene_config:get_scene(SceneId),
			InPos = hd(PointList),
			UsrInfoList = [{Uid,Seq,InPos,#ply_scene_data{sid = Sid}}],
			SceneData = {guild_copy,GuildId,SceneId},
			gen_server:cast({global, scene_mng}, {start_fly, UsrInfoList,SceneId,SceneData})
	end.

check_enter_copy(_Uid, _GuildId, _CopyId, Rec) ->
	case Rec#guild_boss_copy.challenge_num > 0 of
		false -> {error, "dungeon_times"};
		true -> true
	end.

% get_copy_id_by_scene_id(SceneId)->
% 	case data_dungeons_config:select(SceneId) of
% 		[DungeonID | _] -> DungeonID;
% 		_ -> 0
% 	end.

get_scene_id_by_copy_id(CopyId)->
	case data_dungeons_config:get_dungeons(CopyId) of
		#st_dungeons_config{dungenScene = SceneId} ->SceneId;			
		_->0
	end.

req_copy_enter(Uid, Sid, _CopyId, SceneId, Seq) ->
	fun_agent:send_to_scene({req_enter_copy_scene, Uid, Seq, SceneId}),
	on_enter_copy_event(Uid, Sid).

on_enter_copy_event(Uid, Sid) ->
	on_enter_copy_event(Uid, Sid, true).
on_enter_copy_event(Uid, Sid, ReduceTimes) ->
	ReduceTimes andalso do_reduce_copy_times(Uid, Sid).

make_copy_list(Uid,GuildId) ->
	Now = util_time:unixtime(),
	Fighting = fun_guild:get_guild_fighting(GuildId),
	[make_boss_list_help(Uid, Id, Fighting, Now, GuildId) || Id <- data_guild_copy:get_copy()].

make_boss_list_help(Uid, Id, Fighting, Now, GuildId) ->
	#st_data_guild_copy{id = Id, copy_id = CopyId, scene_id = SceneId, open_condition = OpenCondition} = data_guild_copy:get_data(Id),
	OpenState = case Fighting >= OpenCondition of
		true -> ?OPEN;
		_ -> ?NOT_OPEN
	end,
	% ?debug("EndTime : ~p",[get({endtime, Id})]),
	% ?debug("is_kill_boss : ~p",[get({is_kill_boss, Id, GuildId})]),
	CanScene = case OpenState of
		?NOT_OPEN -> ?NOT_OPEN;
		_ -> 
			case get({is_kill_boss, Id, GuildId}) of
				true -> ?NOT_OPEN;
				undefined -> ?NOT_OPEN;
				_ ->
					case Now >= get({endtime, Id}) of
						true -> ?NOT_OPEN;
						_ -> ?OPEN
					end
			end
	end,
	{Step,Damage,Time} = case CanScene of
		?NOT_OPEN -> {0,fun_guild_damage:get_usr_damage(Uid, Id),get_start_time(Id, Now)};
		_ -> {get_progress_data(GuildId, Id),fun_guild_damage:get_usr_damage(Uid, Id),get({endtime, Id})}
	end,
	List = fun_guild_damage:get_top(Id, GuildId),
	RankList = make_damage_rank_pt(List, [], 1),
	{FastServerName, FastGuildName, FastPercent} = case get({fast_guild, Id}) of
		{NewGuildId, Percent} -> {db:get_all_config(servername), NewGuildId, Percent};
		_ ->
			List1 = db:dirty_get(guild_boss_progress, SceneId, #guild_boss_progress.scene_id),
			FunFilter = fun(#guild_boss_progress{kill_time = KillTime}) ->
				KillTime /= 0
			end,
			List2 = lists:filter(FunFilter, List1),
			case List2 of
				[] -> {"",0,10000};
				NewList ->
					FunSort = fun(#guild_boss_progress{kill_time = KillTime1}, #guild_boss_progress{kill_time = KillTime2}) ->
						(KillTime1 =< KillTime2)
					end,
					NewList1 = lists:sort(FunSort, NewList),
					Rec = hd(NewList1),
					{db:get_all_config(servername), Rec#guild_boss_progress.guild_id, Rec#guild_boss_progress.wave * 100}
			end
	end,
	#pt_public_guild_copy_list{
		scene_id            = SceneId,
		copy_id             = CopyId,
		copy_step           = Step,
		damage              = Damage,
		remaining_time      = Time,
		open_state          = OpenState,
		is_open_scene       = CanScene,
		fast_server_name    = FastServerName,
		fast_guild_name     = fun_guild:get_guild_name(FastGuildName),
		fast_guild_progress = FastPercent,
		rank_list           = RankList
	}.


make_damage_rank_pt([], Acc, _Rank) -> lists:reverse(Acc);
make_damage_rank_pt([Rec | Rest], Acc, Rank) ->
	?debug("Rec:~p", [Rec]),
	[#usr{name=Name}] = db:dirty_get(usr, Rec#guild_damage.uid),
	Ptm = #pt_public_guild_ranklist{
		fighting   = Rec#guild_damage.damage,
		uid        = Rec#guild_damage.uid,
		name       = Name,
		rank       = Rank
	},
	make_damage_rank_pt(Rest, [Ptm | Acc], Rank + 1).

%%购买副本次数
req_buy_times(Uid,Sid,Seq) ->
	Rec = get_data(Uid),
	Num = Rec#guild_boss_copy.buy_times + 1,
	Num2 = Rec#guild_boss_copy.challenge_num + 1,
	MaxTimes = data_buy_time_price:get_max_times(?BUY_GUILDCOPY),
	Times = min(MaxTimes, Num),
	case data_buy_time_price:get_data(?BUY_GUILDCOPY, Times) of
		#st_buy_time_price{cost = Cost} ->
			SuccCallBack = fun() ->
				Rec2 = Rec#guild_boss_copy{challenge_num = Num2, buy_times = Num},
				set_data(Rec2),
				mod_msg:handle_to_agnetmng(?MODULE, {req_guild_boss_copy_info, Uid, Sid, Seq})
			end,
			SpendItems = [{?ITEM_WAY_GUILD_COPY_TIMES, T, N} || {T, N} <- Cost],
			fun_item_api:check_and_add_items(Uid, Sid, SpendItems, [], SuccCallBack, undefined);
		_ -> skip
	end.

reset_buy_time(Uid) ->
	Rec = get_data(Uid),
	Rec2 = Rec#guild_boss_copy{buy_times = 0},
	set_data(Rec2).

check_copy_time(Now) ->
	[check_copy_data_help(Id, Now + 300) || Id <- data_guild_copy:get_copy()],
	[check_copy_open_help(Id, Now) || Id <- data_guild_copy:get_copy()],
	[check_copy_close_help(Id, Now) || Id <- data_guild_copy:get_copy()].

check_copy_data_help(Id, Now) ->
	case get({copy_end, Id}) of
		false -> skip;
		_ ->
			case data_guild_copy:get_data(Id) of
				#st_data_guild_copy{id = Id, open_time = {WeekDay,Time,_}} ->
					NowWeekDay = util_time:weekday(Now),
					{_, {Hour, Min, _}} = util_time:seconds_to_datetime(Now),
					NowTime = Hour * 100 + Min,
					case WeekDay == NowWeekDay andalso NowTime == Time of
						true ->
							put({copy_end, Id}, true),
							erase({fast_guild, Id}),
							erase({apply_for_guild_rank, Id}),
							[refresh_guild_progress(Id, Rec#guild.id) || Rec <- db:dirty_match(guild, #guild{_='_'})],
							fun_guild_damage:refresh_top_list(Id);
						_ -> skip
					end;
				_ -> skip
			end
	end.

refresh_guild_progress(CopyId, GuildId) ->
	put({guild_progress, GuildId, CopyId}, {GuildId, 10000}),
	List = db:dirty_get(guild_boss_progress, GuildId, #guild_boss_progress.guild_id),
	Fun = fun(#guild_boss_progress{id = Id, copy_id = CopyId1}) ->
		case CopyId == CopyId1 of
			true ->
				db:dirty_del(guild_boss_progress, Id);
			_ -> skip
		end
	end,
	lists:foreach(Fun, List).

check_copy_open_help(Id, Now) ->
	case data_guild_copy:get_data(Id) of
		#st_data_guild_copy{id = Id, open_time = {WeekDay,Time,Long}} ->
			NowWeekDay = util_time:weekday(Now),
			{_, {Hour, Min, _}} = util_time:seconds_to_datetime(Now),
			NowTime = Hour * 100 + Min,
			case WeekDay == NowWeekDay andalso NowTime == Time of
				true ->
					put({copy_end, Id}, false),
					erase({fast_guild, Id}),
					erase({apply_for_guild_rank, Id}),
					put({endtime, Id}, Now + Long * 3600),
					GuildIdList = db:dirty_all_keys(guild),
					[erase({kill_rank,Id,GuildId}) || GuildId <- GuildIdList],
					[guild_copy_open(GuildId,Id) || GuildId <- GuildIdList];
				_ -> skip
			end;
		_ -> skip
	end.

guild_copy_open(GuildId,Id) ->
	put({is_kill_boss, Id, GuildId}, false).

check_copy_close_help(Id, Now) ->
	case Now >= get({endtime, Id}) of
		true ->
			put({copy_end, Id}, true),
			erlang:start_timer(15000, self(), {?MODULE, delay_kick_all_guild_copy, Id}),
			[guild_copy_close(GuildId,Id) || #guild{id = GuildId} <- db:dirty_match(guild, #guild{_ ='_'})];
		_ -> skip
	end.

guild_copy_close(_GuildId,_Id) -> ok.

delay_kick_all_guild_copy(CopyId) ->
	case data_guild_copy:get_data(CopyId) of
		#st_data_guild_copy{scene_id = Scene} ->
			% ?debug("delay_kick_all_guild_copy:~p", [Scene]),
			fun_scene_mng:set_guild_scene_to_kick_state(Scene);
		_ -> skip
	end.

updata_damage(Scene) ->
	UL = fun_scene_obj:get_ul(),
	CopyId = hd(data_guild_copy:select(Scene)),
	Fun=fun(Object) ->
		case Object of
			#scene_spirit_ex{id = Uid} ->
				case fun_scene_obj:get_obj(Uid)	of
					#scene_spirit_ex{data = #scene_usr_ex{hid = _Hid, sid = Sid, guild_id = GuildId}} ->
					mod_msg:handle_to_toplist_mng({update_raw_data, Uid, Sid, {guild_boss, CopyId, GuildId, fun_scene_skill:get_demage(Uid), fun_scene_skill:get_damage_list()}, Scene});
					_ -> skip
				end;
			_ -> skip
		end	
	end,
	lists:foreach(Fun, UL),
	ok.

set_fast_data(Uid,Scene,Percent) ->
	case fun_guild:get_guild_baseinfo(Uid) of
		{ok, GuildId, _} ->
			Id = hd(data_guild_copy:select(Scene)),
			case get({fast_guild, Id}) of
				{_, OldPercent} ->
					case Percent < OldPercent of
						true -> put({fast_guild, Id}, {GuildId, Percent});
						_ -> skip
					end;
				_ -> put({fast_guild, Id}, {GuildId, Percent})
			end;
		_ -> skip
	end.

get_progress_data(GuildId, Id) ->
	case get({guild_progress, GuildId, Id}) of
		{GuildId, Percent} -> Percent;
		_ -> 10000
	end.

set_progress_data(Uid,Scene,Percent) ->
	case fun_guild:get_guild_baseinfo(Uid) of
		{ok, GuildId, _} ->
			Id = hd(data_guild_copy:select(Scene)),
			case get({guild_progress, GuildId, Id}) of
				{_, _} ->
					put({guild_progress, GuildId, Id}, {GuildId, Percent});
				_ -> 
					put({guild_progress, GuildId, Id}, {GuildId, Percent})
			end;
		_ -> skip
	end.

do_copy_end(Uid, SceneId) -> 
	mod_msg:handle_to_agnetmng(?MODULE, {boss_die, Uid, SceneId, self()}).

get_rank(Id, GuildId) ->
	case get({kill_rank, Id, GuildId}) of
		undefined ->
			Rank = get_rank_for_guild_id(Id),
			put({kill_rank, Id, GuildId}, Rank),
			Rank;
		RankNum -> RankNum
	end.

get_rank_for_guild_id(Id)->
	case get({apply_for_guild_rank, Id}) of
		undefined ->
			put({apply_for_guild_rank, Id},2),
			1;
		RankGuildId when is_number(RankGuildId) ->
			put({apply_for_guild_rank, Id}, RankGuildId + 1),
			RankGuildId
	end.

get_start_time(Id, Now) ->
	case data_guild_copy:get_data(Id) of
		#st_data_guild_copy{open_time = {WeekDay,Time,_}} ->
			HH = Time div 100,
			MM = Time rem 100,
			NowWeekDay = util_time:weekday(Now),
			{Date, {HH1, MM1, _}} = util_time:seconds_to_datetime(Now),
			Diff = if
				WeekDay == NowWeekDay ->
					if
						HH1 < HH -> 0;
						HH1 =< HH andalso MM1 =< MM -> 0;
						true -> 7
					end;
				NowWeekDay > WeekDay -> 7 - (NowWeekDay - WeekDay);
				true -> WeekDay - NowWeekDay
			end,
			NewDate = util_time:add_days(Date, Diff),
			util_time:datetime_to_seconds({NewDate, {HH, MM, 0}});
		_ -> 0
	end.