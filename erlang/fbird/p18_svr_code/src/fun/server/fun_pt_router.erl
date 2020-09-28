%% @doc agent消息路由处理
-module (fun_pt_router).
-include("common.hrl"). 
-export([process_pt/4]).

process_pt(pt_usr_enter_scene_b003,Seq,Pt,Sid) -> 
	mod_scene_api:process_agent_pt(pt_usr_enter_scene_b003,Seq,Pt,Sid);

process_pt(pt_load_scene_finish_b005,Seq,Pt,Sid) ->
	mod_scene_api:process_agent_pt(pt_load_scene_finish_b005,Seq,Pt,Sid);

process_pt(pt_client_error_report_f130,_Seq,Pt,_Sid) ->
	case get(global_tmp) of
		[{_, 1}] -> 
			Uid     = get(uid),
			Msg     = Pt#pt_client_error_report.msg,
			SceneLv = mod_scene_lev:get_curr_scene_lv(Uid),
			?log_trace("uid:~p at barrier:~p report error:~s", [Uid, SceneLv, Msg]);
		_ -> skip
	end;

process_pt(pt_action_d002,Seq,Pt,Sid) -> 
	% ?debug("get action Pt = ~p,Sid = ~p",[Pt,Sid]),
	Uid = get(uid),
	Action = Pt#pt_action.action,
	% ?debug("-----Action=~p",[Action]),
	case Action of
		?ACTION_REQ_GUILD_TEC_INFO -> mod_guild_technology:req_info(Uid, Sid, Seq);
		?ACTION_REQ_ENTER_EXPEDITION -> mod_hero_expedition:req_enter(Uid, Sid, Seq);
		?ACTION_REQ_EXPEDITION_INFO -> mod_hero_expedition:req_info(Uid, Sid, Seq);
		?ACTION_REQ_EXPEDITION_DO -> mod_hero_expedition:req_do_event(Uid, Sid, Seq);
		?ACTION_REQ_EXPEDITION_GIVE_UP -> mod_hero_expedition:req_give_up_event(Uid, Sid, Seq);
		?ACTION_REQ_RECOMMEND_GUILDS -> fun_guild:req_recommend_guilds(Uid, Sid, Seq);
		?ACTION_REQ_MINING_INSPIRE -> fun_mining:req_inspire(Uid, Sid, Seq);
		?ACTION_REQ_MINING_BUY_GRAB_TIMES -> fun_mining:req_bug_grab_times(Uid, Sid, Seq);
		?ACTION_REQ_MINING_LIST -> fun_mining_service:req_mining_list(Uid, Sid, Seq);
		?ACTION_REQ_MINING_INFO -> fun_mining:send_info_to_client(Uid, Sid, Seq);
		?ACTION_REQ_MINING_BEGIN -> fun_mining:req_mining(Uid, Sid, Seq);
		?ACTION_REQ_PEARL_INFO -> fun_element_pearl:send_info_to_client(Uid, Sid, Seq);
		?ACTION_REQ_TALENT_INFO -> fun_talent:send_info_to_client(Uid, Sid, Seq);
		?ACTION_REQ_TALENT_UP_AWAKEN -> fun_talent:req_up_awaken(Uid, Sid, Seq);
		?ACTION_REQ_PET_INFO -> fun_pet:send_info_to_client(Uid, Sid, Seq);
		?ACTION_REQ_PET_UP_STAGE -> fun_pet:req_up_stage(Uid, Sid, Seq);
		?ACTION_REQ_GGB_MY_TEAM -> fun_server_guild_battle:req_my_team_info(Uid, Sid, Seq);
		?ACTION_REQ_GGB_INFO -> fun_server_guild_battle:req_info(Uid, Sid, Seq);
		?ACTION_REQ_GGB_BATTLE_LOG -> fun_server_guild_battle:req_battle_log(Uid, Sid, Seq);
		?ACTION_REQ_GGB_INSPIRE -> fun_server_guild_battle:req_inspire(Uid, Sid, Seq);
		?ACTION_REQ_FETCH_RECHARGE_RETURN -> fun_cdkey:req_fetch_recharge_return(Uid, Sid, Seq);
		?ACTION_REQ_WORLDBOSS_INSPIRE_INFO -> fun_agent_inspire:req_inspire_info(Uid, Sid, Seq);
		?ACTION_REQ_WORLDBOSS_TIMES -> fun_agent_worldboss:req_times_info(Uid, Sid, Seq);
		?ACTION_REQ_WORLDBOSS_LIST -> fun_agent_worldboss:req_worldboss_info(Uid, Sid, Seq);
		?ACTION_REQ_GM_TREASURE_RECORDS -> gm_act_treasure:req_records(Uid, Sid, Seq);
		?ACTION_REQ_GROW_FUND_INFO -> fun_grow_fund:req_info(Uid, Sid, Seq);
		?ACTION_REQ_BUY_GROW_FUND -> fun_grow_fund:req_buy(Uid, Sid, Seq);
		?ACTION_REQ_FETCH_GROW_FUND -> fun_grow_fund:req_fetch(Uid, Sid, Seq);
		?ACTION_LAST_CALLED_HERO -> fun_entourage:req_last_called_hero(Uid, Sid, Seq);
		?ACTION_REQ_FRIENDS_APPLY_INFO-> fun_relation_ex:req_apply_list(Uid, Sid, Seq);

		?ACTION_REQ_HERALD->fun_herald:req_info(Uid, Sid, Seq);
		?ACTION_REQ_RELIFE->fun_relife:req_relife(Uid, Sid, Seq);
		?ACTION_REQ_ENTER_MILITARY_BOSS->fun_relife:req_enter_military_copy(Uid, Sid, Seq);
		?ACTION_REQ_RELIFE_TASK->fun_relife_task:req_relife_task(Uid, Sid, Seq);
		?ACTION_REQ_MEDICINE_BUFF->fun_medicine:send_info_to_client(Uid, Sid, Seq);
		?ACTION_REQ_DOWNLOAD_REWARD->fun_download_reward:req_reward(get(aid), Uid, Sid, Seq);

		?ACTION_GET_RIDE_INFO->
			fun_ride:send_ride_info_to_client(Uid, Sid, Seq);
		?ACTION_REQ_LOST_ITEM -> fun_lost_item:request_lost_item_date(Uid,Sid,Seq);
		?ACTION_REQ_MASTERY_DATA -> fun_mastery:req_mastery_data(Uid, Sid, Seq);
		?ACTION_ENTOURAGE_LIST -> fun_entourage:request_entourage_list(Uid,Sid,Seq);
		?ACTION_REQ_RECENT_CHAT -> gen_server:cast(chat_server, {req_recent_msg,Uid,Sid,Seq});
		?ACTION_TEAM_QUICK -> gen_server:cast(agent_mng, {action,?ACTION_TEAM_QUICK,Uid,Sid,Seq});
		?ACTION_TEAM_QUIT -> gen_server:cast(agent_mng, {action,?ACTION_TEAM_QUIT,Uid,Sid,Seq});
		?ACTION_ALL_ENTOURAGE_INFO->fun_entourage:request_all_entourage_info(Uid, Sid, Seq);
		?ACTION_ALL_GEM_DATA ->fun_gem:req_all_gem_data(Uid, Seq, Sid);
		?ACTION_REQ_COPY_TIMES -> fun_activity_copy:req_copy_times(Uid, Sid, Seq);
		?ACTION_REQ_COPY_OUT -> mod_scene_lev:req_copy_out(Uid, Sid, Seq);
		?ACTION_GUILD_LIST->gen_server:cast(agent_mng, {action,?ACTION_GUILD_LIST,Uid,Sid,Seq});
		?ACTION_ACTIVITY_INFO->fun_liveness:send_info_to_client(Uid, Sid);
		?ACTION_GUILD_ROUGH_INFO->gen_server:cast(agent_mng, {action,?ACTION_GUILD_ROUGH_INFO,Uid,Sid,Seq});
		?ACTION_CANCEL_COMBAT->fun_entourage:req_cancel_combat(Uid, Sid, Seq);
		?ACTION_GUILD_INFO->gen_server:cast(agent_mng, {action,?ACTION_GUILD_INFO,Uid,Sid,Seq});
		?ACTION_GUILD_COMMONALITY_INFO->gen_server:cast(agent_mng, {action,?ACTION_GUILD_COMMONALITY_INFO,Uid,Sid,Seq});
		?ACTION_GUILD_BUILDING_LIST->gen_server:cast(agent_mng, {action,?ACTION_GUILD_BUILDING_LIST,Uid,Sid,Seq});
		?ACTION_GUILD_DONATION_RECORD->gen_server:cast(agent_mng, {action,?ACTION_GUILD_DONATION_RECORD,Uid,Sid,Seq});
		?ACTION_GUILD_COPY_LIST ->gen_server:cast(agent_mng, {action,?ACTION_GUILD_COPY_LIST,Uid,Sid,Seq});
		?ACTION_GUILD_COPY_STATE -> gen_server:cast(agent_mng, {action,?ACTION_GUILD_COPY_STATE,Uid,Sid,Seq});
		?ACTION_GUILD_COPY_TROPHY->gen_server:cast(agent_mng, {action,?ACTION_GUILD_COPY_TROPHY,Uid,Sid,Seq}); 
		?ACTION_GET_FAST_TEAMS->gen_server:cast(agent_mng, {action,?ACTION_GET_FAST_TEAMS,Uid,Sid,Seq});
		?ACTION_REQ_MATCH_READY_CANCEL->gen_server:cast(agent_mng, {action,?ACTION_REQ_MATCH_READY_CANCEL,Uid,Sid,Seq});
		?ACTION_REQ_SUBMIT_READY -> gen_server:cast(agent_mng, {action,?ACTION_REQ_SUBMIT_READY,Uid,Sid,Seq});
		?ACTION_CHAPTER_INFO->fun_chapter:req_chapter_info(Sid, Uid, Seq);
		?ACTION_GUILD_APPLY_FOR_LIST->gen_server:cast(agent_mng, {action,?ACTION_GUILD_APPLY_FOR_LIST,Uid,Sid,Seq});
		% ?ACTION_REQ_BOSS_INFO -> gen_server:cast({global,scene_mng, {req_boss_info,Uid,Sid,get_boos_die_list(Uid),Seq});
		?ACTION_REQ_ARENA_INFO -> gen_server:cast(agent_mng, {action,?ACTION_REQ_ARENA_INFO,Uid,Sid,Seq});
		?ACTION_REQ_REFLUSH_CHALL -> gen_server:cast(agent_mng, {action,?ACTION_REQ_REFLUSH_CHALL,Uid,Sid,Seq});
		?ACTION_REQ_ARENA_RECORD -> gen_server:cast(agent_mng, {action,?ACTION_REQ_ARENA_RECORD,Uid,Sid,Seq});
		?ACTION_REQ_REFLUSH_ARENA_CD ->	gen_server:cast(agent_mng, {action,?ACTION_REQ_REFLUSH_ARENA_CD,Uid,Sid,Seq});
		?ACTION_GET_ACHIEVES->fun_achieve:get_achieves(Uid,Sid,Seq);
		?ACTION_SCENE_BRANCHING_INFO->gen_server:cast(agent_mng, {action,?ACTION_SCENE_BRANCHING_INFO,Uid,Sid,Seq});
		?ACTION_MODEL_CLOTHES_INFO->fun_item_model_clothes:req_model_clothes_info(Sid, Seq, Uid);
		?ACTION_MODEL_CLOTHES_UNFIX->fun_item_model_clothes:req_model_clothes_unfix(Sid, Uid, Seq);
		% ?ACTION_POINT_RESET->fun_paragon_level:req_reset_prop_point(Uid, Sid, Seq);
		% ?ACTION_ALL_POINT_INFO->fun_paragon_level:req_prop_point_info(Uid, Sid, Seq);
		?ACTION_ALL_VIP_INFO->fun_vip:req_vip_info(Uid, Sid, Seq);
		?ACTION_REQ_RECHARGE_DATA -> gen_server:cast(agent_mng, {action,?ACTION_REQ_RECHARGE_DATA,Uid,Sid,Seq});
		?ACTION_USE_ITEM_TIME ->fun_item_use:req_item_use_time(Sid, Uid, Seq);
		?ACTION_REQ_CAMP_LEADER_INFO -> gen_server:cast(agent_mng, {action,?ACTION_REQ_CAMP_LEADER_INFO,Uid,Sid,Seq});
		?ACTION_REQ_SYSTEM_TIME ->
			TimePt = #pt_system_time{
				time_zone = server_config:get_conf(timezone),
				time = util_time:unixtime()
			},
			?send(Sid,proto:pack(TimePt, Seq)),
			ok;
		?ACTION_BUY_COIN -> 
			fun_buy_coin:req_buy_coin(Uid, Sid, Seq);
		?ACTION_REQ_NATIONAL_WAR_CALL_RESPONSE ->fun_agent:send_to_scene({national_war_call_response, Uid,Sid,Seq});
		?ACTION_REQ_NATIONAL_WAR_FLY ->	fun_agent:send_to_scene({req_national_war_fly, Uid,Sid,Seq});
		?ACTION_REQ_NATIONAL_WAR_REC -> gen_server:cast(agent_mng, {action,?ACTION_REQ_NATIONAL_WAR_REC,Uid,Sid,Seq});		
		?ACTION_REQ_NATIONAL_WAR_DATA -> gen_server:cast(agent_mng, {action,?ACTION_REQ_NATIONAL_WAR_DATA,Uid,Sid,Seq});
		?ACTION_REQ_NATIONAL_WAR_SCROLLS_DATA -> gen_server:cast(agent_mng, {action,?ACTION_REQ_NATIONAL_WAR_SCROLLS_DATA,Uid,Sid,Seq});
		?ACTION_REQ_NATIONAL_WAR_START_TIME -> gen_server:cast(agent_mng, {action,?ACTION_REQ_NATIONAL_WAR_START_TIME,Uid,Sid,Seq});
		?ACTION_REQ_NATIONAL_WAR_TIPS ->fun_agent:send_to_scene({req_national_war_tips, Uid,Sid,Seq});
		?ACTION_GUILD_TASK_RESET->fun_task_guild:reset_reward(Sid, Uid, Seq);
		?ACTION_GUILD_TASK_A_KEY_ALL_STAR->fun_task_guild:a_key_full_star(Sid,Uid, Seq);
		?ACTION_GUILD_TASK_WHEEL_REWARD->fun_task_guild:wheel_reward(Sid, Uid, Seq);
		?ACTION_GUILD_TASK_INFO->fun_task_guild:send_guild_to_sid(Sid,Uid, Seq);
		?ACTION_GET_GS_REWARDS->fun_agent_property:get_fighting_rewards_info(Uid, Sid, Seq);
		?ACTION_OUT_STUCK -> fun_agent:out_stuck(Uid,Sid, Seq);  
		?ACTION_REQ_TEAM_WAR_PRE -> gen_server:cast(agent_mng, {action,?ACTION_REQ_TEAM_WAR_PRE,Uid,Sid,Seq});		
		?ACTION_WECHAT_REWARDS_CAN_GET->fun_wechat_share:req_wechat_share_info(Sid, Uid, Seq);
		?ACTION_WECHAT_REWARDS_GET->fun_wechat_share:req_wechat_share_rewards(Sid, Uid, Seq);
		?ACTION_WECHAT_SHARE->fun_wechat_share:req_add_wechat_share(Sid, Uid, Seq);
		?ACTION_REQ_SINGLE_RECHARGE -> gen_server:cast(agent_mng, {action,?ACTION_REQ_SINGLE_RECHARGE,Uid,Sid,Seq}); 
		?ACTION_REQ_ACC_RECHARGE -> fun_gm_activity_ex:send_info_to_client(Uid,Sid,?GM_ACTIVITY_ACC_RECHARGE); 
		?ACTION_REQ_ACC_COST -> fun_gm_activity_ex:send_info_to_client(Uid,Sid,?GM_ACTIVITY_ACC_COST);
		?ACTION_REQ_GM_ACT_DOUBLE -> fun_gm_activity_ex:send_info_to_client(Uid,Sid,?GM_ACTIVITY_DOUBLE_REWARD); 
		?ACTION_REQ_GM_ACT_DISCOUNT -> fun_gm_activity_ex:send_info_to_client(Uid,Sid,?GM_ACTIVITY_DISCOUNT); 
		?ACTION_REQ_GM_ACT_WEEK_TASK -> fun_gm_activity_ex:send_info_to_client(Uid,Sid,?GM_ACTIVITY_WEEK_TASK); 
		?ACTION_REQ_GM_ACT_SALE -> fun_gm_activity_ex:send_info_to_client(Uid,Sid,?GM_ACTIVITY_SALE); 
		?ACTION_REQ_GM_ACT_EXCHANGE -> fun_gm_activity_ex:send_info_to_client(Uid,Sid,?GM_ACTIVITY_EXCHANGE); 
		?ACTION_REQ_GM_ACT_DROP -> fun_gm_activity_ex:send_info_to_client(Uid,Sid,?GM_ACTIVITY_DROP); 
		?ACTION_REQ_DAILY_ACC_RECHARGE -> fun_gm_activity_ex:send_info_to_client(Uid,Sid,?GM_ACTIVITY_DAILY_ACC_RECHARGE); 
		?ACTION_REQ_DAILY_ACC_COST -> fun_gm_activity_ex:send_info_to_client(Uid,Sid,?GM_ACTIVITY_DAILY_ACC_COST);
		?ACTION_REQ_GM_TREASURE_INFO -> fun_gm_activity_ex:send_info_to_client(Uid,Sid,?GM_ACTIVITY_TREASURE); 
		?ACTION_REQ_GM_ACT_PACKAGE -> fun_gm_activity_ex:send_info_to_client(Uid,Sid,?GM_ACTIVITY_PACKAGE); 
		?ACTION_REQ_GM_ACT_DOUBLE_RECHARGE -> fun_gm_activity_ex:send_info_to_client(Uid,Sid,?GM_ACTIVITY_RESET_RECHARGE);
		?ACTION_REQ_GM_LIMIT_SUMMON_INFO -> fun_gm_activity_ex:send_info_to_client(Uid,Sid,?GM_ACTIVITY_LIMIT_SUMMON);
		?ACTION_REQ_GM_RANK_LV_INFO ->
			mod_msg:handle_to_agnetmng(fun_gm_activity_ex, {send_info_to_client2, Uid,Sid,?GM_ACTIVITY_RANK_LV}); 
			% fun_gm_activity_ex:send_info_to_client(Uid,Sid,?GM_ACTIVITY_RANK_LV); 
		?ACTION_REQ_CONTINUOUS_RECHARGE -> fun_gm_activity_ex:send_info_to_client(Uid,Sid,?GM_ACTIVITY_CONTINUOUS_RECHARGE);
		?ACTION_REQ_LIMIT_ACHIEVEMENT -> fun_gm_activity_ex:send_info_to_client(Uid,Sid,?GM_ACTIVITY_LIMIT_ACHIEVEMENT);
		?ACTION_REQ_GM_ACT_LIMIT_DOUBLE_RECHARGE -> fun_gm_activity_ex:send_info_to_client(Uid,Sid,?GM_ACTIVITY_DOUBLE_RECHARGE_TEMP);
		?ACTION_REQ_GM_ACT_RECHARGE_POINT -> fun_gm_activity_ex:send_info_to_client(Uid,Sid,?GM_ACTIVITY_RECHARGE_POINT);
		?ACTION_REQ_GM_ACT_LITERATURE_COLLECTION -> fun_gm_activity_ex:send_info_to_client(Uid,Sid,?GM_ACTIVITY_LITERATURE_COLLECTION);
		?ACTION_REQ_GM_ACT_LOTTERY_CAROUSEL -> fun_gm_activity_ex:send_info_to_client(Uid,Sid,?GM_ACTIVITY_LOTTERY_CAROUSEL);
		?ACTION_REQ_GM_ACT_RETURN_INVESTMENT -> fun_gm_activity_ex:send_info_to_client(Uid,Sid,?GM_ACTIVITY_RETURN_INVESTMENT);
		?ACTION_REQ_MYSTERY_GIFT_INFO -> fun_gm_activity_ex:send_info_to_client(Uid,Sid,?GM_ACTIVITY_MYSTERY_GIFT);
		?ACTION_REQ_GM_ACT_SINGLE_RECHARGE -> fun_gm_activity_ex:send_info_to_client(Uid,Sid,?GM_ACTIVITY_SINGLE_RECHARGE);
		?ACTION_REQ_GM_ACT_ACC_LOGIN -> fun_gm_activity_ex:send_info_to_client(Uid,Sid,?GM_ACTIVITY_ACC_LOGIN);
		?ACTION_REQ_GM_ACT_POINT_PACKAGE -> fun_gm_activity_ex:send_info_to_client(Uid,Sid,?GM_ACTIVITY_POINT_PACKAGE);
		?ACTION_REQ_GM_ACT_DIAMOND_PACKAGE -> fun_gm_activity_ex:send_info_to_client(Uid,Sid,?GM_ACTIVITY_DIAMOND_PACKAGE);
		?ACTION_REQ_GM_ACT_RMB_PACKAGE -> fun_gm_activity_ex:send_info_to_client(Uid,Sid,?GM_ACTIVITY_RMB_PACKAGE);
		?ACTION_REQ_GM_ACT_TURMTABLE -> fun_gm_activity_ex:send_info_to_client(Uid,Sid,?GM_ACTIVITY_TURNTANLE);
		?ACTION_REQ_REPEAT_RECHARGE -> gen_server:cast(agent_mng, {action,?ACTION_REQ_REPEAT_RECHARGE,Uid,Sid,Seq}); 
		?ACTION_REQ_GIFT_RECHARGE -> gen_server:cast(agent_mng, {action,?ACTION_REQ_GIFT_RECHARGE,Uid,Sid,Seq}); 
		?ACTION_REQ_EXCHANGE -> gen_server:cast(agent_mng, {action,?ACTION_REQ_EXCHANGE,Uid,Sid,Seq}); 
		?ACTION_REQ_LOGINACT -> gen_server:cast(agent_mng, {action,?ACTION_REQ_LOGINACT,Uid,Sid,Seq}); 
		?ACTION_GUILD_POST->gen_server:cast(agent_mng, {action,?ACTION_GUILD_POST,Uid,Sid,Seq});
		?ACTION_GET_GAMBLE_RECORD->gen_server:cast(agent_mng, {action,?ACTION_GET_GAMBLE_RECORD,Uid,Sid,Seq});
		?ACTION_REQ_WAR_DEMAGE_DATA ->
			fun_agent:send_to_scene({req_war_demage_data, Uid,Seq});
		?ACTION_GUILD_IMPEACH_PRESIDENT->gen_server:cast(agent_mng, {action,?ACTION_GUILD_IMPEACH_PRESIDENT,Uid,Sid,Seq});
		?ACTION_REQ_OPEN_SVR_FIVE_TIME -> gen_server:cast(agent_mng, {action,?ACTION_REQ_OPEN_SVR_FIVE_TIME,Uid,Sid,Seq});
		?ACTION_REQ_OPEN_SVR_LIMIT_TIME -> gen_server:cast(agent_mng, {action,?ACTION_REQ_OPEN_SVR_LIMIT_TIME,Uid,Sid,Seq});
		?REQ_SEVEN_DAY_REWARDS_DATE->fun_seven_day_target:req_seven_day_rewards_date(Sid, Uid, Seq);
		?ACTION_REQ_GUILD_RENT_ENTOURAGE -> gen_server:cast(agent_mng, {action,?ACTION_REQ_GUILD_RENT_ENTOURAGE,Uid,Sid,Seq});
		?ACTION_REQ_REFLUSH_EXPED -> gen_server:cast(agent_mng, {action,?ACTION_REQ_REFLUSH_EXPED,Uid,Sid,Seq});
		?ACTION_REQ_RENT_ENTOURAGE_LIST -> gen_server:cast(agent_mng, {action,?ACTION_REQ_RENT_ENTOURAGE_LIST,Uid,Sid,Seq}); 
		?REQ_GRAB_RED_PACKET-> gen_server:cast(agent_mng, {action,?REQ_GRAB_RED_PACKET,Uid,Sid,Seq});
		?REQ_RED_PACKET_INFO->gen_server:cast(agent_mng, {action,?REQ_RED_PACKET_INFO,Uid,Sid,Seq});
		?REQ_GUILD_RANKLIST_REWARDS->gen_server:cast(agent_mng, {action,?REQ_GUILD_RANKLIST_REWARDS,Uid,Sid,Seq});
		?REQ_GUILD_TEAM_COPY_INFO->gen_server:cast(agent_mng, {action,?REQ_GUILD_TEAM_COPY_INFO,Uid,Sid,Seq});
		?REQ_GUILD_TEAM_INFO->gen_server:cast(agent_mng, {action,?REQ_GUILD_TEAM_INFO,Uid,Sid,Seq});
		?REQ_GUILD_COPY_JOIN->gen_server:cast(agent_mng, {action,?REQ_GUILD_COPY_JOIN,Uid,Sid,Seq});
		?REQ_GUILD_TEAM_COPY_INFO_DISSOLVE->gen_server:cast(agent_mng, {action,?REQ_GUILD_TEAM_COPY_INFO_DISSOLVE,Uid,Sid,Seq});
		?REQ_GUILD_TEAM_COPY_INFO_QUIT->gen_server:cast(agent_mng, {action,?REQ_GUILD_TEAM_COPY_INFO_QUIT,Uid,Sid,Seq});
		?REQ_GUILD_TEAM_COPY_AGREE->gen_server:cast(agent_mng, {action,?REQ_GUILD_TEAM_COPY_AGREE,Uid,Sid,Seq});	
		?ACTION_REQ_CLIMB_TOWER_RESTART -> fun_agent:send_to_scene({req_climb_tower_restart,Uid,Sid,Seq});
		?REQ_GUILD_TEAM_COPY_RESURGENCE->fun_agent:send_to_scene({req_revive, Uid,Seq});
		?REQ_SEND_RED_PACKET_INFO->gen_server:cast(agent_mng, {action,?REQ_SEND_RED_PACKET_INFO,Uid,Sid,Seq});
		?REQ_ABYSS_BOX_INFO->fun_agent:send_to_scene({abyss_box_info,Uid,Sid,Seq});
		?ACTION_REQ_REQ_PWD_RED_INFO -> gen_server:cast(agent_mng, {action,?ACTION_REQ_REQ_PWD_RED_INFO,Uid,Sid,Seq});
		?ACTION_REQ_ENEMY_INFO-> gen_server:cast(agent_mng, {action,?ACTION_REQ_ENEMY_INFO,Uid,Sid,Seq});
		?ACTION_ACTIVITY_TREASURE_TIME->fun_activity_treasure:req_activity_treasure(Uid, Sid, Seq);
		?ACTION_ACTIVITY_TREASURE_ITEM_INFO->fun_activity_treasure:req_activity_treasure_item_list(Uid, Sid, Seq);
		?ACTION_ALL_PEOPLE_INFO->fun_activity_treasure:req_all_people_info(Uid, Sid, Seq);
		?ACTION_EXTREME_LUXURY_GIFT->gen_server:cast(agent_mng, {action,?ACTION_EXTREME_LUXURY_GIFT,Uid,Sid,Seq});
		?ACTION_ACTIVITY_TREASURE_TIMES->fun_activity_treasure:req_treasure_times(Uid, Sid, Seq);
		?ACTION_REQ_USR_HEAD->fun_usr_head:req_usr_head(Uid,Sid,Seq);
		?ACTION_RECHARGE_ACTIVITY_INFO->
			gen_server:cast(agent_mng, {action,?ACTION_RECHARGE_ACTIVITY_INFO,Uid,Sid,Seq});
		?ACTION_ACT_GLOBAL_RECHARGE->
			mod_msg:handle_to_toplist_mng({req_activity_global_recharge_info, Sid, Uid, Seq});
		?ACTION_ACT_GLOBAL_CONSUME->
			mod_msg:handle_to_toplist_mng({req_activity_global_consume_info, Sid, Uid, Seq});
		?ACTION_ACT_GLOBAL_RECHARGEJIFEN->
			mod_msg:handle_to_toplist_mng({req_activity_global_rechargejifen_info, Sid, Uid, Seq});
		?ACTION_ACT_GLOBAL_CONSUMEJIFEN->
			mod_msg:handle_to_toplist_mng({req_activity_global_consumejifen_info, Sid, Uid, Seq});
		?ACTION_CONSUME_ACTIVITY_INFO->
				gen_server:cast(agent_mng, {action,?ACTION_CONSUME_ACTIVITY_INFO,Uid,Sid,Seq});
		?ACTION_REQ_CONTINU_RECHARGE_DATA-> gen_server:cast(agent_mng, {action,?ACTION_REQ_CONTINU_RECHARGE_DATA,Uid,Sid,Seq});
		?ACTION_REQ_TURNING_WHEEL -> gen_server:cast(agent_mng, {action,?ACTION_REQ_TURNING_WHEEL,Uid,Sid,Seq});
		?ACTION_REQ_TURNING_WHEEL_HIDE -> gen_server:cast(agent_mng, {action,?ACTION_REQ_TURNING_WHEEL_HIDE,Uid,Sid,Seq});
		?ACTION_REQ_CONTINU_RECHARGE_HIDE -> gen_server:cast(agent_mng, {action,?ACTION_REQ_CONTINU_RECHARGE_HIDE,Uid,Sid,Seq});
		?ACTION_REQ_RECHARGE_PACKAGE_DATA -> gen_server:cast(agent_mng, {action,?ACTION_REQ_RECHARGE_PACKAGE_DATA,Uid,Sid,Seq});
		?ACTION_REQ_DRESS_SUIT_DATA -> fun_dress_suit:req_own_dress_suit(Uid, Sid, Seq);
		?ACTION_REQ_GLORY_SWORD_LEV->fun_glory_sword:req_glory_sword_lev(Uid, Sid, Seq);
		?ACTION_REQ_UPDATE_GLORY_SWORD->fun_glory_sword:req_update_glory_sword(Uid, Sid, Seq);
		?ACTION_REQ_GET_SALARY ->gen_server:cast(agent_mng, {action,?ACTION_REQ_GET_SALARY,Uid,Sid,Seq});
		?ACTION_REQ_BUY_GUILD_INSPIRE -> fun_guild_copy:req_buy_inspire_times(Uid,Sid,Seq);
		?ACTION_REQ_TASK_STEP_INFO -> fun_task_step:req_info(Uid, Sid, Seq);
		?ACTION_REQ_GUILD_STONE_INFO ->mod_msg:send_to_agnetmng({send_hunstone_info, Uid, Sid, Seq});
		?ACTION_REQ_MEETING_HELP -> fun_family:req_meeting_help(Uid, Sid, Seq);
		?ACTION_REQ_BUY_ARTIFACT_FAST -> fun_artifact_fast:req_buy(Uid, Sid, Seq);
		?ACTION_REQ_RANDOM_TASK -> fun_random_task:req_random_task(Uid,Sid,Seq);
		?ACTION_REQ_TASK_REWARD -> fun_random_task:req_get_task_reward(Uid,Sid,Seq);
		?ACTION_REQ_GIVE_UP_TASK -> fun_random_task:req_give_up_task(Uid,Sid,Seq);
		?ACTION_REQ_SYSTEM_ACTIVITY_INFO -> fun_system_activity:req_system_act_info(Uid, Sid, Seq);
		?ACTION_REQ_CHARGE_CARD_INFO -> fun_charge_active:req_info(Uid, Sid, Seq);
		?ACTION_REQ_REVIVE -> fun_revive:req_revive(Uid, Sid, Seq);
		?ACTION_REQ_REVIVE_NOT_PLACE -> fun_revive:req_not_revive(Uid, Sid, Seq);
		?ACTION_REQ_REFRESH_GROW_FUND -> fun_grow_fund:req_refresh(Uid, Sid, Seq);
		?ACTION_RE_ENTOURAGE_COMBAT -> fun_entourage:req_re_entourage_combat(Uid,Sid,Seq);
		?ACTION_REQ_ARENA_GUARD_ENTOURAGE -> fun_entourage:req_arena_guard_entourage(Uid,Sid,Seq);
		?ACTION_REQ_RECRUITING_MEMBERS -> gen_server:cast(agent_mng, {action,?ACTION_REQ_RECRUITING_MEMBERS,Uid,Sid,Seq});
		?ACTION_REQ_BUY_GUILD_TIMES -> fun_guild_copy:req_buy_times(Uid,Sid,Seq);
		?ACTION_REQ_WORLDLEVEL_INFO -> fun_worldlevel:req_worldlevel_info(Uid,Sid,Seq);
		?ACTION_REQ_GUILD_BLESSING_INFO -> fun_guild_extra:req_blessing_info(Uid,Sid,Seq);
		?ACTION_REQ_GUILD_BLESSING -> fun_guild_extra:req_guild_blessing(Uid,Sid,Seq);
		?ACTION_REQ_GUILD_LOG -> gen_server:cast(agent_mng, {action,?ACTION_REQ_GUILD_LOG,Uid,Sid,Seq});
		?ACTION_REQ_GLOBAL_ARENA_INFO -> fun_global_arena:req_arena_info(Uid,Sid,Seq);
		?ACTION_REQ_BUY_GLOBAL_ARENA_TIME -> fun_global_arena:req_buy_arena_times(Uid,Sid,Seq);
		?ACTION_REQ_GLOBAL_ARENA_MATCH_START -> fun_global_arena:req_start_global_arena(Uid,Sid,Seq);
		?ACTION_REQ_GLOBAL_ARENA_MATCH_END -> fun_global_arena:req_end_global_arena(Uid,Sid,Seq);
		?ACTION_REQ_FETVH_VIP_DAILY_REWARD -> fun_vip:req_fetch_daily_reward(Uid,Sid,Seq);
		?ACTION_REQ_MAZE_INFO -> fun_maze:req_maze_info(Uid,Sid,Seq);
		?ACTION_REQ_MAZE_POWER -> fun_maze:req_buy_maze_times(Uid,Sid,Seq);
		?ACTION_REQ_MAZE_INSPARE -> fun_maze:req_buy_maze_inspare(Uid,Sid,Seq);
		?ACTION_REQ_MAZE_EXPLORE -> fun_maze:req_maze_explore(Uid,Sid,Seq);
		?ACTION_REQ_MAZE_SETTLE -> fun_maze:req_maze_settle(Uid,Sid,Seq);
		?ACTION_REQ_MAZE_STEP_REWARD -> fun_maze:req_maze_step_reward(Uid,Sid,Seq);
		?ACTION_REQ_MAZE_RANKLIST -> fun_maze:req_maze_ranklist_info(Uid,Sid,Seq);
		?ACTION_REQ_SAILING_INFO -> fun_server_uncharter_water:req_sailing_info(Uid,Sid,Seq);
		?ACTION_REQ_SAILING_GUARD_INFO -> fun_server_uncharter_water:req_sailing_guard_info(Uid,Sid,Seq);
		?ACTION_REQ_SAILING_BUY_TIME -> fun_server_uncharter_water:req_sailing_buy_time(Uid,Sid,Seq);
		?ACTION_REQ_SAILING_INSPIRE -> fun_server_uncharter_water:req_sailing_buy_inspire(Uid,Sid,Seq);
		?ACTION_REQ_SAILING_GUARD_FROM_GUILD -> fun_server_uncharter_water:req_sailing_help(Uid,Sid,Seq);
		?ACTION_REQ_REFRESH_SAILING_PLUNDER -> fun_server_uncharter_water:req_refresh_sailing_plunder(Uid,Sid,Seq);
		?ACTION_REQ_SAILING_REWARD -> fun_server_uncharter_water:req_sailing_reward(Uid,Sid,Seq);
		?ACTION_REQ_MELLEBOSS_INFO -> fun_agent_meleeboss:req_meleeboss_info(Uid,Sid,Seq);
		?ACTION_REQ_BUY_MELLEBOSS_TIME -> fun_agent_meleeboss:req_buy_meleeboss_times(Uid,Sid,Seq);
		?ACTION_REQ_ATTACT_MELLEBOSS_OWNER -> fun_agent_meleeboss:req_attact_meleeboss_owner(Uid,Sid,Seq);
		?ACTION_REQ_HEAD_LEV_INFO -> fun_usr_head:req_head_lev_info(Uid,Sid,Seq);
		?ACTION_REQ_HEAD_SUIT_INFO -> fun_usr_head:req_head_suit_info(Uid,Sid,Seq);
		?ACTION_REQ_GUILD_IMPEACH -> gen_server:cast(agent_mng, {action,?ACTION_REQ_GUILD_IMPEACH,Uid,Sid,Seq});
		?ACTION_REQ_RANDOM_PACKAGE_INFO -> fun_random_gift_package:req_package_info(Uid,Sid,Seq);
		?ACTION_REQ_RANDOM_PACKAGE_REWARD -> fun_random_gift_package:req_package_reward(Uid,Sid,Seq);
		?ACTION_REQ_LEGENDARY_LEVEL_INFO -> fun_paragon_level:req_legendary_level_info(Uid,Sid,Seq);
		?ACTION_REQ_UP_LEGENDARY_LEVEL -> fun_paragon_level:req_update_legendary_lev(Uid,Sid,Seq);
		?ACTION_REQ_LEGENDARY_EXP_INFO -> fun_paragon_level:req_legendary_exp_info(Uid,Sid,Seq);
		?ACTION_REQ_ARENA_SEASON_INFO -> gen_server:cast(agent_mng, {action,?ACTION_REQ_ARENA_SEASON_INFO,Uid,Sid,Seq});
		?ACTION_REQ_GM_ACTIVITY -> fun_gm_activity_ex:req_activity_info(Uid,Sid,Seq);
		?ACTION_REQ_REFRESH_TURMTABLE ->
			case fun_gm_activity_ex:find_open_activity(?GM_ACTIVITY_TURNTANLE) of
				{true, ActivityRec} -> gm_act_turntable:req_refresh(Uid,Sid,ActivityRec);
				_ -> skip
			end;
		%% P18 NEW
		?ACTION_REQ_ENTER_MAIN -> mod_scene_api:enter_stage(Uid,Sid,Seq);
		?ACTION_REQ_MAIN_MOVE -> mod_scene_lev:agent_move_pos(Uid,Sid,Seq);
		?ACTION_REQ_MAIN_ATTACK -> mod_scene_lev:agent_atk_boss(Uid,Sid,Seq);
		?ACTION_REQ_MAIN_RUN_AWAY -> mod_scene_lev:main_scene_lose(Uid,Sid,Seq);
		?ACTION_REQ_ARNEA_INFO -> fun_arena:req_arena_info(Uid,Sid,Seq);
		?ACTION_REQ_ARENA_CHALLENGE_INFO -> fun_arena:req_arena_challenge_info(Uid, Sid, Seq);
		?ACTION_MODULE_DATAS -> fun_agent:req_module_datas(Uid, Sid, Seq);
		?ACTION_REQ_TIME_REEWARD_INFO -> mod_time_reward:req_time_reward_info(Uid, Sid, Seq);
		?ACTION_REQ_FETCH_TIME_REEWARD -> mod_time_reward:req_fetch_time_reward(Uid, Sid, Seq);
		?ACTION_REQ_ENTOURAGE_ILLUSTRATION -> fun_entourage:req_entourage_illustration(Uid, Sid, Seq);
		?ACTION_REQ_SHENQI_ILLUSTRATION -> fun_shenqi:req_shenqi_illustration(Uid, Sid, Seq);
		?ACTION_REQ_SUBSTITUTION_RESULT -> fun_entourage_substitution:req_substitution_result(Uid, Sid, Seq);
		?ACTION_REQ_ENERGY_DRAW -> fun_draw:req_energy_draw(Uid, Sid, Seq);
		?ACTION_REQ_STORE_INFO -> fun_store:req_store_info(Uid, Sid, Seq);
		?ACTION_REQ_NORMAL_TURNTABLE_INFO -> mod_turntable:req_normal_turntable_info(Uid, Sid, Seq);
		?ACTION_REQ_DRAW_HIGH_TURNTABLE -> mod_turntable:req_draw_high_turntable(Uid, Sid, Seq);
		?ACTION_REQ_REFRESH_TURNTABLE -> mod_turntable:req_refresh_turntable(Uid, Sid, Seq);
		?ACTION_REQ_FRIEND_INFO -> gen_server:cast(fun_relation_srv, {action, ?ACTION_REQ_FRIEND_INFO, Uid, Sid, Seq});
		?ACTION_REQ_ONE_DELETE_FRIEND_APPLY -> gen_server:cast(fun_relation_srv, {action, ?ACTION_REQ_ONE_DELETE_FRIEND_APPLY, Uid, Sid, Seq});
		?ACTION_REQ_RECOMMEND_LIST -> gen_server:cast(fun_relation_srv, {action, ?ACTION_REQ_RECOMMEND_LIST, Uid, Sid, Seq});
		?ACTION_REQ_OFFLINE_REWARD -> fun_offline_reward:req_offline_reward(Uid, Sid, Seq);
		?ACTION_REQ_OFFLINE_INFO -> fun_offline_reward:req_offline_info(Uid, Sid, Seq);
		?ACTION_REQ_MAIN_TASK_REWARD -> fun_main_task:req_task_reward(Uid, Sid, Seq);
		?ACTION_REQ_CHAPTER_REWARD -> fun_main_task:req_chapter_rewards(Uid, Sid, Seq);
		?ACTION_REQ_DAILY_ALL_REWARD -> fun_daily_task:req_all_rewards(Uid, Sid, Seq);
		?ACTION_REQ_SIGN -> fun_sign:req_sign(Uid, Sid, Seq);
		_ ->
			?ERROR("pt_action_d002, action:~p unused", [Action])
	end;
process_pt(pt_action_int_d003,Seq,Pt,Sid) ->
	Action = Pt#pt_action_int.action,
	Data = Pt#pt_action_int.data,
	Uid = get(uid),
	case Action of
		?ACTION_REQ_GUILD_TEC_UP_LV -> mod_guild_technology:req_up_lv(Uid, Sid, Seq, Data);
		?ACTION_REQ_GUILD_TEC_RESET -> mod_guild_technology:req_reset(Uid, Sid, Seq, Data);
		?ACTION_REQ_ITEM_DETAIL_INFO -> fun_item:req_item_detail_info(Uid, Sid, Seq, Data);
		?ACTION_REQ_SET_GUIDE -> fun_agent:save_guide_code(Uid, Data);
		?ACTION_REQ_EXPEDITION_UNLOCK_POS -> mod_hero_expedition:req_unlock_next_pos(Uid, Sid, Seq, Data);
		?ACTION_REQ_UNLOAD_ALL_FUWEN -> mod_fuwen_equip:req_unload_all(Uid, Sid, Seq, Data);
		?ACTION_REQ_STRENGTHEN_FUWEN -> mod_fuwen_equip:req_strengthen(Uid, Sid, Seq, Data);
		?ACTION_REQ_CHANGE_GUILD_NOTICE->gen_server:cast(agent_mng, {action_int,?ACTION_REQ_CHANGE_GUILD_NOTICE,Uid,Sid,Seq,Data});
		?ACTION_REQ_SHENQI_UP_LV -> fun_shenqi:req_up_shenqi(Uid, Sid, Seq, Data);
		?ACTION_REQ_MINING_GRAB -> fun_mining:req_grab(Uid, Sid, Seq, Data);
		?ACTION_REQ_HERO_ATTR -> fun_entourage:req_attr_info(Uid, Sid, Seq, Data);
		?ACTION_REQ_MINING_EXCHANGE -> fun_mining:req_exchange(Uid, Sid, Seq, Data);
		?ACTION_REQ_PEARL_ACTIVE -> fun_element_pearl:req_active(Uid, Sid, Seq, Data);
		?ACTION_REQ_PEARL_UP -> fun_element_pearl:req_up_lv(Uid, Sid, Seq, Data);
		?ACTION_REQ_TALENT_UP_SKILL -> fun_talent:req_up_skill(Uid, Sid, Seq, Data);
		?ACTION_REQ_TALENT_DRAW -> fun_talent:req_draw(Uid, Sid, Seq, Data);
		?ACTION_REQ_PET_FOLLOW -> fun_pet:req_change_follow_pet(Uid, Sid, Seq, Data);
		?ACTION_REQ_PET_UP_LV -> fun_pet:req_up_lv(Uid, Sid, Seq, Data);
		?ACTION_REQ_GGB_USE_SHENQI -> fun_server_guild_battle:req_use_shenqi(Uid, Sid, Seq, Data);
		?ACTION_REQ_GGB_WATCH -> fun_server_guild_battle:req_watch(Uid, Sid, Seq, Data);
		?ACTION_REQ_GGB_CHANGE_STRATEGY -> fun_server_guild_battle:req_change_strategy(Uid, Sid, Seq, Data);
		?ACTION_REQ_GGB_GROUP -> fun_server_guild_battle:req_group(Uid, Sid, Seq, Data);
		?ACTION_REQ_ENTER_WORLDBOSS -> 
			gen_server:cast(agent_mng, {action_int,?ACTION_REQ_ENTER_WORLDBOSS,Uid,Sid,Seq,Data});
		?ACTION_REQ_BUY_DUNGEONS_TIMES -> fun_activity_copy:req_buy_times(Uid, Sid, Seq, Data);
		?ACTION_REQ_BARRIER_REWARD_INFO -> fun_barrier_rewards:req_info(Uid, Sid, Seq, Data);
		?ACTION_REQ_GM_OPEN_TREASURE -> gm_act_treasure:open_treasure(Uid, Sid, Data);
		?ACTION_REQ_HERALD_REWARD->fun_herald:req_reward(Uid, Sid, Seq, Data);
		?ACTION_REQ_CHANGE_HEAD->fun_usr_head:req_change_head(Uid,Sid,Seq,Data);	
		?ACTION_REQ_SEVEN_DAY_STATE_REWARD->fun_seven_day_target:req_day_state_reward(Uid, Sid, Seq, Data);
		?ACTION_ON_OFF_RIDING->fun_ride:on_off_ride(Uid, Sid, Seq, Data);
        ?ACTION_RIDE_EQU_UP->fun_ride:ride_equ_up(Uid, Sid, Seq, Data);
        ?ACTION_CHANGE_RIDE_SKIN->fun_ride:ride_change_skin(Uid, Sid, Seq, Data);
		?ACTION_FEED_RIDE->fun_ride:feed_ride(Uid, Sid, Seq, Data);
		?ACTION_RIDE_AWAKE->fun_ride:ride_awake(Uid,Sid,Seq,Data);
		?ACTION_DESTROY_ITEM -> fun_item:destroy_item(Uid,Sid,Data,Seq);
		?ACTION_GET_LOST_ITEM -> fun_lost_item:request_get_lost_item(Uid,Sid,Seq,Data);
		?ACTION_UP_LOST_ITEM_LEV -> fun_lost_item:lost_item_up_lev(Uid,Sid,Seq,Data);
		?ACTION_REQ_UP_MASTERY_LEV -> fun_mastery:req_up_mastery_lev(Uid, Sid, Seq, Data);
		?ACTION_ACT_LOST_ITEM -> fun_lost_item:request_activate_lost_item(Uid,Sid,Seq,Data);
		?ACTION_NO_ACT_LOST_ITEM -> fun_lost_item:request_no_activate_lost_item(Uid,Sid,Seq,Data);
		?ACTION_ENTOURAGE_INFO ->fun_entourage:request_entourage_info(Uid,Sid,Seq,Data);
		?ACTION_ENTOURAGE_ACTIVATE->fun_entourage:request_activate_entourage(Uid,Sid,Seq,Data);
		?ACTION_ENTOURAGE_STAR->fun_entourage:request_entourage_star(Uid,Sid,Data,Seq);
		?ACTION_ITEM_DESTROY->fun_item:destroy_item(Uid,Sid,Data,Seq);
		?ACTION_ITEM_DISCHARGE_EQUIPMENT->fun_item:req_discharge_equipment(Sid, Uid, Data, Seq);
		?ACTION_TEAM_TARGET_CHG -> gen_server:cast(agent_mng, {action_int,?ACTION_TEAM_TARGET_CHG,Uid,Sid,Seq,Data});
		?ACTION_TEAM_ASK -> gen_server:cast(agent_mng, {action_int,?ACTION_TEAM_ASK,Uid,Sid,Seq,Data});
		?ACTION_TEAM_REQ -> gen_server:cast(agent_mng, {action_int,?ACTION_TEAM_REQ,Uid,Sid,Seq,Data});
		?ACTION_TEAM_LEADER_CHG -> gen_server:cast(agent_mng, {action_int,?ACTION_TEAM_LEADER_CHG,Uid,Sid,Seq,Data});
		?ACTION_ADD_GEM->Lev = util:get_lev_by_uid(Uid) ,fun_gem:add_lev_gem(Uid,Sid,Data,Lev);
 		?ACTION_REQ_LIVENESS_REWARD->fun_liveness:req_liveness_reward(Uid, Sid, Seq, Data);
		?ACTION_ACTIVITY_REWARDS->fun_liveness:fetch_reward(Uid, Sid, Data);		
		?ACTION_REVENGE->fun_relation_ex:req_revenge(Uid,Sid,Data,Seq);
		?ACTION_FRIENDS_THUMB_UP->gen_server:cast(agent_mng, {req_thumb_up,Sid,Uid,Data,Seq});
		?ACTION_REQ_COPY_ENTER -> fun_activity_copy:req_copy_enter(Uid, Sid, Seq, Data);
		?ACTION_REQ_ACTIVE_COPY -> fun_activity_copy:req_active_copy(Uid, Sid, Seq, Data);
		?ACTION_DONATE->gen_server:cast(agent_mng, {action_int,?ACTION_DONATE,Uid,Sid,Seq,Data}); 
		?ACTION_GUILD_QUIT->gen_server:cast(agent_mng, {action_int,?ACTION_GUILD_QUIT,Uid,Sid,Seq,Data});
		?ACTION_TEAM_KICK_USR ->gen_server:cast(agent_mng, {action_int,?ACTION_TEAM_KICK_USR,Uid,Sid,Seq,Data});
		?ACTION_GUILD_ROUGH_INFO->gen_server:cast(agent_mng, {action_int,?ACTION_GUILD_ROUGH_INFO,Uid,Sid,Seq,Data});
		?ACTION_REQ_READ_MAIL-> gen_server:cast(agent_mng, {action_int,?ACTION_REQ_READ_MAIL,Uid,Sid,Seq,Data});
		?ACTION_GUILD_COPY_OPEN ->gen_server:cast(agent_mng, {action_int,?ACTION_GUILD_COPY_OPEN,Uid,Sid,Seq,Data});
		?ACTION_GUILD_COPY_ENTER-> gen_server:cast(agent_mng, {action_int,?ACTION_GUILD_COPY_ENTER,Uid,Sid,Seq,Data});
		?ACTION_GUILD_COPY_RESET-> gen_server:cast(agent_mng, {action_int,?ACTION_GUILD_COPY_RESET,Uid,Sid,Seq,Data}); 
		?ACTION_GUILD_COPY_DAMAGE->gen_server:cast(agent_mng, {action_int,?ACTION_GUILD_COPY_DAMAGE,Uid,Sid,Seq,Data});
		?ACTION_EQUIP_INHERIT->fun_item:req_equipment_inherit(Sid,Uid, Data, Seq);
		?ACTION_LEV_REWARDS->fun_rewards:req_lev_rewards(Uid, Sid, Data, Seq);
		?ACTION_SEVEN_DAYS_REWARDS->fun_rewards:req_seven_days_rewards(Uid, Sid, Data, Seq);
		?ACTION_REWARDS_LIST->
			case Data of
				?REWARDS_ONLINE->
					fun_online_rewards:req_online_rewards_info(Uid, Sid, Seq);
				_-> 
					fun_rewards:req_rewards_type_list(Sid, Uid, Data, Seq)
			end;		
		?ACTION_CHAPTER_REWARDS->fun_chapter:req_chapter_rewards(Sid, Uid,Data,Seq);
		?ACTION_USE_INFO_EQUIP->gen_server:cast(agent_mng, {action_int,?ACTION_USE_INFO_EQUIP,Uid,Sid,Seq,Data});
		?ACTION_USE_INFO_PROP-> fun_other_usr_info:req_use_info_prop(Sid, Uid, Data, Seq);
		?ACTION_USE_INFO_ENTOURAGE->gen_server:cast(agent_mng, {action_int,?ACTION_USE_INFO_ENTOURAGE,Uid,Sid,Seq,Data});
		?ACTION_USE_INFO_LOST_ITEM->gen_server:cast(agent_mng, {action_int,?ACTION_USE_INFO_LOST_ITEM,Uid,Sid,Seq,Data});
		?ACTION_ITEM_INFO->fun_item:send_items_by_itemid(Uid, Sid, Data, Seq);
		?ACTION_SET_GUIDE_CODE ->fun_agent:set_guide_code(Uid,Seq,Data);
		?ACTION_GUILDNAME_ENTRY->gen_server:cast(agent_mng, {action_int,?ACTION_GUILDNAME_ENTRY,Uid,Sid,Seq,Data});
		?ACTION_ONLINE_REWARDS->fun_online_rewards:req_online_rewards(Uid, Sid, Data, Seq);
		?ACTION_GET_ACHIEVE_PRICE->fun_achieve:get_achieve_price(Uid, Sid, Seq, Data);
		?ACTION_SCENE_BRANCHING->gen_server:cast(agent_mng, {action_int,?ACTION_SCENE_BRANCHING,Uid,Sid,Seq,Data});
		?ACTION_MODEL_CLOTHES_DRESS->fun_item_model_clothes:req_model_clothes_dress(Sid, Uid, Seq, Data);
		?ACTION_UPGRADE_MODEL_CLOTHES->fun_item_model_clothes:req_upgrade_model_clothes(Sid, Uid, Data, Seq);
		?ACTION_VIP_REWARD->fun_vip:req_vip_rewards(Uid, Sid, Data, Seq);
		?ACTION_REQ_ORDER -> gen_server:cast(agent_mng, {req_gen_order,Uid,Data,Seq});
		?ACTION_REQ_NATIONAL_WAR_SCROLLS ->
			Num=fun_item:get_item_num_by_type(Uid, fun_national_war:get_scolls_type()),
			gen_server:cast(agent_mng, {req_present_scrolls,Uid,Sid,Seq,Data,Num});
		
		?ACTION_GET_GS_REWARDS_PRICE->fun_agent_property:get_fighting_rewards_price(Uid, Sid, Data, Seq);
		?ACTION_PICK_SINGLE_RECHARGE ->gen_server:cast(agent_mng, {action_int,?ACTION_PICK_SINGLE_RECHARGE,Uid,Sid,Seq,Data});
		?ACTION_REQ_FETCH_ACC_RECHARGE ->fun_gm_activity_ex:fetch_reward(Uid,Sid,?GM_ACTIVITY_ACC_RECHARGE,Data);
		?ACTION_REQ_FETCH_ACC_COST ->fun_gm_activity_ex:fetch_reward(Uid,Sid,?GM_ACTIVITY_ACC_COST,Data);
		?ACTION_REQ_GM_ACT_FETCH_WEEK_TASK ->fun_gm_activity_ex:fetch_reward(Uid,Sid,?GM_ACTIVITY_WEEK_TASK,Data);
		?ACTION_REQ_GM_ACT_FETCH_EXCHANGE ->fun_gm_activity_ex:fetch_reward(Uid,Sid,?GM_ACTIVITY_EXCHANGE,Data);
		?ACTION_REQ_GM_ACT_FETCH_SALE ->fun_gm_activity_ex:fetch_reward(Uid,Sid,?GM_ACTIVITY_SALE,Data);
		?ACTION_REQ_DAILY_FETCH_ACC_RECHARGE ->fun_gm_activity_ex:fetch_reward(Uid,Sid,?GM_ACTIVITY_DAILY_ACC_RECHARGE,Data);
		?ACTION_REQ_DAILY_FETCH_ACC_COST ->fun_gm_activity_ex:fetch_reward(Uid,Sid,?GM_ACTIVITY_DAILY_ACC_COST,Data);
		?ACTION_REQ_FETCH_MYSTERY_GIFT ->fun_gm_activity_ex:fetch_reward(Uid,Sid,?GM_ACTIVITY_MYSTERY_GIFT,Data);
		?ACTION_REQ_FETCH_CONTINUOUS_RECHARGE ->fun_gm_activity_ex:fetch_reward(Uid,Sid,?GM_ACTIVITY_CONTINUOUS_RECHARGE,Data);
		?ACTION_REQ_FETCH_LIMIT_ACHIEVEMENT ->fun_gm_activity_ex:fetch_reward(Uid,Sid,?GM_ACTIVITY_LIMIT_ACHIEVEMENT,Data);
		?ACTION_REQ_FETCH_RECHARGE_POINT_REWARD ->fun_gm_activity_ex:fetch_reward(Uid,Sid,?GM_ACTIVITY_RECHARGE_POINT,Data);
		?ACTION_REQ_FETCH_LITERATURE_COLLECTION ->fun_gm_activity_ex:fetch_reward(Uid,Sid,?GM_ACTIVITY_LITERATURE_COLLECTION,Data);
		?ACTION_REQ_FETCH_LOTTERY_CAROUSEL ->fun_gm_activity_ex:fetch_reward(Uid,Sid,?GM_ACTIVITY_LOTTERY_CAROUSEL,Data);
		?ACTION_REQ_FETCH_RETURN_INVESTMENT ->fun_gm_activity_ex:fetch_reward(Uid,Sid,?GM_ACTIVITY_RETURN_INVESTMENT,Data);
		?ACTION_REQ_FETCH_SINGLE_RECHARGE ->fun_gm_activity_ex:fetch_reward(Uid,Sid,?GM_ACTIVITY_SINGLE_RECHARGE,Data);
		?ACTION_REQ_FETCH_ACC_LOGIN ->fun_gm_activity_ex:fetch_reward(Uid,Sid,?GM_ACTIVITY_ACC_LOGIN,Data);
		?ACTION_REQ_FETCH_POINT_PACKAGE ->fun_gm_activity_ex:fetch_reward(Uid,Sid,?GM_ACTIVITY_POINT_PACKAGE,Data);
		?ACTION_REQ_FETCH_DIAMOND_PACKAGE ->fun_gm_activity_ex:fetch_reward(Uid,Sid,?GM_ACTIVITY_DIAMOND_PACKAGE,Data);
		?ACTION_REQ_FETCH_RMB_PACKAGE ->fun_gm_activity_ex:fetch_reward(Uid,Sid,?GM_ACTIVITY_RMB_PACKAGE,Data);
		?ACTION_REQ_FETCH_TURMTABLE ->fun_gm_activity_ex:fetch_reward(Uid,Sid,?GM_ACTIVITY_TURNTANLE,Data);
		?ACTION_PICK_REPEAT_RECHARGE ->gen_server:cast(agent_mng, {action_int,?ACTION_PICK_REPEAT_RECHARGE,Uid,Sid,Seq,Data});
		?ACTION_PICK_EXCHANGE ->gen_server:cast(agent_mng, {action_int,?ACTION_PICK_EXCHANGE,Uid,Sid,Seq,Data});		
        ?ACTION_REQ_INTO_WAR->gen_server:cast(agent_mng, {action_int,?ACTION_REQ_INTO_WAR,Uid,Sid,Seq,Data});
		?ACTION_REQ_INVITE_JOIN_GUILD->gen_server:cast(agent_mng, {action_int,?ACTION_REQ_INVITE_JOIN_GUILD,Uid,Sid,Seq,Data});
		?ACTION_OTHER_USR_INFO_MOUNT->gen_server:cast(agent_mng, {action_int,?ACTION_OTHER_USR_INFO_MOUNT,Uid,Sid,Seq,Data});
		?ACTION_OTHER_USR_INFO_PET->gen_server:cast(agent_mng, {action_int,?ACTION_OTHER_USR_INFO_PET,Uid,Sid,Seq,Data});
		?ACTION_GUILD_IMPEACH_PRESIDENT_POLL->gen_server:cast(agent_mng, {action_int,?ACTION_GUILD_IMPEACH_PRESIDENT_POLL,Uid,Sid,Seq,Data});
		?ACTION_REQ_TEAM_ENTER_WAR -> gen_server:cast(agent_mng, {action_int,?ACTION_REQ_TEAM_ENTER_WAR,Uid,Sid,Seq,Data});
		?ACTION_REQ_FLY_TO_BOSS -> 
			CanFly=case get(fly_to_boss) of
					   undefined -> true;
					   LastFlyTime when erlang:is_integer(LastFlyTime) ->
						   Now=util:unixtime(),
						   if
							   Now > LastFlyTime+20 -> true;
							   true -> false
						   end;
					   _ -> true
				   end,	
			case CanFly of
				true ->
					gen_server:cast(agent_mng, {action_int,?ACTION_REQ_FLY_TO_BOSS,Uid,Sid,Seq,Data}),
					put(fly_to_boss,util:unixtime());
				_ -> skip		
			end;
		?ACTION_REQ_OPEN_SVR_FIVE_DATA -> gen_server:cast(agent_mng, {action_int,?ACTION_REQ_OPEN_SVR_FIVE_DATA,Uid,Sid,Seq,Data});
		?REQ_SEVEN_DAY_ACTIVTY_DATE->fun_seven_day_target:req_seven_day_activty_date(Sid, Uid, Data, Seq);
		?REQ_SEVEN_DAY_TARGET_REWARDS->fun_seven_day_target:req_seven_day_target_rewards(Sid,  Uid, Seq, Data);
		?ACTION_REQ_RENT_ENTOURAGE -> gen_server:cast(agent_mng, {action_int,?ACTION_REQ_RENT_ENTOURAGE,Uid,Sid,Seq,Data});
		?ACTION_REQ_EXPED_TASK -> gen_server:cast(agent_mng, {action_int,?ACTION_REQ_EXPED_TASK,Uid,Sid,Seq,Data});
		?ACTION_REQ_EXPED_FINISH -> gen_server:cast(agent_mng, {action_int,?ACTION_REQ_EXPED_FINISH,Uid,Sid,Seq,Data}); 
		?REQ_SPEEDINESS_TEAM->gen_server:cast(agent_mng, {action_int,?REQ_SPEEDINESS_TEAM,Uid,Sid,Seq,Data});
		?REQ_GUILD_PAYOFF->gen_server:cast(agent_mng, {action_int,?REQ_GUILD_PAYOFF,Uid,Sid,Seq,Data});
		?REQ_GUILD_SET->gen_server:cast(agent_mng, {action_int,?REQ_GUILD_SET,Uid,Sid,Seq,Data});
		?REQ_GUILD_TEAM_COPY_INFO_WINKLE->gen_server:cast(agent_mng, {action_int,?REQ_GUILD_TEAM_COPY_INFO_WINKLE,Uid,Sid,Seq,Data});
		?REQ_CALL_UP_CONFIRM->gen_server:cast(agent_mng, {action_int,?REQ_CALL_UP_CONFIRM,Uid,Sid,Seq,Data});
		?ACTION_REQ_REQ_RECV_PWD_RED -> gen_server:cast(agent_mng, {action_int,?ACTION_REQ_REQ_RECV_PWD_RED,Uid,Sid,Seq,Data});
		?ACTION_OTHER_SKILL ->gen_server:cast(agent_mng, {action_int,?ACTION_OTHER_SKILL,Uid,Sid,Seq,Data});
		?ACTION_ACTIVITY_TREASURE->fun_activity_treasure:req_treasure_extract(Uid, Sid, Data, Seq);
		?ACTION_GET_ALL_PEOPLE->fun_activity_treasure:req_get_all_people(Uid, Sid, Data, Seq);
		?ACTION_REQ_CONTINU_RECHARGE_REWARD->gen_server:cast(agent_mng, {action_int,?ACTION_REQ_CONTINU_RECHARGE_REWARD,Uid,Sid,Seq,Data});
		?ACTION_REQ_LOST_ITEM_RECOVER -> fun_lost_item:request_lost_item_recover(Uid,Sid,Seq,Data);
		?ACTION_REQ_STORY_REWARD -> fun_story:req_story_reward(Uid, Sid, Seq, Data);
		?ACTION_REQ_ACTIVE_RIDE -> fun_ride:req_active_ride(Uid, Sid, Seq, Data);
		?ACTION_REQ_ACTIVE_CLOTHES -> fun_item_model_clothes:req_active_clothes(Uid, Sid, Seq, Data);
		?ACTION_REQ_GET_TASK_STEP_REWARD -> fun_task_step:req_reward(Uid, Sid, Seq, Data);
		?ACTION_REQ_GET_GUILD_STONE ->mod_msg:send_to_agnetmng({req_get_hunstone, Uid, Sid, Seq, Data});
		?ACTION_REQ_ONLINE_STATUS -> fun_agent:req_online_status(Sid, Seq, Data);
		?ACTION_REQ_HOME_BUILDING_LIST -> gen_server:cast(family_mng, {action_int,?ACTION_REQ_HOME_BUILDING_LIST,Uid,Sid,Seq,Data});
		?ACTION_REQ_HOME_BUILDING_DETAIL -> gen_server:cast(family_mng, {action_int,?ACTION_REQ_HOME_BUILDING_DETAIL,Uid,Sid,Seq,Data});
		?ACTION_REQ_HOME_BUILDING_UPGRADE -> fun_family:req_upgrade_building(Uid, Sid, Data, Seq);
		?ACTION_REQ_HOME_BUILDING_GATHER -> gen_server:cast(agent_mng, {action_int,?ACTION_REQ_HOME_BUILDING_GATHER,Uid,Sid,Seq,Data});
		?ACTION_REQ_MEETING -> fun_family:req_meeting(Uid,Sid,Data,Seq);
		?ACTION_REQ_HALL_REWARD -> gen_server:cast(family_mng, {action_int,?ACTION_REQ_HALL_REWARD,Uid,Sid,Seq,Data});
		?ACTION_REQ_HOME_BUILDING_FAST_UPGRADE -> fun_family:req_fast_end(Uid, Sid, Data, Seq);
		?ACTION_REQ_REMOVE_COMMANDER -> gen_server:cast(family_mng, {action_int,?ACTION_REQ_REMOVE_COMMANDER,Uid,Sid,Seq,Data});
		?ACTION_REQ_MINE_REWARD -> fun_family:req_mine_reward(Uid, Sid, Data, Seq);
		?ACTION_REQ_BUY_QUICK_MINE -> gen_server:cast(family_mng, {action_int,?ACTION_REQ_BUY_QUICK_MINE,Uid,Sid,Seq,Data});
		?ACTION_REQ_WORLDBOSS_INSPIRE -> fun_agent_inspire:req_inspire_buy(Uid, Sid, Seq, Data);
		?ACTION_REQ_ENTER_LIMITBOSS -> gen_server:cast(agent_mng, {action_int,?ACTION_REQ_ENTER_LIMITBOSS,Uid,Sid,Seq,Data});
		?ACTION_REQ_BUY_LIMITBOSS_TIMES -> fun_agent_limitboss:req_buy_times(Uid, Sid, Seq, Data);
		?ACTION_REQ_LIMITBOSS_TIMES -> fun_agent_limitboss:req_limitboss_time(Uid, Sid, Seq, Data);
		?ACTION_REQ_ENTOURAGE_PROPERTY -> fun_entourage:req_entourage_property(Uid, Sid, Data, Seq);
		?ACTION_REQ_WORLDLEVEL_REWARD -> fun_worldlevel:req_worldlevel_reward(Uid, Sid, Seq, Data);
		?ACTION_REQ_GLOBAL_ARENA_TASK_REWARD -> fun_global_arena:req_get_task_reward(Uid, Sid, Seq, Data);
		?ACTION_REQ_MAZE_EVENT -> fun_maze:req_maze_explore_event(Uid,Sid,Seq,Data);
		?ACTION_REQ_SAILING_GUARD->fun_server_uncharter_water:req_sailing_guard(Uid,Sid,Seq,Data);
		?ACTION_REQ_SAILING->fun_server_uncharter_water:req_sailing(Uid,Sid,Seq,Data);
		?ACTION_REQ_DRAW_LOTTERY_CAROUSEL->gm_act_lottery_carousel:req_draw(Uid,Sid,Seq,Data);
		?ACTION_REQ_REVIVE_NEW->fun_revive:req_revive_new(Uid,Sid,Seq,Data);
		?ACTION_REQ_NOT_REVIVE_NEW->fun_revive:req_not_revive_new(Uid,Sid,Seq,Data);
		?ACTION_REQ_UP_HEAD_LEV->fun_usr_head:req_up_head_lev(Uid,Sid,Seq,Data);
		?ACTION_REQ_ACTIVE_HEAD_SUIT->fun_usr_head:req_active_suit_lev(Uid,Sid,Seq,Data);
		?ACTION_REQ_UP_HEAD_SUIT_LEV->fun_usr_head:req_up_suit_lev(Uid,Sid,Seq,Data);
		?ACTION_REQ_GUILD_IMPEACH_RESULT -> gen_server:cast(agent_mng, {action_int,?ACTION_REQ_GUILD_IMPEACH_RESULT,Uid,Sid,Seq,Data});
		?ACTION_REQ_ENTOURAGE_AWAKE -> fun_entourage:req_entourage_awake(Uid,Sid,Data,Seq);
		?ACTION_REQ_UPDATE_LEGENDARY_LEVEL -> fun_paragon_level:req_add_legendary_prop(Uid,Sid,Data,Seq);
		?ACTION_REQ_CHANGE_LEGENDARY_EXP -> fun_paragon_level:req_exchange_legendary_exp(Uid,Sid,Data,Seq);
		% ?ACTION_REQ_ACTIVE_GOD_COSTUME_ILLUS -> fun_item_god_costume:req_active_god_costume_illustration(Uid,Sid,Data,Seq);
		?ACTION_REQ_FETCH_ARNEA_REWARD -> gen_server:cast(agent_mng, {action_int,?ACTION_REQ_FETCH_ARNEA_REWARD,Uid,Sid,Seq,Data});
		?ACTION_REQ_DRAW_TURMTABLE -> 
			case fun_gm_activity_ex:find_open_activity(?GM_ACTIVITY_TURNTANLE) of
				{true, ActivityRec} -> gm_act_turntable:req_draw(Uid,Sid,Data,ActivityRec);
				_ -> skip
			end;
		%% P18 NEW
		?ACTION_ITEM_BUY_AND_UPDATE -> fun_item:req_buy_bag_lev(Uid,Sid,Data,Seq);
		?ACTION_RANKLIST-> mod_rank_service:req_rank_list(Uid,Sid,Seq,Data);
		?ACTION_REQ_HERO_LV_UP -> fun_entourage_ex:req_up_lv(Uid, Sid, Seq, Data);
		?ACTION_REQ_HERO_GRADE_UP -> fun_entourage_ex:req_up_grade(Uid, Sid, Seq, Data);
		?ACTION_REQ_ARENA_SINGLE_INFO -> fun_arena:req_arena_challenge_single_info(Uid, Sid, Seq, Data);
		?ACTION_REQ_ONCE_UNLOAD_EQUIPMENT -> mod_entourage_equipment:req_once_unload_equipment(Uid, Sid, Seq, Data);
		?ACTION_REQ_ENTOURAGE_SUBSTITUTION -> fun_entourage_substitution:req_entourage_substitution(Uid, Sid, Seq, Data);
		?ACTION_REQ_REFRESH_STORE -> fun_store:req_refresh_store(Uid, Sid, Seq, Data);
		?ACTION_REQ_DRAW_NORMAL_TURNTABLE -> mod_turntable:req_draw_normal_turntable(Uid, Sid, Seq, Data);
		?ACTION_REQ_DRAW_RECORD -> mod_draw_record:req_draw_record(Uid, Sid, Seq, Data);
		?ACTION_REQ_FRIEND_APPLY -> gen_server:cast(fun_relation_srv, {action_int, ?ACTION_REQ_FRIEND_APPLY, Uid, Sid, Seq, Data});
		?ACTION_REQ_PASS_FRIEND_APPLY -> gen_server:cast(fun_relation_srv, {action_int, ?ACTION_REQ_PASS_FRIEND_APPLY, Uid, Sid, Seq, Data});
		?ACTION_REQ_DELETE_FRIEND_APPLY -> gen_server:cast(fun_relation_srv, {action_int, ?ACTION_REQ_DELETE_FRIEND_APPLY, Uid, Sid, Seq, Data});
		?ACTION_REQ_DELETE_FRIEND -> gen_server:cast(fun_relation_srv, {action_int, ?ACTION_REQ_DELETE_FRIEND, Uid, Sid, Seq, Data});
		?ACTION_REQ_FRIEND_TOP -> gen_server:cast(fun_relation_srv, {action_int, ?ACTION_REQ_FRIEND_TOP, Uid, Sid, Seq, Data});
		?ACTION_REQ_DAILY_TASK_REWARD -> fun_daily_task:req_task_reward(Uid, Sid, Seq, Data);
		_ ->
			?ERROR("pt_action_int_d003, action:~p unused", [Action])
	end;
process_pt(pt_action_float_d005,_Seq,Pt,_Sid) ->
	Action = Pt#pt_action_float.action,
	_Data = Pt#pt_action_float.data,
	case Action of
		_ -> skip
	end;
process_pt(pt_action_string_d004,Seq,Pt,Sid) ->
%% 	?debug("get action_string Pt = ~p,Sid = ~p",[Pt,Sid]),
	Uid = get(uid),
	Action = Pt#pt_action_string.action,
	String = Pt#pt_action_string.data,
	case Action of
		?ACTION_GM_CODE -> 
			case server_config:get_conf(open_gm_code) of 
				true->
					fun_gm_code:process(get(uid),Sid,String);
				_->skip
			end;
		?ACTION_CONFIRM_INVITE_JOIN_GUILD->gen_server:cast(agent_mng, {action_string,?ACTION_CONFIRM_INVITE_JOIN_GUILD,Uid,Sid,Seq,String});
		?ACTION_GUILD_SEEK->gen_server:cast(agent_mng, {action_string,?ACTION_GUILD_SEEK,Uid,Sid,Seq,String});
		?ACTION_GUILD_CHANGE_NOTICE->gen_server:cast(agent_mng, {action_string,?ACTION_GUILD_CHANGE_NOTICE,Uid,Sid,Seq,String});
		?ACTION_USE_CDKEY->fun_cdkey:use_cdkey(Uid, get(aid), String);
		?ACTION_THUMB_UP_NAME->gen_server:cast(agent_mng, {action_string,?ACTION_THUMB_UP_NAME,Uid,Sid,Seq,String});
		%% P18 NEW
		?ACTION_REQ_CHANGE_NAME -> mod_agent_misc:req_change_name(Uid, Sid, String, Seq);
		?ACTION_REQ_SEARCH_FRIEND -> gen_server:cast(fun_relation_srv, {action_string, ?ACTION_REQ_SEARCH_FRIEND, Uid, Sid, Seq, String});
		_ ->
			?ERROR("pt_action_string_d004, action:~p unused", [Action])
	end;
process_pt(pt_action_two_int_d012,Seq,Pt,Sid) ->
%% 	?debug("get action_string Pt = ~p,Sid = ~p",[Pt,Sid]),
	Action = Pt#pt_action_two_int.action,
	Data1 = Pt#pt_action_two_int.data_One,
	Data2 = Pt#pt_action_two_int.data_Two,
	Uid = get(uid),
	case Action of
		?ACTION_REQ_VIEW_GUILD_MEMBER_INFO->gen_server:cast(agent_mng, {action_two_int_d012,?ACTION_REQ_VIEW_GUILD_MEMBER_INFO,Uid,Sid,Data1,Data2,Seq});
		?ACTION_GUILD_JOIN->gen_server:cast(agent_mng, {action_two_int_d012,?ACTION_GUILD_JOIN,Uid,Sid,Data1,Data2,Seq});
		?ACTION_REQ_BARRIER_REWARD_FETCH -> fun_barrier_rewards:req_fetch(Uid, Sid, Seq, Data1, Data2);
		?ACTION_ENTOURAGE_EQUIP->fun_entourage:request_entourage_equip(Uid,Sid,Data1,Data2,Seq);
		?ACTION_ITEM_SELL_ITEM-> fun_item_action:req_sell_item(Uid,Sid,Data1,Data2,Seq);
		?ACTION_REPLY_GUILD_ENTRY->gen_server:cast(agent_mng, {action_two_int_d012,?ACTION_REPLY_GUILD_ENTRY,Uid,Sid,Data1,Data2,Seq});
		?ACTION_GUILD_PERM->gen_server:cast(agent_mng, {action_two_int_d012,?ACTION_GUILD_PERM,Uid,Sid,Data1,Data2,Seq});
		?ACTION_GUILD_BUILDING->gen_server:cast(agent_mng, {action_two_int_d012,?ACTION_GUILD_BUILDING,Uid,Sid,Data1,Data2,Seq});
		?ACTION_GUILD_COPY_APPLY->gen_server:cast(agent_mng, {action_two_int_d012,?ACTION_GUILD_COPY_APPLY,Uid,Sid,Data1,Data2,Seq});
		?ACTION_REQ_STOP_MATCH -> gen_server:cast(agent_mng, {action_two_int_d012,?ACTION_REQ_STOP_MATCH,Uid,Sid,Data1,Data2,Seq});
		?ACTION_PICK_GIFT_RECHARGE -> gen_server:cast(agent_mng, {action_two_int_d012,?ACTION_PICK_GIFT_RECHARGE,Uid,Sid,Data1,Data2,Seq});
		?ACTION_PICK_LOGINACT -> gen_server:cast(agent_mng, {action_two_int_d012,?ACTION_PICK_LOGINACT,Uid,Sid,Data1,Data2,Seq});
		?ACTION_REQ_FAST_COPY->fun_activity_copy:req_fast_copy(Uid, Sid, Seq, Data1, Data2);	
		?ACTION_ENTOURAGE_ADD_EXP->fun_item:add_entourage_exp(Uid,Sid,Data1, Data2,Seq);
		?REQ_GUILD_TEAM_COPY_JOIN->gen_server:cast(agent_mng, {action_two_int_d012,?REQ_GUILD_TEAM_COPY_JOIN,Uid,Sid,Data1,Data2,Seq});
		?ACTION_REQ_HOME_BUILDING_WORKER_ASSIGN -> gen_server:cast(agent_mng, {action_two_int_d012,?ACTION_REQ_HOME_BUILDING_WORKER_ASSIGN,Uid,Sid,Data1,Data2,Seq});
		?ACTION_REQ_HOME_BUILDING_ASSISTANT_ASSIGN -> gen_server:cast(agent_mng, {action_two_int_d012,?ACTION_REQ_HOME_BUILDING_ASSISTANT_ASSIGN,Uid,Sid,Data1,Data2,Seq});
		?ACTION_REQ_SETTLED -> fun_family:req_settled_helper(Uid, Sid, Data1, Data2, Seq);
		?ACTION_REQ_INSTITUE_SKILL_UPGRADE -> fun_family:req_study_skill(Uid, Sid, Data1, Data2, Seq);
		?ACTION_REQ_GM_TREASURE_EXCHANGE -> gm_act_treasure:do_exchange(Uid, Sid, Data1, Data2);
		?ACTION_REQ_JOIN_MEETING -> gen_server:cast(family_mng, {action_two_int_d012,?ACTION_REQ_JOIN_MEETING,Uid,Sid,Data1,Data2,Seq});
		?ACTION_REQ_GLOBAL_ARENA_WORSHIP -> fun_global_arena:req_worship(Uid, Sid, Seq, Data1, Data2);
		?ACTION_REQ_CHALL_ARENA ->
			gen_server:cast(agent_mng, {action_two_int_d012,?ACTION_REQ_CHALL_ARENA,Uid,Sid,Data1,Data2,Seq});
		?ACTION_REQ_MAZE_REVENGE -> fun_maze:req_maze_revenge(Uid,Sid,Seq,Data1,Data2);
		?ACTION_REQ_SAILING_PLUNDER->fun_server_uncharter_water:req_sailing_plunder(Uid,Sid,Data1,Data2,Seq);
		?ACTION_REQ_ENTER_MELLEBOSS->fun_agent_meleeboss:req_enter_copy(Uid,Sid,Data1,Data2,Seq);
		?ACTION_REQ_ITEM_EXCHANGE->fun_exchange:req_exchange(Uid,Sid,Data1,Data2,Seq);
		% ?ACTION_REQ_DRESS_GOD_COSTUME -> fun_item_god_costume:req_dress_god_costume(Uid,Sid,Seq,Data1,Data2);
		% ?ACTION_REQ_BUY_ARENA -> fun_arena_new:req_buy_arena_store(Uid,Sid,Seq,Data1,Data2);
		%% P18 NEW
		?ACTION_REQ_USE_ITEM -> fun_item_action:req_item_use(Uid,Sid,Data1,Data2,Seq);
		?ACTION_REQ_UNLOAD_EQUIPMENT -> mod_entourage_equipment:req_unload_equipment(Uid, Sid, Data1, Data2, Seq);
		?ACTION_REQ_EQUIPMENT_SYNTHWSIS -> mod_entourage_equipment:req_equipment_synthwsis(Uid,Sid,Data1,Data2,Seq);
		?ACTION_REQ_SUMMON_DRAW -> fun_draw:req_summon_draw(Uid, Sid, Data1, Data2, Seq);
		?ACTION_REQ_DRAW -> fun_draw:req_draw(Uid, Sid, Data1, Data2, Seq);
		?ACTION_REQ_LOAD_FUWEN -> mod_fuwen_equip:req_load(Uid, Sid, Seq, Data1, Data2);
		?ACTION_REQ_UNLOAD_FUWEN -> mod_fuwen_equip:req_unload(Uid, Sid, Seq, Data1, Data2);
		?ACTION_REQ_BUY_CELL -> fun_store:req_buy_cell(Uid, Sid, Seq, Data1, Data2);
		?ACTION_REQ_OTHER_USR_INFO -> gen_server:cast(agent_mng, {action_two_int_d012,?ACTION_REQ_OTHER_USR_INFO,Uid,Sid,Data1,Data2,Seq});
		_ ->
			?ERROR("pt_action_two_int_d012, action:~p unused", [Action])
	end;

process_pt(pt_action_tri_int_f025,Seq,Pt,Sid) ->
%% 	?debug("get action_string Pt = ~p,Sid = ~p",[Pt,Sid]),
	Action = Pt#pt_action_tri_int.action,
	Data1 = Pt#pt_action_tri_int.data_One,
	Data2 = Pt#pt_action_tri_int.data_Two,
	Data3 = Pt#pt_action_tri_int.data_Three,
	case Action of
		?ACTION_REQ_GGB_STAKE -> fun_server_guild_battle:req_stake(get(uid), Sid, Seq, Data1, Data2, Data3);
		?ACTION_PAY_BYJIFEN->fun_jifen:checkPayJifen(get(uid),Data1, Data2, Data3,Sid,Seq);
		?ACTION_RIDE_FEEDTHREE->
			% ?debug("test:my ride food"),
			fun_ride:ride_foodstar(get(uid),Sid,Seq,Data1,Data2,Data3);
		_ -> 
			?ERROR("pt_action_tri_int_f025, action:~p unused", [Action])
	end;

process_pt(pt_action_list_f014,Seq,Pt,Sid) ->
	% ?debug("Pt=~p",[Pt]),
	Action = Pt#pt_action_list.action,
	IDS=Pt#pt_action_list.id_list,
	ID_List=[Data#pt_public_id_list.id || Data <- IDS],
	case Action of
		?ACTION_REQ_SET_ARENA_GUARD_ENTOURAGE -> fun_entourage:req_set_guard_entourage(get(uid),Sid,ID_List,Seq);
		_ -> 
			?ERROR("pt_action_list_f014, action:~p unused", [Action])
	end;

process_pt(pt_action_list_and_data_f026,Seq,Pt,Sid) ->
	% ?debug("Pt=~p",[Pt]),
	Uid = get(uid),
	Action = Pt#pt_action_list_and_data.action,
	ID_List = [Data#pt_public_id_list.id || Data <- Pt#pt_action_list_and_data.id_list],
	Data = Pt#pt_action_list_and_data.data,
	case Action of
		?ACTION_REQ_SHENQI_UP_STAR -> fun_shenqi:req_up_star(Uid,Sid,Seq,Data,ID_List);
		?ACTION_REQ_HERO_STAR_UP -> fun_entourage_ex:req_up_star(Uid,Sid,Seq,Data,ID_List);
		?ACTION_REQ_EQUIPMENT -> mod_entourage_equipment:req_equipment(Uid,Sid,Data,ID_List,Seq);
		?ACTION_REQ_ITEM_BREAK -> mod_breakdown:req_break(Uid,Sid,Data,ID_List,Seq);
		_ -> ?WARNING("pt_action_list_and_data_f026 action ~p unused", [Action])
	end;

process_pt(pt_action_string_and_data_f032,Seq,Pt,Sid) ->
	% ?debug("Pt=~p",[Pt]),
	Uid = get(uid),
	Action = Pt#pt_action_string_and_data.action,
	String = Pt#pt_action_string_and_data.data2,
	Data = Pt#pt_action_string_and_data.data1,
	case Action of
		?ACTION_GUILD_CREATE->gen_server:cast(agent_mng, {pt_action_string_and_data_f032,?ACTION_GUILD_CREATE,Uid,Sid,Seq,String,Data});
		?ACTION_REQ_CHANGE_GUILD_NAME -> gen_server:cast(agent_mng, {pt_action_string_and_data_f032,?ACTION_REQ_CHANGE_GUILD_NAME,Uid,Sid,Data,String,Seq});
		_ -> 
			?ERROR("pt_action_string_and_data_f032, action:~p unused", [Action])
	end;

process_pt(pt_create_guild_f095,Seq,Pt,Sid) ->
	Uid = get(uid),
	#pt_create_guild{
		banner = Banner,
		guild_name = GuildName,
		notice = Notice
	} = Pt,
	gen_server:cast(agent_mng, {create_guild,Uid,Sid,Seq,GuildName,Banner,Notice});


% process_pt(pt_action_two_int_list_f084,Seq,Pt,Sid) ->
% 	% ?debug("Pt=~p",[Pt]),
% 	Action = Pt#pt_action_two_int_list.action,
% 	List1 = Pt#pt_action_two_int_list.list,
% 	List = [{Data1, Data2} || #pt_public_two_int{data1=Data1,data2=Data2} <- List1],
% 	case Action of
% 		_ -> 
% 			?ERROR("pt_action_two_int_list_f084, action:~p unused", [Action])
% 	end;

process_pt(pt_action_data_and_two_int_list_f08d,Seq,Pt,Sid) ->
	% ?debug("Pt=~p",[Pt]),
	Uid = get(uid),
	Action = Pt#pt_action_data_and_two_int_list.action,
	Data = Pt#pt_action_data_and_two_int_list.data,
	List1 = Pt#pt_action_data_and_two_int_list.list,
	List = [{Data1, Data2} || #pt_public_two_int{data1=Data1,data2=Data2} <- List1],
	case Action of
		?ACTION_ENTOURAGE_COMBAT -> fun_entourage:req_entourage_combat(Uid,Sid,Seq,List,Data);
		?ACTION_REQ_SET_GUARD_LIST -> gen_server:cast(agent_mng, {pt_action_data_and_two_int_list_f08d,?ACTION_REQ_SET_GUARD_LIST,Uid,Sid,List,Data,Seq});
		?ACTION_REQ_SET_COPY_ON_BATTLE -> fun_activity_copy:req_set_on_battles(Uid,Sid,Seq,List,Data);
		?ACTION_REQ_SET_EXPEDITION_ON_BATTLE -> mod_hero_expedition:req_set_on_battles(Uid,Sid,Seq,List,Data);
		_ -> 
			?ERROR("pt_action_data_and_two_int_list_f08d, action:~p unused", [Action])
	end;

process_pt(pt_arena_challenge_f089,Seq,Pt,Sid) ->
	% ?debug("Pt=~p",[Pt]),
	Action = Pt#pt_arena_challenge.action,
	List1 = Pt#pt_arena_challenge.entourage_list,
	List = [{Data1, Data2} || #pt_public_two_int{data1=Data1,data2=Data2} <- List1],
	TUid = Pt#pt_arena_challenge.t_uid,
	Type = Pt#pt_arena_challenge.rank_type,
	Data = Pt#pt_arena_challenge.shenqi_id,
	Uid = get(uid),
	case Action of
		?ACTION_REQ_ENTER_ARENA -> gen_server:cast(agent_mng, {pt_arena_challenge_f089,?ACTION_REQ_ENTER_ARENA,Uid,Sid,Seq,TUid,Type,List,Data});
		?ACTION_REQ_ARENA_REVENGE -> gen_server:cast(agent_mng, {pt_arena_challenge_f089,?ACTION_REQ_ARENA_REVENGE,Uid,Sid,Seq,TUid,Type,List,Data});
		?ACTION_REQ_FRIEND_ATTACK -> fun_relation_ex:req_friend_attack(Uid,Sid,Seq,TUid,Type,List,Data);
		_ ->
			?ERROR("pt_arena_challenge_f089, action:~p unused", [Action])
	end;

process_pt(pt_give_pwd_red_d258,Seq,Pt,Sid) ->
	?debug("---------------give_pwd_red_d258 Pt = ~p,Sid = ~p",[Pt,Sid]),
	PwdContext = Pt#pt_give_pwd_red.pwd_context,
	Diamond = Pt#pt_give_pwd_red.diamond,
	RedNum = Pt#pt_give_pwd_red.red_num,
	gen_server:cast(agent_mng, {req_give_password_red,get(uid),Sid,Seq,PwdContext,Diamond,RedNum});

process_pt(pt_req_entourage_create_model_f03b,Seq,Pt,Sid) ->
	ItemIdId = Pt#pt_req_entourage_create_model.id,
	CreateType = Pt#pt_req_entourage_create_model.create_type,
	fun_entourage:req_entourage_create(get(uid),Sid,Seq,ItemIdId,CreateType);
process_pt(pt_store_buy_d034,Seq,Pt,Sid) ->
%% 	?debug("store_buy Pt=~p~n",[Pt]),
	StoreID = Pt#pt_store_buy.store_id,
	ID = Pt#pt_store_buy.cell_id,
	Num = Pt#pt_store_buy.buy_num,
	fun_store:req_buy(get(uid), Sid, Seq, StoreID, ID, Num);


process_pt(pt_req_gem_update_d102,Seq,Pt,Sid) ->
%% 	?debug("req_gem_update Pt=~p~n",[Pt]),
	GemId=Pt#pt_req_gem_update.gem_id,
	ItemId=Pt#pt_req_gem_update.item_id,
	UpdateState = Pt#pt_req_gem_update.state,
	fun_gem:update_gem_lev(get(uid), Sid, Seq, GemId, ItemId, UpdateState); 

process_pt(pt_req_chat_d209,Seq,Pt,Sid) ->
	case fun_gm_operation:check_shutup(Sid,get(uid),Seq) of
		true->
			RecName = Pt#pt_req_chat.rec_name, 
			Chanle=Pt#pt_req_chat.chanle,
			Content=Pt#pt_req_chat.content,
			mod_msg:handle_to_chat_server({req_chat, get(uid), Sid, Seq, RecName, Chanle, Content});
		_->skip
	end;

process_pt(pt_updata_name_card_d174,Seq,Pt,Sid) ->
	ItemId = Pt#pt_updata_name_card.item_id,
	UpdataName =Pt#pt_updata_name_card.updata_name,
	fun_item:updata_name_card(get(uid),Seq,Sid,ItemId,UpdataName); 

process_pt(pt_team_process_d188,_Seq,Pt,Sid) ->
	GS = Pt#pt_team_process.gs,
	Lev = Pt#pt_team_process.lev,
	Population = Pt#pt_team_process.population,
	gen_server:cast(agent_mng, {team_process_info,get(uid),Sid,GS,Lev,Population});
process_pt(pt_req_guild_call_upon_d193,_Seq,Pt,Sid) ->
	CallUponId = Pt#pt_req_guild_call_upon.call_upon_id,
	MinGs = Pt#pt_req_guild_call_upon.min_gs,
	MinLev = Pt#pt_req_guild_call_upon.min_lev,
	MinPost = Pt#pt_req_guild_call_upon.min_post,
	gen_server:cast(agent_mng, {req_guild_call_upon,get(uid),Sid,CallUponId,MinGs,MinLev,MinPost});

process_pt(pt_req_quick_fight_c100,Seq,Pt,Sid) ->
	case Pt of
		#pt_req_quick_fight{req_type=Req_type} ->
			fun_quick_fight:req_quick_fight_info(get(uid), Sid, Seq,Req_type);
		_ ->skip
	end;
	
process_pt(PtModule,_Seq,_Pt,_Sid) -> 
	?ERROR("unprocessed pt:~p", [PtModule]),
	ok.