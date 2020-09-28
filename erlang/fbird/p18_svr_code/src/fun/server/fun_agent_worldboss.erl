%% @doc 世界boss的玩家个人模块
-module (fun_agent_worldboss).
-include("common.hrl").
-export([handle/1]).
-export([gm_reset_times/1]).
% -export([recover_times/2]).
-export([req_worldboss_info/3, req_times_info/3]).
% -export([on_login/1]).


get_max_times() -> util:get_data_para_num(1049).
%% ========================== 数据接口 ==========================
get_data(Uid) ->
	case db:dirty_get(usr_worldboss, Uid, #usr_worldboss.uid) of
		[]    -> 
			#usr_worldboss{
				uid        = Uid,
				left_times = get_max_times()
			};
		[Rec] -> Rec
	end.
set_data(Rec) -> 
	case Rec#usr_worldboss.id of
		0 -> db:insert(Rec);
		_ -> db:dirty_put(Rec)
	end.
%% ========================== 数据接口 ==========================

gm_reset_times(Uid) ->
	Rec = get_data(Uid),
	Rec2 = Rec#usr_worldboss{
		left_times = get_max_times(),
		recover_begin_time = 0
	},
	set_data(Rec2),
	send_times_info_to_client(Uid, get(sid), 0),
	ok.

% on_login(Uid) ->
% 	recover_times(Uid, util_time:unixtime()).

handle(req_worldboss_info) ->
	req_worldboss_info(get(uid), get(sid), 0); 
handle({do_enter_copy, Seq, Scene, BossHp}) -> 
	do_enter_copy(get(uid), Seq, Scene, BossHp);
handle({do_reduce_copy_times, _Scene}) ->
	% [DungeonsId] = data_dungeons_config:select(Scene),
	ok.

%% 注：该副本的次数挪到fun_copy_times模块里去了
do_enter_copy(_Uid, _Seq, _Scene, _BossHp) ->
	todo.
	


% do_reduce_times(Uid) ->
% 	Rec = get_data(Uid),
% 	NewTimes = Rec#usr_worldboss.left_times - 1,
% 	RecoverTime2 = case Rec#usr_worldboss.left_times >= get_max_times() of
% 		true -> %% 减少次数之前如果是满次数的，就可以开始回复倒计时了
% 			util_time:unixtime();
% 		_ -> %% 否则保持之前的回复时间
% 			Rec#usr_worldboss.recover_begin_time
% 	end,
% 	Rec2 = Rec#usr_worldboss{
% 		left_times         = NewTimes,
% 		recover_begin_time = RecoverTime2
% 	},
% 	set_data(Rec2).

% recover_times(Uid, Now) ->
% 	Rec = get_data(Uid),
% 	Interval = util:get_data_para_num(1050) * 3600,
% 	LeftTime = Rec#usr_worldboss.left_times,
% 	MaxTimes = get_max_times(),
% 	case LeftTime >= MaxTimes of
% 		true -> skip;
% 		false ->
% 			Duration = Now - Rec#usr_worldboss.recover_begin_time,
% 			case Duration div Interval of
% 				N when N > 0 -> 
% 					NewTimes = min(LeftTime + N, MaxTimes),
% 					Rec2 = Rec#usr_worldboss{
% 						left_times = NewTimes,
% 						recover_begin_time = Now
% 					},
% 					set_data(Rec2),
% 					send_times_info_to_client(Uid, get(sid), 0);
% 				_ -> skip
% 			end
% 	end.

send_times_info_to_client(Uid, Sid, Seq) -> 
	Rec = get_data(Uid),
	NextTime = case Rec#usr_worldboss.left_times >= get_max_times() of
		true -> 0;
		_ -> 
			Interval = util:get_data_para_num(1050) * 3600,
			Rec#usr_worldboss.recover_begin_time + Interval
	end,
	Pt = #pt_worldboss_times{
		left_times = Rec#usr_worldboss.left_times,
		next_recover_time = NextTime
	},
	?send(Sid, proto:pack(Pt, Seq)),
	ok.

send_worldboss_info_to_client(_Uid, Sid, Seq) ->
	List  = fun_worldboss:get_boss_list(),
	List2 = [make_boss_pt(Rec) || Rec <- List],
	Pt    = #pt_worldboss_list{list = List2},
	?send(Sid, proto:pack(Pt, Seq)),
	ok.

make_boss_pt(Rec) ->
	#pt_public_worldboss_info{
		boss_id          = Rec#worldboss_state.boss_id,
		state            = ?_IF(fun_worldboss:is_boss_alive(Rec), ?BOSS_STATE_ALIVE, ?BOSS_STATE_DIE),
		next_revive_time = Rec#worldboss_state.next_revive_time
	}.

req_times_info(_Uid, _Sid, _Seq) ->
	% send_times_info_to_client(Uid, Sid, Seq),
	ok.

req_worldboss_info(Uid, Sid, Seq) ->
	send_worldboss_info_to_client(Uid, Sid, Seq),
	ok.


