%% 后台活动——乱斗boss
-module(system_melleboss).
-include("common.hrl").
-export([on_act_open/2,on_act_close/2,on_act_change/1]).
-export([get_boss_rec/1]).
-export([get_boss_hp/1]).
-export([handle/1]).
-export([delay_kick_all_usr/1,notify_boss_die/1]).
-export([create_scene/1]).
-export([send_boss_revive/1]).

handle({boss_die, ScenePid, Uid, Diff, BossId}) ->
	Now = util_time:unixtime(),
	?debug("BossId:~p", [BossId]),
	Rec = get_boss_rec(BossId),
	St = data_melleboss:get_boss(BossId),
	Rec2 = Rec#melleboss_state{
		next_revive_time = Now + St#st_melleboss.refresh_time
	},
	set_boss_rec(Rec2),
	set_boss_hp(BossId, 0),
	erlang:start_timer(1000, self(), {?MODULE, notify_boss_die, St#st_melleboss.scene}),
	erlang:start_timer(5000, self(), {?MODULE, delay_kick_all_usr, {ScenePid, St#st_melleboss.scene}}),
	erlang:start_timer(St#st_melleboss.re_scene_time * 1000, self(), {?MODULE, create_scene, BossId}),
	erlang:start_timer(St#st_melleboss.refresh_time * 1000, self(), {?MODULE, send_boss_revive, BossId}),
	case db:dirty_get(usr, Uid) of
		[#usr{prof = Prof}] ->
			case db:dirty_get(ply, Uid) of
				[#ply{sid = Sid, agent_hid = Hid}] -> mod_msg:handle_to_agent(Hid, fun_agent_meleeboss, {on_get_owner, Uid, Sid});
				_ -> skip
			end,
			send_owner_reward(Uid, BossId, Diff, Prof);
		_ -> skip
	end,
	ok;

handle({req_meleeboss_info, Uid, Sid, Seq}) ->
	req_meleeboss_info(Uid, Sid, Seq, 0);

handle({set_boss_hp, BossId, Progress}) ->
	% ?debug("Progress = ~p",[{BossId, Progress}]),
	set_boss_hp(BossId, Progress).

req_meleeboss_info(Uid, Sid, Seq, Type) ->
	Rec = fun_agent_meleeboss:get_data(Uid),
	Pt = #pt_melleboss_info{
		type 		 = Type,
		reward_times = Rec#usr_melleboss.times,
		buy_times    = Rec#usr_melleboss.buy_times,
		list 		 = make_meleeboss_info(data_melleboss:all_boss_list(), [])
	},
	% ?debug("Pt = ~p",[Pt]),
	?send(Sid, proto:pack(Pt, Seq)).

send_boss_revive(BossId) ->
	set_boss_hp(BossId, 10000),
	[req_meleeboss_info(Uid, Sid, 0, 2) || #ply{uid = Uid, sid = Sid} <- db:dirty_match(ply, #ply{_='_'})],
	mod_msg:handle_to_chat_server({send_system_speaker, [integer_to_list(770),util:to_list(fun_monster:get_monster_name(BossId))]}).

notify_boss_die(_Scene) ->
	Fun = fun(Uid) ->
		case db:dirty_get(ply, Uid) of
			[#ply{sid=Sid}] ->
				req_meleeboss_info(Uid, Sid, 0, 1);
			_ -> skip
		end
	end,
	[Fun(Uid) || Uid <- db:dirty_all_keys(ply)],
	ok.

on_act_change(_ActType) ->
	List = data_melleboss:all_boss_list(),
	[init_boss_rec(Id) || Id <- List],
	ok.

init_boss_rec(BossId) ->
	get_boss_rec(BossId),
	dick_scene(BossId),
	create_scene(BossId),
	ok.

dick_scene(BossId) ->
	St = data_melleboss:get_boss(BossId),
	fun_scene_mng:set_guild_scene_to_kick_state(St#st_melleboss.scene).

create_scene(BossId) ->
	St = data_melleboss:get_boss(BossId),
	gen_server:cast({global, scene_mng}, {create_scene, St#st_melleboss.scene, {melle_boss, St#st_melleboss.scene}}).

get_boss_rec(BossId) ->
	case db:dirty_get(melleboss_state, BossId, #melleboss_state.boss_id) of
		[] -> 
			Rec = #melleboss_state{
				boss_id          = BossId,
				next_revive_time = 0
			},
			set_boss_rec(Rec),
			Rec;
		[Rec] -> Rec
	end.

set_boss_rec(Rec) ->
	case Rec#melleboss_state.id of
		0 -> db:insert(Rec);
		_ -> db:dirty_put(Rec)
	end.

on_act_open(ActType, Status) ->
	case db:dirty_get(system_activity, ActType, #system_activity.act_type) of
		[] -> db:insert(#system_activity{act_type=ActType,act_status=Status});
		[Rec = #system_activity{act_status=OldStatus}] ->
			case Status /= OldStatus of
				true ->
					NewRec = Rec#system_activity{act_status=Status},
					db:dirty_put(NewRec),
					List = db:dirty_match(ply, #ply{_ = '_'}),
					mod_msg:handle_to_chat_server({send_system_speaker, [integer_to_list(777)]}),
					[fun_system_activity:send_info_to_client(Uid, Sid, ActType, Status, 0) || #ply{uid = Uid, sid = Sid} <- List];
				_ -> skip
			end
	end.

on_act_close(ActType, Status) ->
	case db:dirty_get(system_activity, ActType, #system_activity.act_type) of
		[] -> db:insert(#system_activity{act_type=ActType,act_status=Status});
		[Rec = #system_activity{act_status=OldStatus}] ->
			case Status /= OldStatus of
				true ->
					NewRec = Rec#system_activity{act_status=Status},
					db:dirty_put(NewRec),
					List = db:dirty_match(ply, #ply{_ = '_'}),
					[fun_system_activity:send_info_to_client(Uid, Sid, ActType, Status, 0) || #ply{uid = Uid, sid = Sid} <- List];
				_ -> skip
			end
	end.


get_boss_hp(BossId) ->
	case get(progress) of
		undefined -> 10000;
		L ->
			case lists:keyfind(BossId, 1, L) of
				{_, T} -> T;
				_ -> 10000
			end
	end.

set_boss_hp(BossId, Progress) ->
	case get(progress) of
		L when length(L) > 0 ->
			NewList = lists:keystore(BossId, 1, L, {BossId, Progress}),
			put(progress, NewList);
		_ -> put(progress, [{BossId, Progress}])
	end.

delay_kick_all_usr({_ScenePid, Scene}) ->
	?debug("delay_kick_all_usr:~p", [Scene]),
	fun_scene_mng:set_guild_scene_to_kick_state(Scene),
	ok.

send_owner_reward(Uid, BossId, Diff, Prof) ->
	Rec = fun_agent_meleeboss:get_data(Uid),
	case Rec#usr_melleboss.times > 0 of
		true ->
			St = data_melleboss:get_boss(BossId),
			{Box1, Box2, Box3} = St#st_melleboss.reward_box,
			BoxId = case Diff of
				1 -> Box1;
				2 -> Box2;
				3 -> Box3
			end,
			NewRec = Rec#usr_melleboss{
				times = Rec#usr_melleboss.times - 1
			},
			fun_agent_meleeboss:set_data(NewRec),
			RewardItems = fun_draw:box(BoxId, Prof),
			#mail_content{mailName = Title, text = Content} = data_mail:data_mail(melee_boss),
			MonsterName = util:to_binary(fun_monster:get_monster_name(BossId)),
			Content2    = util:format_lang(util:to_binary(Content), [MonsterName]),
			mod_mail_new:sys_send_personal_mail(Uid, Title, Content2, RewardItems, ?MAIL_TIME_LEN);
		_ -> skip
	end.

make_meleeboss_info([], Acc) -> Acc;
make_meleeboss_info([BossId | Rest], Acc) ->
	St = data_melleboss:get_boss(BossId),
	Rec = get_boss_rec(BossId),
	BossHp = get_boss_hp(BossId),
	UsrNum = case db:dirty_match(scene, #scene{type = St#st_melleboss.scene, _='_'}) of
		[#scene{num = Num}] -> Num;
		_ -> 0
	end,
	Pt = #pt_public_melleboss_list{
		boss_id 	= BossId,
		boss_hp 	= BossHp,
		usr_num 	= UsrNum,
		revive_time = Rec#melleboss_state.next_revive_time
	},
	make_meleeboss_info(Rest, [Pt | Acc]).