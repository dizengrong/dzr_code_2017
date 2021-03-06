-module(all_ptc).
-compile([export_all]).
-export([write/0]).

-define(max_a,"A111"). %%登陆协议
-define(max_b,"B106"). %%进入/切换场景协议
-define(max_c,"C022"). %%场景内协议
-define(max_wm,"D436"). %%wm协议
-define(max_lp,"D2BD"). %%lp协议
-define(max_gzy,"D30D"). %%gzy协议
-define(max_zzp_a,"E12B"). %%zzp协议
-define(max_cqt,"D500"). %%cqt协议
-define(max_dzr,"E200"). %%dzr协议
-define(max_zsm,"D70A"). %%zsm协议

get_new_list() ->
	[
		ptc_action_two_int_list,
		ptc_main_scene_status,
		ptc_main_scene_result,
		ptc_scene_end,
		ptc_scene_monster_die,
		ptc_arena_challenge,
		ptc_entourage_update,
		ptc_update_resource,
		ptc_arena_challenge_info,
		ptc_hero_illustration,
		ptc_action_data_and_two_int_list
	].

get_list() ->
	[
	 ptc_public_class,
	 ptc_shenqi_skill_effect,
	 ptc_cast_shenqi_skill,
	 ptc_relife_task_info,
	 ptc_download_reward,
	 ptc_daily_acc_recharge_info,
	 ptc_daily_acc_cost,
	 ptc_grow_fund_info,
	 ptc_login,
	 ptc_login_robot,
	 ptc_error_info, 
	 ptc_usr_list,
	 ptc_req_net,
	 ptc_queue_info,
	 ptc_net_info,
	 ptc_usr_enter,
	 ptc_usr_info,
	 ptc_usr_enter_scene,
	 ptc_req_load_scene,
	 ptc_load_scene_finish,
	 ptc_scene_info,
	 ptc_req_create_usr,
	 ptc_create_usr_list,
	 ptc_req_delete_usr,
	 ptc_delete_usr,
	 ptc_action,
	 ptc_action_int,
	 ptc_action_string,
	 ptc_action_float,
	 ptc_action_list,
	 ptc_ping,
	 ptc_net_chg_code,
	 ptc_last_called_hero,
	 ptc_charge_card,
	 ptc_ggb_info,
	 ptc_ggb_my_team_info,
	 ptc_ggb_group_info,
	 ptc_ggb_scene_brief_info,
	 ptc_ggb_scene_report,
	 ptc_ggb_battle_log,
	 ptc_ggb_nofity,
	 ptc_ggb_battle_result,
	 ptc_ggb_battle_waiting,
	 
	 ptc_relife_succeed,
	 ptc_draw_base,
	 ptc_medicine,

	 ptc_scene_move,
	 ptc_niubi,
	 ptc_scene_add,
	 ptc_scene_dec,
	 ptc_scene_fly_by_fly_point,
	 ptc_scene_skill,
	 ptc_scene_skill_effect,
	 ptc_scene_property,
	 ptc_scene_chg_buff,
	 ptc_scene_remove_buff,
	 ptc_scene_break_persistent,
	 ptc_scene_drop,
	 ptc_scene_pickup,
	 ptc_scene_add_arrow,
	 ptc_scene_delete_arrow,
	 ptc_scene_add_trap,
	 ptc_scene_delete_trap,
	 ptc_scene_usr_team_chg,
	 ptc_scene_hide,
	 ptc_scene_skill_aleret,
	 ptc_scene_skill_aleret_cancel,
	 
	 ptc_item_info,
	 ptc_item_chg,
	 ptc_lost_item,
	 ptc_lost_item_get,
	 ptc_lost_item_lev,
	 ptc_lost_item_activate,
	 ptc_scene_transform,
	 ptc_entourage_list,
	 ptc_entourage_info,
	 ptc_task_list,
	 ptc_update_task_condition,
	 ptc_accept_task,	 
	 ptc_finish_task,
	 ptc_del_task,
	 ptc_accept_task_response,
	 ptc_finish_task_response,
	 ptc_req_task_list,
	 ptc_all_skill,
	 ptc_action_two_int,
	 ptc_update_base,	 
	 ptc_entourage_create,
	 ptc_team_info,
	 ptc_team_member_chg,
	 ptc_team_ask,
	 ptc_team_ans_ask,
	 ptc_team_req,
	 ptc_team_ans_req,
	 ptc_team_leader_chg,
	 ptc_team_member_leave,
	 ptc_team_destroy,
	 ptc_team_ask_cancle,
	 ptc_team_req_cancle,
	 ptc_reloading,
	 ptc_mastery,
	 ptc_mastery_update,
	 ptc_pet_info,
	 ptc_store_info,
	 ptc_store_buy,
	 ptc_req_gem_update,
	 ptc_return_gem_update,
	 ptc_scene_item_action,
	 ptc_say_notify,
	 ptc_req_item_recycle,
	 ptc_return_sign,
	 ptc_activity_info,
	 ptc_progress_bar_begin,
	 ptc_progress_bar_end,
	 ptc_friends_info,
	 ptc_friend_apply_list,
	 ptc_revive,
	 ptc_open_box_get_item,
	 ptc_recommend_friends_list,
	 ptc_copy_times,
	 ptc_get_success,
	 ptc_revive_times,
	 ptc_all_guild_list_info,
	 ptc_guild_member_info,
	 ptc_guild_commonality,
	 ptc_members_entry,
	 ptc_guild_succeed,
	 ptc_item_recoin,
	 ptc_item_recoin_return,
	 ptc_entourage_succeed,
	 ptc_chat,
	 ptc_req_chat,	 
	 ptc_req_jump,
	 ptc_scene_jump,
	 ptc_acquire_new_title,
	 ptc_ret_titles,
	 ptc_req_mail,
	 ptc_mail_content,
	 ptc_del_mail,
	 ptc_read_mail_item,
	 ptc_update_mail,
	 ptc_invite_join_guild,
	 ptc_copy_win,
	 ptc_donation_record_list,
	 ptc_guild_building_list,
	 ptc_monster_affiliation,
	 ptc_guild_copy_list,
	 ptc_guild_copy_trophy,
	 ptc_guild_copy_enter,
	 ptc_guild_copy_damage_ranking,
	 ptc_use_someone_title,
	 ptc_start_timer,
	 ptc_break_copy_timer,
	 ptc_update_usr_discrib,
	 ptc_mdf_team_info,
	 ptc_ret_scene_teams,
	 ptc_ranklist,
	 ptc_ret_ride_info,
	 ptc_ret_ride_prop,
	 ptc_receive_rewards_succeed,
	 ptc_ret_skin_list,
	 ptc_rewards_return,
	 ptc_req_match,
	 ptc_stop_match,
	 ptc_match_ready_cancel,
	 ptc_start_match,
	 ptc_usr_info_equi,
	 ptc_usr_info_property,
	 ptc_usr_info_lost_item,
	 ptc_usr_info_entourage,
	 ptc_match_succ,
	 ptc_match_submit_ready,
	 ptc_draw,
	 ptc_draw_times,
	 ptc_item_info_return,
	 ptc_broadcast_ride_info,
	 ptc_archaeology,
	 ptc_archaeology_reward,
	 ptc_camp_vote_data,
	 ptc_vote_result,
	 ptc_join_camp,
	 ptc_ret_trials_info,
	 ptc_update_camp,
	 ptc_wanted_task,
	 ptc_task_rewards_succeed,
	 ptc_camp_worship,
	 ptc_worship_response,
	 ptc_ret_risks_info,
	 ptc_scene_fly_scene,
	 ptc_camp_task,
	 ptc_ret_hero_challenge,
	 ptc_military_prize_succ,
	 ptc_camp_activity_data,
	 ptc_item_model,
	 ptc_guild_name,
	 ptc_req_continue_hc,
	 ptc_update_scene_usr_data,
	 ptc_copy_exist_time,
	 ptc_crowd_num,
	 ptc_backpack_upgrade,
	 ptc_guild_notice,
	 ptc_seven_day_target_status,
	 ptc_chapter_info,
	 ptc_guild_member_verify,
	 ptc_quick_add_pet,
	 ptc_update_monster_prop,
	 ptc_boss_info,
	 ptc_boss_prize,
	 ptc_boss_lose,
	 ptc_arena_info,
	 ptc_challenger_reflush,
	 ptc_arena_record_info,
	 ptc_arena_reflush_cd,
     ptc_arena_result,
     ptc_ret_fast_trials,
	 ptc_chapter_succeed,
	 ptc_camp_killed_military,
	 ptc_item_compound_succeed,
	 ptc_scene_load,
	 ptc_scene_branching_info,
	 ptc_ret_achieves,
	 ptc_item_model_clothes,
	 ptc_paragon_level,
	 ptc_arena_start_time,
	 ptc_unlock_atlas,
	 ptc_vip_rewards,
	 ptc_activity_success,
	 ptc_first_recharge,
	 ptc_honor_kill,
	 ptc_ret_charge_active,
	 ptc_update_charge_active,
	 ptc_entourage_soul_link,
	 ptc_recharge_succ,
	 ptc_entourage_fetter_info,
	 ptc_recharge_data,
	 ptc_vip_succeed,
	 ptc_first_extend_recharge,
	 ptc_dart_activity_state,
	 ptc_use_item_groupId,
	 ptc_camp_skill,
	 ptc_abddart_activity,
	 ptc_ref_queue,
	 ptc_exit_queue,
	 ptc_dart_pos,
	 ptc_camp_leader_info,
	 ptc_system_time,
	 ptc_dart_time,
	 ptc_off_line_exp,
	 ptc_off_line_succeed,
	 ptc_sdk_login,
	 ptc_login_auth_succ,
	 ptc_gen_order,
	 ptc_update_camp_leader,
	 ptc_retrueve_info,
	 ptc_retreve_succeed,
	 ptc_req_quick_buy,
	 ptc_return_quick_buy,
	 ptc_move_sand_buff,
	 ptc_move_sand_buff_id,
	 ptc_buy_coin,
	 ptc_all_star,
	 ptc_task_rewards_info,
	 ptc_guild_task,
	 ptc_entourage_star,
	 ptc_ret_war_times,
	 ptc_national_war_data,
	 ptc_national_war_record,
	 ptc_national_war_call,
	 ptc_national_war_scrolls,
	 ptc_national_war_call_broadcast,
	 ptc_ret_war_report,
	 ptc_war_over,
	 ptc_ans_match_war,
	 ptc_royal_box_info,
	 ptc_royal_box_succeed,
	 ptc_entourage_star_rewards,
	 ptc_equip_rewards,
	 ptc_equip_and_entourage_succeed,
	 ptc_ret_gs_rewards,
	 ptc_match_finish,
	 ptc_ret_gamble_info,
	 ptc_week_rewards_info,
	 ptc_ret_gamble_price,
	 ptc_ret_items_buffer,
	 ptc_wechat_rewards,
	 ptc_national_war_show_info,
	 ptc_guild_post,
	 ptc_fortress_task_info,
	 ptc_single_recharge_info,
	 ptc_repeat_recharge_info,
	 ptc_gift_recharge_info,
	 ptc_exchange_info,
	 ptc_loginact_info,
	 ptc_picked_single_recharge,
	 ptc_picked_repeat_recharge,
	 ptc_picked_gift_recharge,
	 ptc_picked_exchange,
	 ptc_picked_loginact,
	 ptc_sweep_copy_rewards_info,
	 ptc_ret_fast_copy,
	 ptc_flag_count,
	 ptc_flag_status,
	 ptc_national_war_tips,
	 ptc_national_war_start_time,
	 ptc_ret_wheel_info,
	 ptc_ret_guide_tag_point,
	 ptc_ret_gamble_record,
	 ptc_ret_war_usr_area,
	 ptc_scene_full_tips,
	 ptc_updata_name_card,
	 ptc_update_name_succeed,
	 ptc_war_damage_rank,
	 ptc_atlas_team_info,
	 ptc_copy_scene_notice_revive,
	 ptc_usr_info_mount,
	 ptc_usr_info_pet,
	 ptc_growth_bible_info,
	 ptc_req_atlas_team_info,
	 ptc_guild_impeach_president,
	 ptc_blacklist_info,
	 ptc_team_war_seq,
	 ptc_scramble_info,
	 ptc_team_war_ready_finish,
	 ptc_hide_boss_data,
	 ptc_hide_boss_response,
	 ptc_update_boss_born_and_die,
	 ptc_open_svr_five_day_time,
	 ptc_open_svr_five_day_data,
	 ptc_update_open_svr_five_camp,
	 ptc_seven_day_target_info,
	 ptc_seven_day_target_rewards_info,
	 ptc_seven_day_target_succeed,
	 ptc_rent_entourage_response,
	 ptc_doing_exped_task,
	 ptc_expedition_task,
	 ptc_rent_entourage_info,
	 ptc_expedition_request,
	 ptc_strength_oven_info,
	 ptc_inscription_info,
	 ptc_team_process,
	 ptc_climb_tower_data,
	 ptc_red_packet_surplus_time,
	 ptc_red_packet_rewards,
	 ptc_climb_tower_reset,
	 ptc_climb_tower_fast,
	 ptc_climb_tower_first_reward,
	 ptc_guild_team_copy_info,
	 ptc_guild_team_info,
	 ptc_req_guild_call_upon,
	 ptc_guild_call_upon_broadcast,
	 ptc_guild_team_copy_succeed,
	 ptc_send_red_packet_info,
	 ptc_call_up_info,
	 ptc_entourage_exped_reward,
	 ptc_open_svr_time_limit,
	 ptc_abyss_box,
	 ptc_give_pwd_red,
	 ptc_pwd_red_info,
	 ptc_receive_red_response,
	 ptc_give_red_tips,
	 ptc_entourage_mastery_grow,
	 ptc_flying_shoes,
	 ptc_other_usr_skill_info,
	 ptc_share_info,
	 ptc_all_people_info,
	 ptc_treasure_activity_time,
	 ptc_treasure_rewards,
	 ptc_extreme_luxury_gift,
	 ptc_treasure_all_rewards,
	 ptc_treasure_times,
	 ptc_consume_rank_info,
	 ptc_recharge_rank_info,
	 ptc_rank_consume_activity_time,
	 ptc_rank_recharge_activity_time,
	 ptc_gm_continu_recharage,
	 ptc_gm_continu_recharge_close,
	 ptc_gm_continu_recharge_reward,
	 ptc_turning_wheel_config,
	 ptc_turning_wheel_hide,
	 ptc_recharge_package_data,
	 ptc_dress_suit_data,
	 ptc_lost_item_recover,
	 ptc_glory_sword,
	 ptc_military_skill,
	 ptc_copy_time_rewards,
	 ptc_stamina_time,
	 ptc_mystery_store_data,
	 ptc_mystery_store_buy,
	 ptc_hero_challenge_info,
	 ptc_pet_collect_info,
	 ptc_join_hero_challenge,
	 ptc_pet_book_list,
	 ptc_artifact_forging,
	 ptc_sky_ladder_info,
	 ptc_sky_ladder_reward,
	 ptc_sky_ladder_scene_result,
	 ptc_flash_gift_bag_info,
	 ptc_flash_gift_bag_time,
	 ptc_sdk_auth_failed,
	 
	 ptc_req_melting,
	 ptc_melting_suc,
	 ptc_compose_info,
	 ptc_bslx,
	 ptc_clear_skill_cd,
	 ptc_req_quick_fight,
	 ptc_update_quick_fight_info,
	 ptc_req_setting_pick_item,
	 ptc_time_reward_info,
	 ptc_time_reward_item,
	 ptc_update_guild_boss_reward,
	 ptc_update_guild_inspire_times,
	 ptc_story_show,
	 ptc_stroy_reward_info,
	 ptc_req_fly_planes,
	 ptc_task_step,
	 ptc_task_step_info,
	 ptc_req_guild_stone_info,
	 ptc_guild_stone_donation,
	 ptc_req_guild_stone_get,
	 ptc_acc_recharge_info,
	 ptc_show_fetched_reward,
	 ptc_gm_act_week_task,
	 ptc_gm_act_exchange,
	 ptc_gm_act_sale,
	 ptc_gm_act_drop,
	 ptc_acc_cost,
	 ptc_gm_act_discount,
	 ptc_gm_act_double,
	 ptc_shenqi_info,
	 ptc_recent_chat,
	 ptc_barrier_rewards_info,
	 ptc_online_status,
	 ptc_add_friend_confirm,
	 ptc_rep_add_friend_confirm,
	 ptc_home_building_list,
	 ptc_home_building_common_detail,
	 ptc_home_building_mine_info,
	 ptc_home_building_factory_info,
	 ptc_home_building_gather_succ,
	 ptc_home_building_req_produce,
	 ptc_home_building_upgrade_begin,
	 ptc_home_building_produce_begin,
	 ptc_building_upgrade_complete,
	 ptc_worldboss_list,
	 ptc_worldboss_times,
	 ptc_worldboss_damage_rank,
	 ptc_worldboss_inspire,
	 ptc_copy_data,
	 ptc_recharge_return,
	 ptc_gm_act_treasure,
	 ptc_gm_act_treasure_record,
	 ptc_gm_act_package,
	 ptc_client_error_report,
	 ptc_revive_notify,
	 ptc_artifact_fast,
	 ptc_gm_act_reset_recharge,
	 ptc_random_task,
	 ptc_gm_act_lv_rank,
	 ptc_system_activity,
	 ptc_system_activity_limitboss,
	 ptc_all_system_activity,
	 ptc_gm_act_limit_summon,
	 ptc_entourage_die,
	 ptc_entourage_revive,
	 ptc_action_tri_int,
	 ptc_action_list_and_data,
	 ptc_entourage_rune_info,
	 ptc_continuous_recharge_info,
	 ptc_limit_achievement_info,
	 ptc_entourage_debt_exchange_succ,
	 ptc_usr_head,
	 ptc_arena_guard_entourage,
	 ptc_consume_global_rank_info,
	 ptc_recharge_global_rank_info,
	 ptc_consumejifen_shop,
	 ptc_rechargejifen_shop,
	 ptc_action_string_and_data,
	 ptc_entourage_property,
	 ptc_sign_day,
	 ptc_entourage_list_new,
	 ptc_entourage_info_new,
	 ptc_entourage_succeed_new,
	 ptc_entourage_die_new,
	 ptc_entourage_revive_new,
	 ptc_entourage_create_model,
	 ptc_req_entourage_create_model,
	 ptc_usr_title,
	 ptc_worldlevel_info,
	 ptc_guild_blessing_info,
	 ptc_guild_operation,
	 ptc_global_arena_info,
	 ptc_global_arena_ranklist,
	 ptc_global_last_arena_ranklist,
	 ptc_global_arena_match_succ,
	 ptc_global_arena_match_start,
	 ptc_global_arena_result,
	 ptc_gm_act_limit_double_recharge,
	 ptc_praise_reward,
	 ptc_gm_act_recharge_point,
	 ptc_vip_daily_reward,
	 ptc_talent_info,
	 ptc_talent_draw,
	 ptc_ele_pearl_info,
	 ptc_mining_info,
	 ptc_mining_list,
	 ptc_maze_info,
	 ptc_maze_event,
	 ptc_sailing_info,
	 ptc_sailing_plunder_info,
	 ptc_sailing_guard_info,
	 ptc_global_guild_ranklist_info,
	 ptc_gm_act_literature_collection,
	 ptc_gm_act_lottery_carousel,
	 ptc_lottery_carousel_list,
	 ptc_maze_ranklist,
	 ptc_melleboss_info,
	 ptc_scene_change_camp,
	 ptc_melle_boss_scene_info,
	 ptc_revive_info_new,
	 ptc_melleboss_revive,
	 ptc_shenqi_awaken,
	 ptc_head_lev_info,
	 ptc_head_suit_info,
	 ptc_guild_impeach,
	 ptc_random_gift_package,
	 ptc_return_investment_info,
	 ptc_special_upgrade,
	 ptc_new_entourage_info,
	 ptc_system_time_zone,
	 ptc_legendary_level_info,
	 ptc_entourage_challenge,
	 ptc_legendary_level_start,
	 ptc_legendary_level_exp_info,
	 ptc_god_costume_info,
	 ptc_god_costume_illustration_info,
	 ptc_god_costume_draw,
	 ptc_mystery_gift_info,
	 ptc_arnea_season_info,
	 ptc_arnea_task_info,
	 ptc_arnea_store_info,
	 ptc_gm_act_single_recharge,
	 ptc_gm_act_acc_login,
	 ptc_gm_activity,
	 ptc_gm_act_point_package,
	 ptc_gm_act_diamond_package,
	 ptc_gm_act_rmb_package,
	 ptc_gm_act_turntable,
	 ptc_gm_act_turntable_draw_result,
	 ptc_hero_attr_info
	].


write() ->
	case file:open("./include/pt.hrl", [write]) of
		{ok, RdFile} ->
			List = get_list() ++ get_new_list(),
			Fun = fun(Module) ->  Module:write(RdFile),io:format("~p write ok!!~n", [Module]) end,
			lists:foreach(Fun, List),
			file:close(RdFile),
			io:format("\n===>copy changed pt \n", []),
			copy_changed_pt(server_config:get_conf(temp_erl_pt_dir), "./src/pt/"),
			{ok, List};
		R -> R
	end.


copy_changed_pt(SrcDir, DestDir) ->
	{ok, List} = file:list_dir(SrcDir),
	[copy_changed_pt(SrcDir, F, DestDir) || F <- List].

copy_changed_pt(SrcDir, File, DestDir) ->
	F1 = filename:join([SrcDir, File]),
	F2 = filename:join([DestDir, File]),
	case (not filelib:is_dir(F1)) andalso filename:extension(F1) == ".erl" of
		true ->
			{ok, B1} = file:read_file(F1),
			case file:read_file(F2) of
				{ok, B2} -> ok;
				_ -> B2 = <<>>
			end,
			case B1 /= B2 of
				true -> 
					file:copy(F1, F2),
					io:format("    copy ~s to ~s\n", [filename:basename(F1), F2]);
				false -> skip
			end;
		false -> skip
	end.

