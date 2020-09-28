%% @doc 世界boss的全局模块
-module(fun_worldboss).
-include("common.hrl").
-export([init_boss_list/0, get_boss_list/0]).
-export([handle/1]).
-export([req_enter_copy/4]).
-export([delay_kick_all_usr/1]).
-export([notify_boss_die/1]).
-export([get_rank_reward/2]).
-export([is_boss_alive/1]).
-export([refresh_killed_times/1]).


init_boss_list() ->
	List = data_worldboss:all_boss_list(),
	[get_boss_rec(Id) || Id <- List],
	ok.


get_boss_list() ->
	[hd(db:dirty_get(worldboss_state, Id)) || Id <- db:dirty_all_keys(worldboss_state)].

get_boss_rec(BossId) ->
	InitHp = fun_monster:get_conf_max_hp(BossId),
	case db:dirty_get(worldboss_state, BossId, #worldboss_state.boss_id) of
		[] -> 
			St = data_worldboss:get_boss(BossId),
			Rec = #worldboss_state{
				boss_id          = St#st_worldboss.boss_id,
				next_revive_time = 0,
				init_hp          = InitHp,
				max_hp           = InitHp
			},
			set_boss_rec(Rec),
			Rec;
		[Rec] -> 
			case InitHp /=  Rec#worldboss_state.init_hp of
				true -> 
					%% 如果配置表额boss血量改了，就重置该boss的数据
					%% 这样自动化处理后就避免了人工来提醒修改会忘记的问题
					Rec2 = Rec#worldboss_state{
						alive_length_list = [],
						next_revive_time  = 0,
						killed_times      = 0,
						init_hp           = InitHp,
						max_hp            = InitHp
					},
					set_boss_rec(Rec2),
					Rec2;
				_ ->
					L = Rec#worldboss_state.alive_length_list,
					Rec#worldboss_state{
						alive_length_list = util:string_to_term(util:to_list(L))
					}
			end
	end.
set_boss_rec(Rec) ->
	Rec2 = Rec#worldboss_state{
		alive_length_list    = util:term_to_string(Rec#worldboss_state.alive_length_list)
	},
	case Rec#worldboss_state.id of
		0 -> db:insert(Rec2);
		_ -> db:dirty_put(Rec2)
	end.


req_enter_copy(Uid, Sid, Seq, BossId) ->
	case check_enter(Uid, BossId) of
		{error, Reason} -> ?debug("Reason:~p", [Reason]),
			?error_report(Sid, Reason, Seq);
		{ok, Scene, BossHp} ->
			[PlyRec | _] = db:dirty_get(ply, Uid),
			fun_agent_mng:agent_msg_by_pid(Uid, {world_boss, Uid, Sid}),
			mod_msg:handle_to_agent(PlyRec#ply.agent_hid, fun_agent_worldboss, {do_enter_copy, Seq, Scene, BossHp})
	end.

check_enter(Uid, BossId) ->
	% [PlyRec | _] = db:dirty_get(ply, Uid),
	St = data_worldboss:get_boss(BossId),
	BossRec = get_boss_rec(BossId),
	case mod_scene_lev:get_curr_scene_lv(Uid) >= St#st_worldboss.need_lv of
		true -> 
			case mod_scene_lev:get_curr_scene_lv(Uid) >= St#st_worldboss.limit_lv of
				true -> {error, "world_boss_2"};
				_ ->
					case is_boss_alive(BossRec) of
						false -> {error, "error_worldboss_die"};
						true  -> {ok, St#st_worldboss.scene, get_current_boss_max_hp(BossRec)}
					end
			end;
		_ -> {error, "not_enough_player_level"}
	end.

%% 计算本次刷新的boss的新血量
get_current_boss_max_hp(BossRec) ->
	LastMaxHp = BossRec#worldboss_state.max_hp,
	MaxHp = case BossRec#worldboss_state.alive_length_list of
		[] -> LastMaxHp;
		[_Time] -> LastMaxHp;
		[{_, Last1}, {_, Last2} | _] ->
			St = data_worldboss:get_boss(BossRec#worldboss_state.boss_id),
			if 
				Last1 < St#st_worldboss.hpUpTime andalso Last2 < St#st_worldboss.hpUpTime ->
					Rate = get_change_rate(BossRec#worldboss_state.killed_times),
					LastMaxHp*(1 + Rate);
				Last1 > St#st_worldboss.hpDownTime andalso Last2 > St#st_worldboss.hpDownTime ->
					Rate = get_change_rate(BossRec#worldboss_state.killed_times),
					LastMaxHp*(1 - Rate);
				true -> 
					LastMaxHp
			end
	end,
	util:floor(MaxHp).

get_change_rate(KilledTimes) ->
	case KilledTimes >= util:get_data_para_num(1058) of
		true  -> util:get_data_para_num(1060);
		false -> util:get_data_para_num(1059)
	end.


is_boss_alive(Rec) -> 
	Now = util_time:unixtime(),
	Rec#worldboss_state.next_revive_time =< Now.


handle({boss_die, KillerId, ScenePid, BossId, RankList, AliveTime}) ->
	?debug("BossId:~p", [BossId]),
	Rec = get_boss_rec(BossId),
	St = data_worldboss:get_boss(BossId),
	Rec2 = Rec#worldboss_state{
		next_revive_time  = St#st_worldboss.refresh_time + util_time:unixtime(),
		killed_times      = Rec#worldboss_state.killed_times + 1,
		alive_length_list = lists:sublist([{die, AliveTime} | Rec#worldboss_state.alive_length_list], 2),
		max_hp 			  = get_current_boss_max_hp(Rec)
	},
	set_boss_rec(Rec2),
	erlang:start_timer(1000, self(), {?MODULE, notify_boss_die, St#st_worldboss.scene}),
	erlang:start_timer(15000, self(), {?MODULE, delay_kick_all_usr, {ScenePid, St#st_worldboss.scene}}),
	[send_win_mail(Uid, Rank, Damage, BossId) || {Uid, Rank, Damage} <- RankList],

	case db:dirty_get(ply, KillerId) of
		[_Ply] -> send_kill_mail(KillerId, BossId);
		_     -> skip
	end,
	ok.

notify_boss_die(_Scene) ->
	Fun = fun(Uid) ->
		case db:dirty_get(ply, Uid) of
			[#ply{agent_hid=Hid} | _] ->
				mod_msg:handle_to_agent(Hid, fun_agent_worldboss, req_worldboss_info);
			_ -> skip
		end
	end,
	[Fun(Uid) || Uid <- db:dirty_all_keys(ply)],
	ok.
	
delay_kick_all_usr({ScenePid, Scene}) ->
	?debug("delay_kick_all_usr:~p", [Scene]),
	fun_scene_mng:set_scene_to_kick_state(ScenePid),
	ok.


send_win_mail(Uid, Rank, Damage, BossId) ->
	case db:dirty_get(usr, Uid) of
		[] -> skip;
		_ ->
			#mail_content{mailName = Title, text = Content} = data_mail:data_mail(world_boss_reward),
			MonsterName = util:to_binary(fun_monster:get_monster_name(BossId)),
			Content2    = util:format_lang(util:to_binary(Content), [MonsterName,Damage,Rank]),
			RewardItems = get_rank_reward(Rank, BossId),
			NewRewardItems = system_double_reward:is_double(RewardItems),
			mod_mail_new:sys_send_personal_mail(Uid, Title, Content2, NewRewardItems, ?MAIL_TIME_LEN)
	end.

send_kill_mail(Uid, BossId) ->
	case db:dirty_get(usr, Uid) of
		[] -> skip;
		_ ->
			RewardItems = fun_draw:box(0, 0),
			NewRewardItems = system_double_reward:is_double(RewardItems),
			#mail_content{mailName = Title, text = Content} = data_mail:data_mail(world_boss_reward2),
			MonsterName = util:to_binary(fun_monster:get_monster_name(BossId)),
			Content2    = util:format_lang(util:to_binary(Content), [MonsterName]),
			mod_mail_new:sys_send_personal_mail(Uid, Title, Content2, NewRewardItems, ?MAIL_TIME_LEN)
	end.

get_rank_reward(Rank, BossId) -> 
	#st_worldboss{rewards = {RewardItems, Baodi}} = data_worldboss:get_boss(BossId),
	BoxId2 = case find_rank_reward(RewardItems, Rank) of
		0 -> Baodi;
		BoxId -> BoxId
	end,
	RewardItems2 = fun_draw:box(BoxId2, 0),
	RewardItems2.


find_rank_reward([], _Rank) -> 0;
find_rank_reward([{Begin, End, BoxId} | Rest], Rank) ->
	case Rank >= Begin andalso Rank =< End of
		true -> BoxId;
		_ -> find_rank_reward(Rest, Rank)
	end.

refresh_killed_times(Now) ->
	List = data_worldboss:all_boss_list(),
	case get(refresh_time) of
		Time when (Time /= undefined andalso Time > 0) ->
			case util_time:is_same_day(Now, Time) of
				true -> skip;
				_ ->
					put(refresh_time, Now),
					[set_killed_time(Id) || Id <- List]
			end;
		_ -> 
			put(refresh_time, Now)
	end.

set_killed_time(BossId) ->
	case db:dirty_get(worldboss_state, BossId, #worldboss_state.boss_id) of
		[] -> skip;
		[Rec] -> 
			KilledTimes = Rec#worldboss_state.killed_times,
			case data_worldboss:get_boss(BossId) of
				#st_worldboss{boss_id=BossId,hpDayReduce=ReTime} ->
					case KilledTimes >= ReTime of
						true -> 
							Rec2 = Rec#worldboss_state{killed_times=KilledTimes-ReTime},
							db:dirty_put(Rec2);
						_ -> 
							Rec2 = Rec#worldboss_state{killed_times=0},
							db:dirty_put(Rec2)
					end;
				_ -> skip
			end
	end.