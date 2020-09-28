%% 后台活动——限时boss
-module(system_activity_limitboss).
-include("common.hrl").
-export([req_enter_copy/4]).
-export([on_act_open/2,on_act_close/2,on_act_change/1]).
-export([handle/1]).
-export([get_rank_reward/1,delay_kick_all_usr/1]).
-export([do_act_close/1,on_act_open_help/1]).

-define(SCENE, 500038).

req_enter_copy(Uid, Sid, Seq, CopyId) ->
	case check_enter(Uid, CopyId) of
		{error, Reason} -> ?debug("Reason:~p", [Reason]),
			?error_report(Sid, Reason, Seq);
		{ok, Scene} ->
			[PlyRec | _] = db:dirty_get(ply, Uid),
			% fun_agent_mng:agent_msg_by_pid(Uid, {limit_boss, Uid, Sid}),
			put({req_enter_limitboss_time, Uid}, util_time:unixtime()),
			mod_msg:handle_to_agent(PlyRec#ply.agent_hid, fun_agent_limitboss, {do_enter_copy, Seq, CopyId, Scene})
	end.

check_enter(Uid, CopyId) ->
	check_enter2(Uid, CopyId).

check_enter2(_Uid, CopyId) ->
	case data_dungeons_config:get_dungeons(CopyId) of
		#st_dungeons_config{dungenScene = SceneID} ->
			% BarrierId     = mod_scene_lev:get_curr_scene_lv(Uid),
			% [#usr{lev=Lev} | _] = db:dirty_get(usr, Uid),
			case fun_system_activity:find_open_activity(?SYSTEM_LIMIT_BOSS) of
				{error, Reason} -> {error, Reason};
				_ ->
					case db:dirty_get(system_activity, ?SYSTEM_LIMIT_BOSS, #system_activity.act_type) of
						[] -> {error, "no_activity"};
						[#system_activity{act_status=Status}] ->
							case Status of
								?ACT_CLOSE -> {error, "act_close"};
								_ ->  {ok, SceneID}
							end
					end
			end;
		_ -> 
			?log_error("request enter copy error, Scene is not copy:~p", [CopyId]),
			{error, "check_data_error"}
	end.

on_act_change(_ActType) ->
	case get(act_end) of
		false -> skip;
		_ -> 
			put(act_end, true)
			% fun_toplist_new:refresh_top_list(?RANKLIST_TOTEL_BOSS_DAMAGE)
	end.

on_act_open(ActType, Status) ->
	put(act_end, false),
	?debug("boss_die~p",[get(is_boss_die)]),
	case get(is_boss_die) of
		true -> skip;
		_ ->
			put(is_boss_die,false),
			case db:dirty_get(system_activity, ActType, #system_activity.act_type) of
				[] -> db:insert(#system_activity{act_type=ActType,act_status=Status});
				[Rec = #system_activity{act_status=OldStatus}] ->
					case Status /= OldStatus of
						true ->
							%% 预先创建限时boss场景，不然在玩家请求时再去创建，可能会导致创建多个场景的情况，其根本原因是场景的创建是异步
							gen_server:cast({global, scene_mng}, {create_scene, 500038, {limit_boss, 500038}}),
							NewRec = Rec#system_activity{act_status=Status},
							db:dirty_put(NewRec),
							erlang:start_timer(5000, self(), {?MODULE, on_act_open_help, {ActType, Status}});
						_ -> skip
					end
			end
	end.

on_act_open_help({ActType, Status}) ->
	List = db:dirty_match(ply, #ply{_ = '_'}),
	mod_msg:handle_to_chat_server({send_system_speaker, [integer_to_list(615)]}),
	[mod_msg:handle_to_agent(Hid, fun_agent_limitboss, {on_act_open, Uid, Sid}) || #ply{uid = Uid, sid = Sid, agent_hid = Hid} <- List],
	[fun_system_activity:send_info_to_client(Uid, Sid, ActType, Status, 0) || #ply{uid = Uid, sid = Sid} <- List].

on_act_close(ActType, Status) ->
	?debug("boss_die~p",[get(is_boss_die)]),
	put(act_end, true),
	case get(is_boss_die) of
		true -> skip;
		_ ->
			case db:dirty_get(system_activity, ActType, #system_activity.act_type) of
				[] -> db:insert(#system_activity{act_type=ActType,act_status=Status});
				[Rec = #system_activity{act_status=OldStatus}] ->
					case Status /= OldStatus of
						true ->
							NewRec = Rec#system_activity{act_status=Status},
							db:dirty_put(NewRec),
							List = db:dirty_match(ply, #ply{_ = '_'}),
							[fun_system_activity:send_info_to_client(Uid, Sid, ActType, Status, 0) || #ply{uid = Uid, sid = Sid} <- List],
							erlang:start_timer(200*1000, self(), {?MODULE, do_act_close, {ActType, Status}});
						_ -> skip
					end
			end
	end.

do_act_close({_ActType, _Status}) -> skip.
	% case get(is_boss_die) of
	% 	true -> skip;
	% 	_ ->
	% 		mod_msg:handle_to_scenemng(?MODULE, {do_act_close, ActType}),
	% 		RankList = fun_toplist_new:ranking_tab_help(?RANKLIST_TOTEL_BOSS_DAMAGE),
	% 		[send_win_mail(Uid, Rank, Num) || #ranklist_total_boss_damage{uid=Uid,rank=Rank,num=Num} <- RankList]
	% end.

handle({reenter_check_limitboss_open, Uid, Scene, ToPos}) -> 
	case db:dirty_get(ply, Uid) of
		[#ply{agent_hid = Hid}] ->
			case fun_system_activity:find_open_activity(?SYSTEM_LIMIT_BOSS) of
				{error, _} -> 
					mod_msg:send_to_agent(Hid, {reenter_limitboss_not_ok, Scene, ToPos});
				_ -> 
					TimeLen = fun_interface:s_get_copy_scene_time(?SCENE),
					Now = util_time:unixtime(),
					case get({req_enter_limitboss_time, Uid}) of
						ReqTime when Now < ReqTime + TimeLen - 3 -> %% 玩家的时间还没打完
							mod_msg:send_to_agent(Hid, {reenter_limitboss_ok, Scene, ToPos});
						_ -> 
							mod_msg:send_to_agent(Hid, {reenter_limitboss_not_ok, Scene, ToPos})
					end
			end;
		_ -> skip
	end;

handle({boss_die, ScenePid, BossId, Scene}) ->
	boss_die({ScenePid, BossId, Scene});

handle({do_act_close, _ActType}) ->
	case db:dirty_match(scene, #scene{type = ?SCENE, _='_'}) of
		[] -> skip;
		List ->
			[delay_kick_all_usr({Rec#scene.hid, ?SCENE}) || Rec <- List]
	end;

handle({kill_boss, Uid, MonsterId}) -> 
	% #st_monster_config{monsterBoxId = BoxId} = data_monster:get_monster(MonsterId),
	RewardItems = fun_draw:box(0, 0),
	#mail_content{mailName = Title, text = Content} = data_mail:data_mail(world_boss_reward2),
	MonsterName = util:to_binary(fun_monster:get_monster_name(MonsterId)),
	Content2    = util:format_lang(util:to_binary(Content), [MonsterName]),
	mod_mail_new:sys_send_personal_mail(Uid, Title, Content2, RewardItems, ?MAIL_TIME_LEN),
	ok.

boss_die({ScenePid, _BossId, Scene}) ->
	put(is_boss_die,true),
	erlang:start_timer(15000, self(), {?MODULE, delay_kick_all_usr, {ScenePid, Scene}}),
	% RankList = fun_toplist_new:ranking_tab_help(?RANKLIST_TOTEL_BOSS_DAMAGE),
	% [send_win_mail(Uid, Rank, Num) || #ranklist_total_boss_damage{uid=Uid,rank=Rank,num=Num} <- RankList],
	case db:dirty_get(system_activity, ?SYSTEM_LIMIT_BOSS, #system_activity.act_type) of
		[] -> db:insert(#system_activity{act_type=?SYSTEM_LIMIT_BOSS,act_status=?ACT_CLOSE});
		[Rec = #system_activity{act_status=OldStatus}] ->
			case OldStatus == ?ACT_OPEN of
				true ->
					NewRec = Rec#system_activity{act_status=?ACT_CLOSE},
					db:dirty_put(NewRec),
					List = db:dirty_match(ply, #ply{_ = '_'}),
					[fun_system_activity:send_info_to_client(Uid, Sid, ?SYSTEM_LIMIT_BOSS, 0, 0) || #ply{uid = Uid, sid = Sid} <- List];
				_ -> skip
			end
	end.

% send_win_mail(Uid, Rank, Num) ->
% 	case db:dirty_get(usr, Uid) of
% 		[] -> skip;
% 		_ ->
% 			#mail_content{mailName = Title, text = Content} = data_mail:data_mail(limit_boss),
% 			Content2    = util:format_lang(util:to_binary(Content), [Num, Rank]),
% 			RewardItems = get_rank_reward(Rank),
% 			mod_mail_new:sys_send_personal_mail(Uid, Title, Content2, RewardItems, ?MAIL_TIME_LEN)
% 	end.

get_rank_reward(Rank) ->
	RewardItems = find_rank_reward(Rank,1),
	RewardItems.

find_rank_reward(URank, RankId) ->
	case data_limitboss:get_data(RankId) of
		#st_limitboss_reward{ranking = {Start,End}, reward = Rewards} ->
			case URank =< Start andalso URank >= End of
				true -> 
					case Rewards of
						[] -> data_limitboss:get_base_reward();
						_ -> Rewards
					end;
				_ -> find_rank_reward(URank, RankId + 1)
			end;
		_ -> data_limitboss:get_base_reward()
	end.

delay_kick_all_usr({ScenePid, Scene}) ->
	?debug("delay_kick_all_usr:~p", [Scene]),
	fun_scene_mng:set_scene_to_kick_state(ScenePid),
	ok.