%% @doc 这个文件自动生成的，请不要修改
-module(proto_pack).
-compile(export_all).
-include("proto_helper.hrl").


pt_break_succ({_, V1}) -> 
	<<?WUINT32(V1)>>.

pt_daily_task_info({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WLIST(V2, pt_public_task_list)>>.

pt_guild_tec_info({_, V1, V2, V3}) -> 
	<<?WBYTE(V1), ?WBYTE(V2), ?WLIST(V3, pt_public_two_int)>>.

pt_main_task_info({_, V1, V2, V3, V4}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WLIST(V4, pt_public_task_list)>>.

pt_item_detail_info({_, V1}) -> 
	<<?WLIST(V1, pt_public_item_des)>>.

pt_offline_reward({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WLIST(V2, pt_public_item_list)>>.

pt_scene_hero_prop_change({_, V1, V2, V3}) -> 
	<<?WUINT64(V1), ?WUINT32(V2), ?WUINT32(V3)>>.

pt_guide_info({_, V1}) -> 
	<<?WLIST(V1, uint32)>>.

pt_other_usr_info({_, V1, V2, V3, V4, V5, V6, V7, V8, V9}) -> 
	<<?WBYTE(V1), ?WUINT32(V2), ?WBYTE(V3), ?WBYTE(V4), ?WSTRING(V5), ?WSTRING(V6), ?WUINT32(V7), ?WLIST(V8, pt_public_on_battle_heros), ?WLIST(V9, pt_public_item_des)>>.

pt_search_friends_result({_, V1}) -> 
	<<?WLIST(V1, pt_public_pending_list)>>.

pt_recommend_friends_info({_, V1}) -> 
	<<?WLIST(V1, pt_public_pending_list)>>.

pt_friends_apply_info({_, V1}) -> 
	<<?WLIST(V1, pt_public_pending_list)>>.

pt_friends_info({_, V1}) -> 
	<<?WLIST(V1, pt_public_friend_list)>>.

pt_hero_expedition_hero_hp({_, V1}) -> 
	<<?WLIST(V1, pt_public_left_hp)>>.

pt_hero_expedition_scene_result({_, V1, V2, V3, V4}) -> 
	<<?WBYTE(V1), ?WLIST(V2, pt_public_item_list), ?WLIST(V3, pt_public_scene_damage_list), ?WLIST(V4, pt_public_scene_damage_list)>>.

pt_scene_copy_id({_, V1}) -> 
	<<?WUINT32(V1)>>.

pt_act_copy_scene_result({_, V1, V2, V3, V4, V5}) -> 
	<<?WBYTE(V1), ?WLIST(V2, pt_public_item_list), ?WLIST(V3, pt_public_item_list), ?WLIST(V4, pt_public_scene_damage_list), ?WLIST(V5, pt_public_scene_damage_list)>>.

pt_act_copy_scene_data({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WLIST(V2, pt_public_item_list)>>.

pt_hero_expedition_succ(_) -> 
	<<>>.

pt_on_scene_heros({_, V1}) -> 
	<<?WLIST(V1, pt_public_on_battle_data)>>.

pt_hero_expedition_info({_, V1, V2, V3, V4, V5, V6, V7, V8, V9}) -> 
	<<?WBYTE(V1), ?WBYTE(V2), ?WBYTE(V3), ?WBYTE(V4), ?WBYTE(V5), ?WBYTE(V6), ?WBYTE(V7), ?WLIST(V8, pt_public_expedition_pos), ?WLIST(V9, pt_public_expedition_sub_event)>>.

pt_act_copy_info({_, V1}) -> 
	<<?WLIST(V1, pt_public_act_copy)>>.

pt_draw_record({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WLIST(V2, pt_public_draw_record_list)>>.

pt_high_turntable_result({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WLIST(V3, pt_public_turntable_list)>>.

pt_normal_turntable_result({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WLIST(V2, pt_public_item_list)>>.

pt_turntable_info({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WLIST(V3, pt_public_turntable_list)>>.

pt_guild_view_member_info({_, V1, V2, V3, V4, V5, V6, V7, V8}) -> 
	<<?WBYTE(V1), ?WUINT32(V2), ?WBYTE(V3), ?WSTRING(V4), ?WSTRING(V5), ?WUINT32(V6), ?WLIST(V7, pt_public_on_battle_heros), ?WLIST(V8, pt_public_item_des)>>.

pt_draw_info({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WLIST(V2, pt_public_draw_list)>>.

pt_draw_result({_, V1, V2}) -> 
	<<?WBYTE(V1), ?WLIST(V2, pt_public_item_list)>>.

pt_recommend_guild_list({_, V1}) -> 
	<<?WLIST(V1, pt_public_guild_info_list)>>.

pt_create_guild({_, V1, V2, V3}) -> 
	<<?WBYTE(V1), ?WSTRING(V2), ?WSTRING(V3)>>.

pt_entourage_substitution_result({_, V1}) -> 
	<<?WUINT32(V1)>>.

pt_defender_zhenfa({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_shenqi_update({_, V1, V2}) -> 
	<<?WBYTE(V1), ?WUINT32(V2)>>.

pt_shenqi_illustration({_, V1}) -> 
	<<?WLIST(V1, pt_public_illustration_info)>>.

pt_on_battle_heros({_, V1}) -> 
	<<?WLIST(V1, pt_public_on_battle_data)>>.

pt_arena_challenge_single_info({_, V1, V2, V3, V4}) -> 
	<<?WUINT64(V1), ?WUINT32(V2), ?WUINT32(V3), ?WLIST(V4, pt_public_entourage_info_list)>>.

pt_time_reward({_, V1}) -> 
	<<?WUINT32(V1)>>.

pt_action_data_and_two_int_list({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WUINT64(V2), ?WLIST(V3, pt_public_two_int)>>.

pt_item_num_update({_, V1}) -> 
	<<?WLIST(V1, pt_public_two_int)>>.

pt_hero_illustration({_, V1}) -> 
	<<?WLIST(V1, pt_public_illustration_info)>>.

pt_arena_challenge_info({_, V1}) -> 
	<<?WLIST(V1, pt_public_challenge_list)>>.

pt_update_resource({_, V1}) -> 
	<<?WLIST(V1, pt_public_resource_list)>>.

pt_entourage_update({_, V1, V2}) -> 
	<<?WBYTE(V1), ?WUINT32(V2)>>.

pt_arena_challenge({_, V1, V2, V3, V4, V5}) -> 
	<<?WUINT32(V1), ?WUINT64(V2), ?WUINT32(V3), ?WUINT32(V4), ?WLIST(V5, pt_public_two_int)>>.

pt_scene_monster_die({_, V1}) -> 
	<<?WINT32(V1)>>.

pt_scene_end({_, V1}) -> 
	<<?WINT32(V1)>>.

pt_main_scene_result({_, V1, V2, V3, V4, V5, V6, V7, V8}) -> 
	<<?WINT32(V1), ?WINT32(V2), ?WUINT32(V3), ?WUINT32(V4), ?WUINT32(V5), ?WLIST(V6, pt_public_item_list), ?WLIST(V7, pt_public_scene_damage_list), ?WLIST(V8, pt_public_scene_damage_list)>>.

pt_main_scene_status({_, V1}) -> 
	<<?WUINT32(V1)>>.

pt_action_two_int_list({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WLIST(V2, pt_public_two_int)>>.

pt_hero_attr_info({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WLIST(V3, pt_public_attr_info)>>.

pt_gm_act_turntable_draw_result({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WLIST(V2, pt_public_item_list)>>.

pt_gm_act_turntable({_, V1, V2, V3, V4, V5}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WSTRING(V4), ?WLIST(V5, pt_public_act_turntable_des)>>.

pt_gm_act_rmb_package({_, V1, V2, V3, V4, V5}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WSTRING(V4), ?WLIST(V5, pt_public_act_rmb_package_des)>>.

pt_gm_act_diamond_package({_, V1, V2, V3, V4, V5}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WSTRING(V4), ?WLIST(V5, pt_public_act_diamond_package_des)>>.

pt_gm_act_point_package({_, V1, V2, V3, V4, V5}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WSTRING(V4), ?WLIST(V5, pt_public_act_point_package_des)>>.

pt_gm_activity({_, V1}) -> 
	<<?WLIST(V1, pt_public_activity_list)>>.

pt_gm_act_acc_login({_, V1, V2, V3, V4, V5, V6}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WUINT32(V4), ?WSTRING(V5), ?WLIST(V6, pt_public_acc_login_des)>>.

pt_gm_act_single_recharge({_, V1, V2, V3, V4, V5}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WSTRING(V4), ?WLIST(V5, pt_public_single_recharge_des)>>.

pt_arnea_store_info({_, V1}) -> 
	<<?WLIST(V1, pt_public_arena_store_info_list)>>.

pt_arnea_task_info({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3)>>.

pt_arnea_season_info({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_mystery_gift_info({_, V1, V2, V3, V4}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WSTRING(V3), ?WLIST(V4, pt_public_mystery_gift_info_des)>>.

pt_god_costume_draw({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WLIST(V2, pt_public_item_list)>>.

pt_god_costume_illustration_info({_, V1, V2}) -> 
	<<?WLIST(V1, pt_public_id_list), ?WLIST(V2, pt_public_id_list)>>.

pt_god_costume_info({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_legendary_level_exp_info({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WLIST(V2, pt_public_legendary_exp_buy_list)>>.

pt_legendary_level_start({_, V1}) -> 
	<<?WSTRING(V1)>>.

pt_entourage_challenge({_, V1, V2, V3, V4}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WLIST(V4, pt_public_entourage_challenge_info)>>.

pt_legendary_level_info({_, V1}) -> 
	<<?WLIST(V1, pt_public_legendary_level_info_list)>>.

pt_system_time_zone({_, V1}) -> 
	<<?WINT32(V1)>>.

pt_new_entourage_info({_, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WUINT32(V4), ?WUINT32(V5), ?WUINT32(V6), ?WUINT32(V7), ?WUINT32(V8), ?WUINT32(V9), ?WUINT32(V10), ?WUINT32(V11), ?WUINT32(V12)>>.

pt_special_upgrade({_, V1}) -> 
	<<?WUINT32(V1)>>.

pt_return_investment_info({_, V1, V2, V3, V4}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WSTRING(V3), ?WLIST(V4, pt_public_return_investment_des)>>.

pt_random_gift_package({_, V1, V2, V3, V4}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WUINT32(V4)>>.

pt_guild_impeach({_, V1}) -> 
	<<?WSTRING(V1)>>.

pt_head_suit_info({_, V1}) -> 
	<<?WLIST(V1, pt_public_head_list)>>.

pt_head_lev_info({_, V1}) -> 
	<<?WLIST(V1, pt_public_head_list)>>.

pt_shenqi_awaken({_, V1}) -> 
	<<?WUINT32(V1)>>.

pt_melleboss_revive({_, V1}) -> 
	<<?WUINT32(V1)>>.

pt_revive_info_new({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3)>>.

pt_melle_boss_scene_info({_, V1, V2, V3, V4}) -> 
	<<?WUINT64(V1), ?WUINT32(V2), ?WUINT32(V3), ?WUINT32(V4)>>.

pt_scene_change_camp({_, V1, V2}) -> 
	<<?WUINT64(V1), ?WUINT32(V2)>>.

pt_melleboss_info({_, V1, V2, V3, V4}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WLIST(V4, pt_public_melleboss_list)>>.

pt_maze_ranklist({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WLIST(V3, pt_public_maze_ranklist)>>.

pt_lottery_carousel_list({_, V1}) -> 
	<<?WLIST(V1, pt_public_id_list)>>.

pt_gm_act_lottery_carousel({_, V1, V2, V3, V4, V5}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WSTRING(V4), ?WLIST(V5, pt_public_act_lottery_carousel_des)>>.

pt_gm_act_literature_collection({_, V1, V2, V3, V4, V5}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WSTRING(V4), ?WLIST(V5, pt_public_act_literature_collection_des)>>.

pt_global_guild_ranklist_info({_, V1, V2, V3, V4}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WLIST(V4, pt_public_global_guild_ranklist)>>.

pt_sailing_guard_info({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WLIST(V3, pt_public_guard_list)>>.

pt_sailing_plunder_info({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WLIST(V2, pt_public_plunder_list)>>.

pt_sailing_info({_, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WUINT32(V4), ?WUINT32(V5), ?WUINT32(V6), ?WUINT32(V7), ?WSTRING(V8), ?WUINT32(V9), ?WUINT32(V10), ?WLIST(V11, pt_public_sailing_record)>>.

pt_maze_event({_, V1, V2, V3, V4, V5, V6, V7, V8, V9}) -> 
	<<?WUINT32(V1), ?WSTRING(V2), ?WUINT32(V3), ?WUINT32(V4), ?WUINT32(V5), ?WUINT32(V6), ?WUINT32(V7), ?WSTRING(V8), ?WUINT32(V9)>>.

pt_maze_info({_, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WUINT32(V4), ?WUINT32(V5), ?WUINT32(V6), ?WUINT32(V7), ?WUINT32(V8), ?WUINT32(V9), ?WLIST(V10, pt_public_item_list), ?WLIST(V11, pt_public_maze_record)>>.

pt_mining_list({_, V1}) -> 
	<<?WLIST(V1, pt_public_mining_list_des)>>.

pt_mining_info({_, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12}) -> 
	<<?WBYTE(V1), ?WUINT32(V2), ?WUINT32(V3), ?WUINT32(V4), ?WUINT32(V5), ?WUINT32(V6), ?WUINT32(V7), ?WUINT16(V8), ?WUINT16(V9), ?WUINT16(V10), ?WLIST(V11, pt_public_property_list), ?WLIST(V12, pt_public_mining_defend_des)>>.

pt_ele_pearl_info({_, V1, V2, V3, V4, V5}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WUINT32(V4), ?WUINT32(V5)>>.

pt_talent_draw({_, V1, V2}) -> 
	<<?WLIST(V1, uint32), ?WLIST(V2, pt_public_item_list)>>.

pt_talent_info({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WLIST(V2, pt_public_talent_skill_des)>>.

pt_gm_act_recharge_point({_, V1, V2, V3, V4, V5}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WSTRING(V4), ?WLIST(V5, pt_public_act_recharge_point_des)>>.

pt_praise_reward({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_gm_act_limit_double_recharge({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WSTRING(V3)>>.

pt_global_arena_result({_, V1, V2, V3, V4, V5, V6}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WUINT32(V4), ?WUINT32(V5), ?WLIST(V6, pt_public_item_list)>>.

pt_global_arena_match_start({_, V1}) -> 
	<<?WUINT32(V1)>>.

pt_global_arena_match_succ({_, V1}) -> 
	<<?WUINT32(V1)>>.

pt_global_last_arena_ranklist({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WLIST(V2, pt_public_global_arena_last_ranklist_info)>>.

pt_global_arena_ranklist({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WLIST(V2, pt_public_global_arena_ranklist_info)>>.

pt_global_arena_info({_, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WUINT32(V4), ?WUINT32(V5), ?WLIST(V6, pt_public_global_arena_daily_task), ?WUINT32(V7), ?WLIST(V8, pt_public_global_arena_daily_log), ?WUINT32(V9), ?WUINT32(V10), ?WUINT32(V11)>>.

pt_guild_operation({_, V1}) -> 
	<<?WUINT32(V1)>>.

pt_guild_blessing_info({_, V1}) -> 
	<<?WUINT32(V1)>>.

pt_worldlevel_info({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_usr_title({_, V1, V2, V3, V4}) -> 
	<<?WUINT64(V1), ?WUINT16(V2), ?WUINT32(V3), ?WLIST(V4, pt_public_title_chpprof)>>.

pt_req_entourage_create_model({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_entourage_create_model({_, V1, V2, V3, V4, V5, V6, V7, V8}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WUINT32(V4), ?WUINT32(V5), ?WUINT32(V6), ?WUINT32(V7), ?WUINT32(V8)>>.

pt_entourage_revive_new({_, V1}) -> 
	<<?WUINT32(V1)>>.

pt_entourage_die_new({_, V1}) -> 
	<<?WLIST(V1, pt_public_dead_entourage_list)>>.

pt_entourage_succeed_new({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_entourage_info_new({_, V1, V2, V3, V4, V5}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WUINT32(V4), ?WLIST(V5, pt_public_property_list)>>.

pt_entourage_list_new({_, V1}) -> 
	<<?WLIST(V1, pt_public_entourage_list)>>.

pt_sign_day({_, V1}) -> 
	<<?WUINT32(V1)>>.

pt_entourage_property({_, V1}) -> 
	<<?WLIST(V1, pt_public_property_list)>>.

pt_action_string_and_data({_, V1, V2, V3}) -> 
	<<?WINT32(V1), ?WINT32(V2), ?WSTRING(V3)>>.

pt_rechargejifen_shop({_, V1, V2, V3, V4, V5, V6}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WUINT32(V4), ?WSTRING(V5), ?WLIST(V6, pt_public_jifen_shop)>>.

pt_consumejifen_shop({_, V1, V2, V3, V4, V5, V6}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WUINT32(V4), ?WSTRING(V5), ?WLIST(V6, pt_public_jifen_shop)>>.

pt_recharge_global_rank_info({_, V1, V2, V3, V4, V5, V6, V7, V8, V9}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WUINT32(V4), ?WUINT32(V5), ?WUINT32(V6), ?WSTRING(V7), ?WLIST(V8, pt_public_global_rewards_info), ?WLIST(V9, pt_public_recharge_global_rank_list)>>.

pt_consume_global_rank_info({_, V1, V2, V3, V4, V5, V6, V7, V8, V9}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WUINT32(V4), ?WUINT32(V5), ?WUINT32(V6), ?WSTRING(V7), ?WLIST(V8, pt_public_global_rewards_info), ?WLIST(V9, pt_public_consume_global_rank_list)>>.

pt_usr_head({_, V1, V2, V3}) -> 
	<<?WUINT64(V1), ?WUINT32(V2), ?WLIST(V3, pt_public_usrid_list)>>.

pt_entourage_debt_exchange_succ({_, V1, V2}) -> 
	<<?WSTRING(V1), ?WUINT32(V2)>>.

pt_limit_achievement_info({_, V1, V2, V3, V4}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WSTRING(V3), ?WLIST(V4, pt_public_limit_achievement_des)>>.

pt_continuous_recharge_info({_, V1, V2, V3, V4, V5}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WSTRING(V4), ?WLIST(V5, pt_public_continuous_recharge_des)>>.

pt_entourage_rune_info({_, V1, V2, V3, V4, V5}) -> 
	<<?WINT32(V1), ?WINT32(V2), ?WINT32(V3), ?WINT32(V4), ?WLIST(V5, pt_public_property_list)>>.

pt_action_list_and_data({_, V1, V2, V3}) -> 
	<<?WINT32(V1), ?WLIST(V2, pt_public_id_list), ?WINT32(V3)>>.

pt_action_tri_int({_, V1, V2, V3, V4}) -> 
	<<?WINT32(V1), ?WUINT64(V2), ?WUINT64(V3), ?WUINT64(V4)>>.

pt_entourage_revive({_, V1}) -> 
	<<?WUINT32(V1)>>.

pt_entourage_die({_, V1}) -> 
	<<?WUINT32(V1)>>.

pt_gm_act_limit_summon({_, V1, V2, V3, V4, V5, V6, V7}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WSTRING(V3), ?WUINT32(V4), ?WUINT32(V5), ?WLIST(V6, pt_public_limit_summon_rank_reward_des), ?WLIST(V7, pt_public_limit_summon_ranking_des)>>.

pt_all_system_activity({_, V1}) -> 
	<<?WLIST(V1, pt_public_system_activity_info)>>.

pt_system_activity_limitboss({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_system_activity({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_gm_act_lv_rank({_, V1, V2, V3, V4, V5, V6}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WSTRING(V3), ?WUINT32(V4), ?WLIST(V5, pt_public_lv_rank_reward_des), ?WLIST(V6, pt_public_gm_act_lv_rank_des)>>.

pt_random_task({_, V1, V2, V3, V4, V5, V6, V7, V8}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WUINT32(V4), ?WUINT32(V5), ?WUINT32(V6), ?WUINT32(V7), ?WUINT32(V8)>>.

pt_gm_act_reset_recharge({_, V1, V2, V3, V4}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WSTRING(V3), ?WLIST(V4, pt_public_gm_act_reset_recharge_des)>>.

pt_artifact_fast({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3)>>.

pt_revive_notify({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_client_error_report({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WSTRING(V2)>>.

pt_gm_act_package({_, V1, V2, V3, V4}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WSTRING(V3), ?WLIST(V4, pt_public_gm_act_package_des)>>.

pt_gm_act_treasure_record({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WLIST(V2, pt_public_treasure_record_des)>>.

pt_gm_act_treasure({_, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WSTRING(V3), ?WUINT32(V4), ?WUINT32(V5), ?WUINT32(V6), ?WUINT32(V7), ?WUINT32(V8), ?WLIST(V9, pt_public_item_list), ?WLIST(V10, pt_public_item_list), ?WLIST(V11, pt_public_item_list), ?WLIST(V12, pt_public_treasure_exchange_des), ?WLIST(V13, pt_public_treasure_rank_reward_des), ?WLIST(V14, pt_public_treasure_ranking_des)>>.

pt_recharge_return({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_copy_data({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_worldboss_inspire({_, V1}) -> 
	<<?WUINT32(V1)>>.

pt_worldboss_damage_rank({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WLIST(V2, pt_public_worldboss_damage_info)>>.

pt_worldboss_times({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_worldboss_list({_, V1}) -> 
	<<?WLIST(V1, pt_public_worldboss_info)>>.

pt_building_upgrade_complete({_, V1}) -> 
	<<?WUINT32(V1)>>.

pt_home_building_produce_begin({_, V1}) -> 
	<<?WUINT32(V1)>>.

pt_home_building_upgrade_begin({_, V1}) -> 
	<<?WUINT32(V1)>>.

pt_home_building_req_produce({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WLIST(V2, uint8)>>.

pt_home_building_gather_succ({_, V1}) -> 
	<<?WUINT32(V1)>>.

pt_home_building_factory_info({_, V1, V2, V3, V4, V5, V6}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WUINT32(V4), ?WUINT32(V5), ?WLIST(V6, pt_public_item_list)>>.

pt_home_building_mine_info({_, V1, V2, V3, V4, V5, V6}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WLIST(V4, pt_public_home_building_worker_info), ?WLIST(V5, pt_public_home_building_worker_info), ?WUINT32(V6)>>.

pt_home_building_common_detail({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_home_building_list({_, V1, V2}) -> 
	<<?WUINT64(V1), ?WLIST(V2, pt_public_home_building_base_info)>>.

pt_online_status({_, V1, V2}) -> 
	<<?WUINT64(V1), ?WBYTE(V2)>>.

pt_barrier_rewards_info({_, V1, V2}) -> 
	<<?WINT32(V1), ?WLIST(V2, pt_public_barrier_rewards_des)>>.

pt_recent_chat({_, V1}) -> 
	<<?WLIST(V1, pt_public_recent_chat_msg)>>.

pt_shenqi_info({_, V1}) -> 
	<<?WUINT32(V1)>>.

pt_gm_act_double({_, V1, V2, V3, V4}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WSTRING(V3), ?WLIST(V4, pt_public_gm_act_double_des)>>.

pt_gm_act_discount({_, V1, V2, V3, V4}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WSTRING(V3), ?WLIST(V4, pt_public_gm_act_discount_des)>>.

pt_acc_cost({_, V1, V2, V3, V4, V5, V6}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WSTRING(V3), ?WSTRING(V4), ?WUINT32(V5), ?WLIST(V6, pt_public_acc_cost_des)>>.

pt_gm_act_drop({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WSTRING(V3)>>.

pt_gm_act_sale({_, V1, V2, V3, V4, V5}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WSTRING(V3), ?WUINT32(V4), ?WLIST(V5, pt_public_gm_act_sale_des)>>.

pt_gm_act_exchange({_, V1, V2, V3, V4}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WSTRING(V3), ?WLIST(V4, pt_public_gm_act_exchange_des)>>.

pt_gm_act_week_task({_, V1, V2, V3, V4}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WSTRING(V3), ?WLIST(V4, pt_public_gm_act_week_task_des)>>.

pt_show_fetched_reward({_, V1, V2, V3}) -> 
	<<?WLIST(V1, pt_public_friend_name_list), ?WUINT32(V2), ?WLIST(V3, pt_public_item_list)>>.

pt_acc_recharge_info({_, V1, V2, V3, V4}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WSTRING(V3), ?WLIST(V4, pt_public_acc_recharge_des)>>.

pt_req_guild_stone_get({_, V1}) -> 
	<<?WUINT32(V1)>>.

pt_guild_stone_donation({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_req_guild_stone_info({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WLIST(V2, pt_public_guild_stone_list), ?WUINT32(V3)>>.

pt_task_step_info({_, V1, V2, V3, V4}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WUINT32(V4)>>.

pt_task_step({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_req_fly_planes({_, V1}) -> 
	<<?WINT32(V1)>>.

pt_stroy_reward_info({_, V1}) -> 
	<<?WLIST(V1, uint32)>>.

pt_story_show({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_update_guild_inspire_times({_, V1}) -> 
	<<?WUINT32(V1)>>.

pt_update_guild_boss_reward({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WLIST(V2, pt_public_id_list), ?WLIST(V3, pt_public_id_list)>>.

pt_time_reward_item({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WLIST(V2, pt_public_time_reward)>>.

pt_time_reward_info({_, V1, V2, V3, V4}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WLIST(V3, uint32), ?WUINT32(V4)>>.

pt_req_setting_pick_item({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3)>>.

pt_update_quick_fight_info({_, V1, V2, V3, V4, V5, V6, V7}) -> 
	<<?WINT32(V1), ?WINT32(V2), ?WINT32(V3), ?WUINT32(V4), ?WUINT32(V5), ?WUINT32(V6), ?WLIST(V7, pt_public_item_list)>>.

pt_req_quick_fight({_, V1}) -> 
	<<?WUINT32(V1)>>.

pt_clear_skill_cd({_, V1}) -> 
	<<?WUINT32(V1)>>.

pt_bslx(_) -> 
	<<>>.

pt_compose_info({_, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14, V15, V16, V17}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WUINT32(V4), ?WUINT32(V5), ?WUINT32(V6), ?WUINT32(V7), ?WUINT32(V8), ?WLIST(V9, uint32), ?WLIST(V10, uint32), ?WLIST(V11, uint32), ?WUINT32(V12), ?WUINT32(V13), ?WUINT32(V14), ?WUINT32(V15), ?WUINT32(V16), ?WUINT32(V17)>>.

pt_melting_suc({_, V1}) -> 
	<<?WINT32(V1)>>.

pt_req_melting({_, V1}) -> 
	<<?WLIST(V1, uint32)>>.

pt_sdk_auth_failed({_, V1}) -> 
	<<?WSTRING(V1)>>.

pt_flash_gift_bag_time({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_flash_gift_bag_info({_, V1}) -> 
	<<?WLIST(V1, pt_public_flash_gift_bag_list)>>.

pt_sky_ladder_scene_result({_, V1}) -> 
	<<?WINT32(V1)>>.

pt_sky_ladder_reward({_, V1}) -> 
	<<?WLIST(V1, pt_public_reward_info)>>.

pt_sky_ladder_info({_, V1, V2, V3, V4, V5, V6, V7, V8}) -> 
	<<?WINT32(V1), ?WINT32(V2), ?WINT32(V3), ?WINT32(V4), ?WINT32(V5), ?WINT32(V6), ?WINT32(V7), ?WINT32(V8)>>.

pt_artifact_forging(_) -> 
	<<>>.

pt_pet_book({_, V1}) -> 
	<<?WLIST(V1, pt_public_pet_skill_books)>>.

pt_join_hero_challenge({_, V1}) -> 
	<<?WLIST(V1, uint32)>>.

pt_pet_collect({_, V1}) -> 
	<<?WLIST(V1, pt_public_pet_coll_info)>>.

pt_hero_challenge_info({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_mystery_store_buy({_, V1}) -> 
	<<?WLIST(V1, pt_public_mystery_store_item_list)>>.

pt_mystery_store_data({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WLIST(V2, pt_public_mystery_store_item_list)>>.

pt_stamina_time({_, V1}) -> 
	<<?WUINT32(V1)>>.

pt_copy_time_rewards({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WLIST(V2, uint32)>>.

pt_military_skill({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WLIST(V2, pt_public_military_skill_info)>>.

pt_glory_sword({_, V1}) -> 
	<<?WUINT32(V1)>>.

pt_lost_item_recover({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3)>>.

pt_dress_suit_data({_, V1}) -> 
	<<?WLIST(V1, pt_public_id_list)>>.

pt_recharge_package_data({_, V1}) -> 
	<<?WUINT32(V1)>>.

pt_turning_wheel_hide({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_turning_wheel_config({_, V1}) -> 
	<<?WLIST(V1, pt_public_turning_wheel_config_list)>>.

pt_gm_continu_recharge_reward(_) -> 
	<<>>.

pt_gm_continu_recharge_close({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_gm_continu_recharge({_, V1}) -> 
	<<?WLIST(V1, pt_public_diamond_lev_list)>>.

pt_rank_recharge_activity_time({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_rank_consume_activity_time({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_recharge_rank_info({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WLIST(V2, pt_public_recharge_rank_list)>>.

pt_consume_rank_info({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WLIST(V2, pt_public_consume_rank_list)>>.

pt_treasure_times({_, V1}) -> 
	<<?WUINT32(V1)>>.

pt_treasure_all_rewards({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WLIST(V3, pt_public_treasure_rewards_info)>>.

pt_extreme_luxury_gift({_, V1, V2}) -> 
	<<?WLIST(V1, pt_public_extreme_luxury_gift_info), ?WLIST(V2, pt_public_extreme_ranklist)>>.

pt_treasure_rewards({_, V1}) -> 
	<<?WLIST(V1, pt_public_treasure_rewards_info)>>.

pt_treasure_activity_time({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_all_people_info({_, V1}) -> 
	<<?WLIST(V1, pt_public_all_people_info)>>.

pt_share_info({_, V1}) -> 
	<<?WUINT32(V1)>>.

pt_other_usr_skill_info({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WLIST(V2, pt_public_other_usr_skill)>>.

pt_flying_shoes(_) -> 
	<<>>.

pt_entourage_mastery_grow({_, V1}) -> 
	<<?WLIST(V1, pt_public_entourage_mastery_info)>>.

pt_give_red_tips(_) -> 
	<<>>.

pt_rev_red_response({_, V1, V2, V3, V4}) -> 
	<<?WUINT64(V1), ?WUINT32(V2), ?WUINT32(V3), ?WUINT32(V4)>>.

pt_pwd_red_info({_, V1}) -> 
	<<?WLIST(V1, pt_public_pwd_red_list)>>.

pt_give_pwd_red({_, V1, V2, V3}) -> 
	<<?WSTRING(V1), ?WUINT32(V2), ?WUINT32(V3)>>.

pt_abyss_box({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_open_svr_time_limit({_, V1}) -> 
	<<?WINT32(V1)>>.

pt_entourage_expedition_reward({_, V1, V2, V3, V4}) -> 
	<<?WLIST(V1, pt_public_id_list), ?WINT32(V2), ?WLIST(V3, pt_public_item_list), ?WINT32(V4)>>.

pt_call_up_info({_, V1, V2, V3, V4}) -> 
	<<?WUINT32(V1), ?WUINT64(V2), ?WSTRING(V3), ?WUINT32(V4)>>.

pt_send_red_packet_info({_, V1, V2, V3, V4, V5}) -> 
	<<?WUINT64(V1), ?WSTRING(V2), ?WUINT32(V3), ?WUINT32(V4), ?WUINT32(V5)>>.

pt_guild_team_copy_succeed({_, V1}) -> 
	<<?WLIST(V1, pt_public_get_success_list)>>.

pt_guild_call_upon_broadcast({_, V1}) -> 
	<<?WUINT32(V1)>>.

pt_req_guild_call_upon({_, V1, V2, V3, V4}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WUINT32(V4)>>.

pt_guild_team_info({_, V1}) -> 
	<<?WLIST(V1, pt_public_guild_team_list)>>.

pt_guild_team_copy_info({_, V1, V2, V3, V4}) -> 
	<<?WUINT32(V1), ?WUINT64(V2), ?WUINT32(V3), ?WLIST(V4, pt_public_guild_team_copy_list)>>.

pt_climb_tower_first_reward({_, V1}) -> 
	<<?WUINT32(V1)>>.

pt_climb_tower_fast({_, V1}) -> 
	<<?WUINT32(V1)>>.

pt_climb_tower_reset(_) -> 
	<<>>.

pt_red_packet_rewards({_, V1}) -> 
	<<?WUINT32(V1)>>.

pt_red_packet_surplus_time({_, V1, V2, V3, V4, V5}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WUINT32(V4), ?WUINT32(V5)>>.

pt_climb_tower_data({_, V1, V2, V3, V4, V5}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WUINT32(V4), ?WLIST(V5, pt_public_climb_tower_first_reward)>>.

pt_team_process({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3)>>.

pt_inscription_info({_, V1}) -> 
	<<?WLIST(V1, pt_public_inscription_list)>>.

pt_strength_oven_info({_, V1}) -> 
	<<?WLIST(V1, pt_public_strength_oven_list)>>.

pt_expedition_request({_, V1, V2}) -> 
	<<?WINT32(V1), ?WLIST(V2, pt_public_exped_entourage_list)>>.

pt_rent_entourage_info({_, V1}) -> 
	<<?WLIST(V1, pt_public_rent_entourage_list)>>.

pt_exped_task({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WLIST(V3, pt_public_id_list)>>.

pt_doing_exped_task({_, V1}) -> 
	<<?WLIST(V1, pt_public_expedition_list)>>.

pt_rent_entourage({_, V1, V2}) -> 
	<<?WINT32(V1), ?WINT32(V2)>>.

pt_seven_day_target_succeed({_, V1}) -> 
	<<?WLIST(V1, pt_public_item_list)>>.

pt_seven_day_target_rewards_info({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WLIST(V2, pt_public_seven_day_target_rewards_list)>>.

pt_seven_day_target_info({_, V1}) -> 
	<<?WLIST(V1, pt_public_seven_day_target_info_list)>>.

pt_open_svr_five_day_camp(_) -> 
	<<>>.

pt_open_svr_five_day_data({_, V1, V2, V3, V4}) -> 
	<<?WINT32(V1), ?WINT32(V2), ?WINT32(V3), ?WLIST(V4, pt_public_five_act_info)>>.

pt_open_svr_five_day_time({_, V1}) -> 
	<<?WINT32(V1)>>.

pt_boss_born_and_die({_, V1, V2}) -> 
	<<?WINT32(V1), ?WINT32(V2)>>.

pt_hide_boss_response({_, V1, V2}) -> 
	<<?WINT32(V1), ?WINT32(V2)>>.

pt_hide_boss_data({_, V1}) -> 
	<<?WLIST(V1, pt_public_id_list)>>.

pt_war_ready_finish(_) -> 
	<<>>.

pt_scramble_info({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_team_war_seq({_, V1}) -> 
	<<?WUINT32(V1)>>.

pt_blacklist_info({_, V1}) -> 
	<<?WLIST(V1, pt_public_blacklist_list)>>.

pt_guild_impeach_president({_, V1}) -> 
	<<?WUINT32(V1)>>.

pt_req_atlas_team_info(_) -> 
	<<>>.

pt_growth_bible_info({_, V1}) -> 
	<<?WLIST(V1, pt_public_growth_bible_info)>>.

pt_usr_info_pet({_, V1, V2, V3}) -> 
	<<?WLIST(V1, pt_public_pet_property_list), ?WLIST(V2, pt_public_other_pet_list), ?WUINT32(V3)>>.

pt_usr_info_mount({_, V1, V2, V3, V4}) -> 
	<<?WUINT32(V1), ?WLIST(V2, pt_public_illusion_list), ?WLIST(V3, pt_public_mount_equip_list), ?WUINT32(V4)>>.

pt_copy_notice_revive(_) -> 
	<<>>.

pt_atlas_team_info({_, V1}) -> 
	<<?WLIST(V1, pt_public_atlas_team_list)>>.

pt_war_damage_rank({_, V1, V2}) -> 
	<<?WINT32(V1), ?WLIST(V2, pt_public_war_damage)>>.

pt_update_name_succeed({_, V1}) -> 
	<<?WSTRING(V1)>>.

pt_updata_name_card({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WSTRING(V2)>>.

pt_scene_full_tips(_) -> 
	<<>>.

pt_ret_war_usr_area({_, V1}) -> 
	<<?WUINT32(V1)>>.

pt_ret_gamble_record({_, V1}) -> 
	<<?WLIST(V1, pt_public_gamble_record)>>.

pt_ret_guide_tag_point({_, V1, V2, V3, V4, V5, V6, V7}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WUINT32(V4), ?WUINT32(V5), ?WUINT32(V6), ?WUINT32(V7)>>.

pt_ret_wheel_info({_, V1}) -> 
	<<?WUINT16(V1)>>.

pt_national_war_start_time({_, V1, V2}) -> 
	<<?WINT32(V1), ?WINT32(V2)>>.

pt_national_war_tips({_, V1}) -> 
	<<?WLIST(V1, pt_public_boss_info)>>.

pt_flag_status({_, V1, V2}) -> 
	<<?WINT32(V1), ?WINT32(V2)>>.

pt_flag_count({_, V1, V2, V3}) -> 
	<<?WINT32(V1), ?WINT32(V2), ?WINT32(V3)>>.

pt_ret_fast_copy({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WBYTE(V2), ?WLIST(V3, pt_public_item_list)>>.

pt_copy_rewards_info({_, V1}) -> 
	<<?WLIST(V1, pt_public_item_list)>>.

pt_picked_loginact({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WLIST(V2, pt_public_item_list)>>.

pt_picked_exchange({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WLIST(V2, pt_public_item_list)>>.

pt_picked_gift_recharge({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WLIST(V3, pt_public_item_list)>>.

pt_picked_repeat_recharge({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WLIST(V2, pt_public_item_list)>>.

pt_picked_single_recharge({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WLIST(V2, pt_public_item_list)>>.

pt_loginact_info({_, V1, V2, V3, V4, V5}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WUINT32(V4), ?WLIST(V5, pt_public_loginact_des)>>.

pt_exchange_info({_, V1, V2, V3, V4}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WLIST(V4, pt_public_exchange_des)>>.

pt_gift_recharge_info({_, V1, V2, V3, V4, V5, V6, V7}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WUINT32(V4), ?WUINT32(V5), ?WUINT32(V6), ?WLIST(V7, pt_public_gift_des)>>.

pt_repeat_recharge_info({_, V1, V2, V3, V4, V5, V6, V7}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WUINT32(V4), ?WUINT32(V5), ?WUINT32(V6), ?WLIST(V7, pt_public_repeat_des)>>.

pt_single_recharge_info({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WLIST(V3, pt_public_single_des)>>.

pt_fortress_task_info({_, V1, V2, V3, V4}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WUINT32(V4)>>.

pt_guild_post({_, V1}) -> 
	<<?WUINT32(V1)>>.

pt_national_war_show_info({_, V1, V2, V3}) -> 
	<<?WINT32(V1), ?WINT32(V2), ?WINT32(V3)>>.

pt_wechat_rewards({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_ret_items_buffer({_, V1, V2}) -> 
	<<?WUINT16(V1), ?WLIST(V2, pt_public_item_list)>>.

pt_ret_gamble_price({_, V1, V2, V3}) -> 
	<<?WBYTE(V1), ?WLIST(V2, pt_public_id_list), ?WUINT16(V3)>>.

pt_week_rewards_info({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WLIST(V2, pt_public_week_rewards_list)>>.

pt_ret_gamble_info({_, V1, V2, V3, V4, V5, V6}) -> 
	<<?WUINT16(V1), ?WBYTE(V2), ?WUINT16(V3), ?WUINT16(V4), ?WBYTE(V5), ?WUINT16(V6)>>.

pt_match_finish(_) -> 
	<<>>.

pt_ret_gs_rewards({_, V1, V2}) -> 
	<<?WBYTE(V1), ?WLIST(V2, pt_public_equip_rewards_list)>>.

pt_equip_and_entourage_succeed({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_equip_rewards({_, V1}) -> 
	<<?WLIST(V1, pt_public_equip_rewards_list)>>.

pt_entourage_star_rewards({_, V1}) -> 
	<<?WLIST(V1, pt_public_entourage_star_rewards)>>.

pt_royal_box_succeed({_, V1, V2}) -> 
	<<?WINT32(V1), ?WLIST(V2, pt_public_recycle_list)>>.

pt_royal_box_info({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WINT32(V2), ?WLIST(V3, pt_public_royal_box_list)>>.

pt_ans_match_war({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WBYTE(V2), ?WBYTE(V3)>>.

pt_war_over({_, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13}) -> 
	<<?WUINT32(V1), ?WBYTE(V2), ?WUINT32(V3), ?WLIST(V4, pt_public_item_list), ?WUINT32(V5), ?WUINT32(V6), ?WUINT32(V7), ?WUINT32(V8), ?WUINT32(V9), ?WUINT32(V10), ?WUINT32(V11), ?WUINT32(V12), ?WUINT32(V13)>>.

pt_ret_war_report({_, V1, V2, V3, V4, V5, V6, V7, V8, V9}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WUINT32(V4), ?WUINT16(V5), ?WUINT16(V6), ?WUINT16(V7), ?WUINT16(V8), ?WUINT16(V9)>>.

pt_national_war_call_broadcast({_, V1}) -> 
	<<?WSTRING(V1)>>.

pt_national_war_scrolls({_, V1}) -> 
	<<?WLIST(V1, pt_public_present_entourage_scrolls)>>.

pt_national_war_call({_, V1}) -> 
	<<?WINT32(V1)>>.

pt_national_war_record({_, V1}) -> 
	<<?WLIST(V1, pt_public_national_war_record)>>.

pt_national_war_data({_, V1, V2, V3, V4, V5, V6, V7, V8}) -> 
	<<?WINT32(V1), ?WINT32(V2), ?WINT32(V3), ?WINT32(V4), ?WINT32(V5), ?WINT32(V6), ?WINT32(V7), ?WINT32(V8)>>.

pt_ret_war_times({_, V1}) -> 
	<<?WLIST(V1, pt_public_war_info_list)>>.

pt_entourage_star({_, V1, V2}) -> 
	<<?WUINT64(V1), ?WUINT32(V2)>>.

pt_guild_task({_, V1, V2, V3, V4}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WUINT32(V4)>>.

pt_task_rewards_info({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WLIST(V3, pt_public_task_rewards_list)>>.

pt_all_star({_, V1}) -> 
	<<?WUINT32(V1)>>.

pt_buy_coin({_, V1, V2, V3, V4, V5, V6}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WUINT32(V4), ?WUINT32(V5), ?WUINT32(V6)>>.

pt_move_sand_buff_id({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3)>>.

pt_move_sand_buff({_, V1}) -> 
	<<?WLIST(V1, pt_public_move_sand_list)>>.

pt_return_quick_buy({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3)>>.

pt_req_quick_buy({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3)>>.

pt_retreve_succeed({_, V1}) -> 
	<<?WINT32(V1)>>.

pt_retrueve_info({_, V1}) -> 
	<<?WLIST(V1, pt_public_retrueve_info)>>.

pt_update_camp_leader({_, V1}) -> 
	<<?WUINT32(V1)>>.

pt_gen_order({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WSTRING(V2)>>.

pt_login_auth_succ({_, V1}) -> 
	<<?WSTRING(V1)>>.

pt_sdk_login({_, V1, V2, V3, V4, V5, V6, V7}) -> 
	<<?WSTRING(V1), ?WSTRING(V2), ?WSTRING(V3), ?WUINT32(V4), ?WUINT32(V5), ?WUINT32(V6), ?WSTRING(V7)>>.

pt_off_line_succeed(_) -> 
	<<>>.

pt_off_line_exp({_, V1, V2, V3, V4, V5}) -> 
	<<?WINT32(V1), ?WINT32(V2), ?WINT32(V3), ?WINT32(V4), ?WINT32(V5)>>.

pt_dart_time({_, V1}) -> 
	<<?WUINT32(V1)>>.

pt_system_time({_, V1, V2}) -> 
	<<?WINT32(V1), ?WINT32(V2)>>.

pt_camp_leader_info({_, V1, V2, V3, V4, V5, V6, V7, V8}) -> 
	<<?WUINT64(V1), ?WSTRING(V2), ?WINT32(V3), ?WINT32(V4), ?WINT32(V5), ?WINT32(V6), ?WINT32(V7), ?WLIST(V8, pt_public_deputy_list)>>.

pt_dart_pos({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3)>>.

pt_exit_queue(_) -> 
	<<>>.

pt_ref_queue(_) -> 
	<<>>.

pt_abddart_activity({_, V1}) -> 
	<<?WLIST(V1, pt_public_abddart_activity_list)>>.

pt_camp_skill({_, V1}) -> 
	<<?WINT32(V1)>>.

pt_use_item_groupId({_, V1}) -> 
	<<?WLIST(V1, pt_public_use_item_groupId)>>.

pt_dart_activity_state({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WLIST(V2, pt_public_activity_id_list)>>.

pt_first_extend_recharge({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WLIST(V2, pt_public_item_list)>>.

pt_recharge_data({_, V1}) -> 
	<<?WLIST(V1, pt_public_recharge_list)>>.

pt_entourage_fetter_info({_, V1}) -> 
	<<?WLIST(V1, pt_public_entourage_fetter_info)>>.

pt_recharge_succ({_, V1}) -> 
	<<?WINT32(V1)>>.

pt_entourage_soul_link({_, V1, V2}) -> 
	<<?WLIST(V1, pt_public_entourage_soul_link), ?WLIST(V2, uint32)>>.

pt_update_charge_active({_, V1, V2}) -> 
	<<?WBYTE(V1), ?WINT32(V2)>>.

pt_ret_charge_active({_, V1}) -> 
	<<?WLIST(V1, pt_public_charge_active)>>.

pt_honor_kill({_, V1, V2, V3}) -> 
	<<?WINT32(V1), ?WINT32(V2), ?WINT32(V3)>>.

pt_first_recharge({_, V1, V2, V3, V4}) -> 
	<<?WINT32(V1), ?WINT32(V2), ?WINT32(V3), ?WINT32(V4)>>.

pt_activity_success({_, V1}) -> 
	<<?WLIST(V1, pt_public_item_list)>>.

pt_vip_info({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WLIST(V2, pt_public_vip_rewards_list)>>.

pt_unlock_atlas({_, V1}) -> 
	<<?WLIST(V1, pt_public_unlock_atlas_list)>>.

pt_arena_start_time({_, V1}) -> 
	<<?WINT32(V1)>>.

pt_paragon_level({_, V1}) -> 
	<<?WLIST(V1, pt_public_paragon_level)>>.

pt_item_model_clothes({_, V1}) -> 
	<<?WLIST(V1, pt_public_item_model_clothes)>>.

pt_ret_achieves({_, V1}) -> 
	<<?WLIST(V1, pt_public_achieve)>>.

pt_scene_branching_info({_, V1}) -> 
	<<?WLIST(V1, pt_public_scene_branching_info)>>.

pt_scene_load(_) -> 
	<<>>.

pt_ptc_item_compound_succeed({_, V1}) -> 
	<<?WLIST(V1, pt_public_get_success_list)>>.

pt_camp_killed_military({_, V1}) -> 
	<<?WUINT32(V1)>>.

pt_chapter_succeed(_) -> 
	<<>>.

pt_ret_fast_trials({_, V1, V2, V3, V4, V5}) -> 
	<<?WINT32(V1), ?WINT32(V2), ?WINT32(V3), ?WINT32(V4), ?WLIST(V5, pt_public_item_list)>>.

pt_arena_result({_, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12}) -> 
	<<?WBYTE(V1), ?WINT32(V2), ?WINT32(V3), ?WSTRING(V4), ?WSTRING(V5), ?WINT32(V6), ?WINT32(V7), ?WINT32(V8), ?WINT32(V9), ?WLIST(V10, pt_public_item_list), ?WLIST(V11, pt_public_scene_damage_list), ?WLIST(V12, pt_public_scene_damage_list)>>.

pt_arena_reflush_cd({_, V1}) -> 
	<<?WINT32(V1)>>.

pt_arena_record_info({_, V1}) -> 
	<<?WLIST(V1, pt_public_arena_record)>>.

pt_challenger_reflush({_, V1}) -> 
	<<?WLIST(V1, pt_public_challenge_list)>>.

pt_arena_info({_, V1, V2, V3, V4, V5, V6}) -> 
	<<?WINT32(V1), ?WINT32(V2), ?WINT32(V3), ?WUINT32(V4), ?WUINT32(V5), ?WLIST(V6, pt_public_arena_record_list)>>.

pt_boss_lose({_, V1}) -> 
	<<?WINT32(V1)>>.

pt_boss_win({_, V1, V2, V3, V4}) -> 
	<<?WINT32(V1), ?WINT32(V2), ?WINT32(V3), ?WLIST(V4, pt_public_item_list)>>.

pt_boss_info({_, V1}) -> 
	<<?WLIST(V1, pt_public_boss_ex_info)>>.

pt_update_monster_prop({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WLIST(V2, pt_public_property_list)>>.

pt_req_quick_add_pet({_, V1}) -> 
	<<?WUINT32(V1)>>.

pt_guild_member_verify(_) -> 
	<<>>.

pt_chapter_info({_, V1, V2}) -> 
	<<?WINT32(V1), ?WINT32(V2)>>.

pt_seven_day_target_status({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_guild_notice({_, V1}) -> 
	<<?WSTRING(V1)>>.

pt_backpack_upgrade({_, V1, V2}) -> 
	<<?WINT32(V1), ?WINT32(V2)>>.

pt_crowd_num({_, V1}) -> 
	<<?WINT32(V1)>>.

pt_copy_exist_time({_, V1}) -> 
	<<?WINT32(V1)>>.

pt_update_scene_usr_data({_, V1, V2, V3, V4}) -> 
	<<?WUINT64(V1), ?WUINT32(V2), ?WSTRING(V3), ?WUINT32(V4)>>.

pt_req_continue_hc({_, V1}) -> 
	<<?WLIST(V1, pt_public_drop_des)>>.

pt_guild_name({_, V1}) -> 
	<<?WSTRING(V1)>>.

pt_item_model({_, V1}) -> 
	<<?WINT32(V1)>>.

pt_camp_activity({_, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WUINT32(V4), ?WUINT32(V5), ?WUINT32(V6), ?WUINT32(V7), ?WUINT32(V8), ?WUINT32(V9), ?WUINT32(V10)>>.

pt_military_prize(_) -> 
	<<>>.

pt_ret_hero_challenge({_, V1, V2, V3, V4, V5, V6}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WUINT32(V4), ?WBYTE(V5), ?WLIST(V6, pt_public_entourage)>>.

pt_camp_task({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3)>>.

pt_scene_fly_scene({_, V1}) -> 
	<<?WINT32(V1)>>.

pt_ret_risks_info({_, V1}) -> 
	<<?WLIST(V1, pt_public_trial_nums)>>.

pt_worship_response(_) -> 
	<<>>.

pt_can_worship({_, V1}) -> 
	<<?WINT32(V1)>>.

pt_task_rewards_succeed({_, V1}) -> 
	<<?WLIST(V1, pt_public_get_success_list)>>.

pt_wanted_task({_, V1, V2, V3, V4}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WUINT32(V4)>>.

pt_update_camp({_, V1, V2}) -> 
	<<?WUINT64(V1), ?WINT32(V2)>>.

pt_ret_trials_info({_, V1, V2}) -> 
	<<?WLIST(V1, pt_public_trial_nums), ?WLIST(V2, pt_public_int32x4)>>.

pt_join_camp({_, V1}) -> 
	<<?WUINT32(V1)>>.

pt_vote_succ(_) -> 
	<<>>.

pt_camp_vote_data({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WLIST(V2, pt_public_camp_vote_list)>>.

pt_archaeology_reward({_, V1}) -> 
	<<?WLIST(V1, pt_public_draw_item_list)>>.

pt_archaeology({_, V1, V2, V3, V4, V5}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WUINT32(V4), ?WUINT32(V5)>>.

pt_broadcast_ride_info({_, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10}) -> 
	<<?WUINT64(V1), ?WBYTE(V2), ?WUINT32(V3), ?WUINT32(V4), ?WUINT32(V5), ?WUINT32(V6), ?WUINT32(V7), ?WUINT32(V8), ?WUINT32(V9), ?WUINT32(V10)>>.

pt_item_info_return({_, V1}) -> 
	<<?WLIST(V1, pt_public_item_des)>>.

pt_draw_times({_, V1, V2, V3}) -> 
	<<?WBYTE(V1), ?WUINT32(V2), ?WLIST(V3, pt_public_draw_times)>>.

pt_draw({_, V1}) -> 
	<<?WLIST(V1, pt_public_draw_item_list)>>.

pt_submit_ready({_, V1}) -> 
	<<?WSTRING(V1)>>.

pt_match_succ({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WLIST(V3, pt_public_match_succ_list)>>.

pt_usr_info_entourage({_, V1}) -> 
	<<?WLIST(V1, pt_public_entourage_info_list)>>.

pt_usr_info_lost_item({_, V1}) -> 
	<<?WLIST(V1, pt_public_lost_item_info)>>.

pt_usr_info_property({_, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14, V15, V16, V17, V18, V19, V20, V21, V22, V23, V24, V25, V26, V27, V28, V29, V30, V31, V32, V33, V34, V35, V36}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WSTRING(V4), ?WUINT32(V5), ?WUINT32(V6), ?WUINT32(V7), ?WUINT32(V8), ?WUINT32(V9), ?WUINT32(V10), ?WUINT32(V11), ?WUINT32(V12), ?WUINT32(V13), ?WUINT32(V14), ?WUINT32(V15), ?WUINT32(V16), ?WUINT32(V17), ?WUINT32(V18), ?WUINT32(V19), ?WUINT32(V20), ?WUINT32(V21), ?WUINT32(V22), ?WUINT32(V23), ?WUINT32(V24), ?WUINT32(V25), ?WUINT32(V26), ?WUINT32(V27), ?WUINT32(V28), ?WUINT32(V29), ?WUINT32(V30), ?WUINT32(V31), ?WUINT32(V32), ?WUINT32(V33), ?WUINT32(V34), ?WUINT32(V35), ?WUINT32(V36)>>.

pt_usr_info_equi({_, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14}) -> 
	<<?WUINT64(V1), ?WSTRING(V2), ?WUINT32(V3), ?WUINT32(V4), ?WUINT32(V5), ?WUINT32(V6), ?WUINT32(V7), ?WUINT32(V8), ?WUINT32(V9), ?WUINT32(V10), ?WUINT32(V11), ?WUINT32(V12), ?WLIST(V13, pt_public_item_des), ?WLIST(V14, pt_public_other_gem_list)>>.

pt_start_match({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_match_ready_cancel(_) -> 
	<<>>.

pt_stop_match({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_req_match({_, V1}) -> 
	<<?WUINT32(V1)>>.

pt_rewards_return({_, V1, V2, V3}) -> 
	<<?WINT32(V1), ?WINT32(V2), ?WLIST(V3, pt_public_rewards_receive_list)>>.

pt_ret_skin_list({_, V1}) -> 
	<<?WLIST(V1, pt_public_r_skin)>>.

pt_receive_rewards_succeed({_, V1}) -> 
	<<?WLIST(V1, pt_public_get_success_list)>>.

pt_ret_ride_prop({_, V1}) -> 
	<<?WLIST(V1, pt_public_prop_entry)>>.

pt_ret_ride_info({_, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WBYTE(V3), ?WUINT32(V4), ?WBYTE(V5), ?WUINT32(V6), ?WUINT32(V7), ?WUINT32(V8), ?WUINT32(V9), ?WUINT32(V10), ?WUINT32(V11), ?WUINT32(V12), ?WUINT32(V13), ?WLIST(V14, pt_public_r_skin)>>.

pt_ranklist({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WLIST(V3, pt_public_ranklist)>>.

pt_ret_scene_teams({_, V1}) -> 
	<<?WLIST(V1, pt_public_team_info)>>.

pt_mdf_team_info({_, V1, V2, V3, V4}) -> 
	<<?WBYTE(V1), ?WBYTE(V2), ?WBYTE(V3), ?WBYTE(V4)>>.

pt_update_usr_discrib({_, V1, V2, V3, V4}) -> 
	<<?WUINT64(V1), ?WUINT16(V2), ?WUINT32(V3), ?WSTRING(V4)>>.

pt_break_timer(_) -> 
	<<>>.

pt_start_timer({_, V1}) -> 
	<<?WUINT32(V1)>>.

pt_use_someone_title({_, V1}) -> 
	<<?WUINT16(V1)>>.

pt_guild_copy_damage_ranking({_, V1, V2}) -> 
	<<?WINT32(V1), ?WLIST(V2, pt_public_guild_copy_damage_ranking)>>.

pt_guild_copy_enter({_, V1}) -> 
	<<?WLIST(V1, pt_public_guild_copy_enter_list)>>.

pt_guild_copy_trophy({_, V1}) -> 
	<<?WLIST(V1, pt_public_guild_copy_trophy_list)>>.

pt_guild_copy_list({_, V1, V2, V3}) -> 
	<<?WINT32(V1), ?WINT32(V2), ?WLIST(V3, pt_public_guild_copy_list)>>.

pt_monster_affiliation({_, V1}) -> 
	<<?WLIST(V1, pt_public_monster_affiliation)>>.

pt_guild_building_list({_, V1}) -> 
	<<?WLIST(V1, pt_public_guild_building_list)>>.

pt_donation_record_list({_, V1}) -> 
	<<?WLIST(V1, pt_public_donation_record_list)>>.

pt_copy_win({_, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11}) -> 
	<<?WINT32(V1), ?WINT32(V2), ?WINT32(V3), ?WINT32(V4), ?WINT32(V5), ?WINT32(V6), ?WINT32(V7), ?WINT32(V8), ?WLIST(V9, pt_public_item_list), ?WLIST(V10, pt_public_item_list), ?WLIST(V11, pt_public_common_rank)>>.

pt_invite_join_guild({_, V1, V2}) -> 
	<<?WSTRING(V1), ?WSTRING(V2)>>.

pt_update_mail({_, V1}) -> 
	<<?WLIST(V1, pt_public_update_mails)>>.

pt_read_mail_item({_, V1}) -> 
	<<?WLIST(V1, pt_public_id_list)>>.

pt_del_mail({_, V1}) -> 
	<<?WLIST(V1, pt_public_id_list)>>.

pt_mail_content({_, V1, V2, V3, V4}) -> 
	<<?WUINT32(V1), ?WSTRING(V2), ?WSTRING(V3), ?WLIST(V4, pt_public_item_list)>>.

pt_req_mail({_, V1}) -> 
	<<?WLIST(V1, pt_public_mail_list)>>.

pt_ret_titles({_, V1, V2}) -> 
	<<?WUINT16(V1), ?WLIST(V2, pt_public_title_obj)>>.

pt_acquire_new_title({_, V1, V2}) -> 
	<<?WUINT16(V1), ?WUINT32(V2)>>.

pt_scene_jump({_, V1, V2, V3, V4, V5}) -> 
	<<?WUINT64(V1), ?WFLOAT(V2), ?WFLOAT(V3), ?WFLOAT(V4), ?WFLOAT(V5)>>.

pt_req_jump(_) -> 
	<<>>.

pt_req_chat({_, V1, V2, V3}) -> 
	<<?WSTRING(V1), ?WUINT32(V2), ?WSTRING(V3)>>.

pt_chat({_, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14}) -> 
	<<?WUINT64(V1), ?WUINT64(V2), ?WSTRING(V3), ?WSTRING(V4), ?WUINT32(V5), ?WUINT32(V6), ?WLIST(V7, string), ?WUINT32(V8), ?WUINT32(V9), ?WUINT32(V10), ?WUINT32(V11), ?WSTRING(V12), ?WUINT64(V13), ?WUINT32(V14)>>.

pt_entourage_succeed({_, V1}) -> 
	<<?WLIST(V1, pt_public_get_success_list)>>.

pt_item_recoin_return({_, V1}) -> 
	<<?WLIST(V1, uint32)>>.

pt_item_recoin({_, V1, V2}) -> 
	<<?WINT32(V1), ?WLIST(V2, uint32)>>.

pt_guild_succeed({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WLIST(V2, pt_public_guild_operation_list)>>.

pt_members_entry({_, V1}) -> 
	<<?WLIST(V1, pt_public_guild_members_entry_list)>>.

pt_guild_commonality({_, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10}) -> 
	<<?WUINT64(V1), ?WBYTE(V2), ?WSTRING(V3), ?WINT32(V4), ?WINT32(V5), ?WINT32(V6), ?WINT32(V7), ?WINT32(V8), ?WUINT32(V9), ?WSTRING(V10)>>.

pt_guild_member_info({_, V1, V2}) -> 
	<<?WBYTE(V1), ?WLIST(V2, pt_public_guild_member_list)>>.

pt_all_guild_list_info({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WLIST(V2, pt_public_guild_info_list)>>.

pt_revive_times({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_get_success({_, V1}) -> 
	<<?WLIST(V1, pt_public_get_success_list)>>.

pt_copy_times({_, V1, V2}) -> 
	<<?WLIST(V1, pt_public_copy_times), ?WLIST(V2, uint32)>>.

pt_open_box_get_item({_, V1}) -> 
	<<?WLIST(V1, pt_public_item_list)>>.

pt_revive({_, V1, V2, V3, V4, V5}) -> 
	<<?WUINT64(V1), ?WUINT32(V2), ?WFLOAT(V3), ?WFLOAT(V4), ?WFLOAT(V5)>>.

pt_progress_bar_end({_, V1, V2, V3}) -> 
	<<?WUINT64(V1), ?WUINT32(V2), ?WUINT32(V3)>>.

pt_progress_bar_begin({_, V1, V2}) -> 
	<<?WUINT64(V1), ?WUINT32(V2)>>.

pt_activity_info({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WLIST(V2, pt_public_activity_info), ?WLIST(V3, uint32)>>.

pt_return_sign({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3)>>.

pt_req_item_recycle({_, V1}) -> 
	<<?WLIST(V1, pt_public_recycle_list)>>.

pt_say_notify({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_scene_item({_, V1}) -> 
	<<?WUINT32(V1)>>.

pt_return_gem_update({_, V1}) -> 
	<<?WLIST(V1, pt_public_gem_list)>>.

pt_req_gem_update({_, V1, V2, V3}) -> 
	<<?WINT32(V1), ?WINT32(V2), ?WINT32(V3)>>.

pt_store_buy({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3)>>.

pt_store_info({_, V1, V2}) -> 
	<<?WLIST(V1, pt_public_store_info), ?WLIST(V2, pt_public_usr_buy_cell_info)>>.

pt_pet({_, V1, V2, V3, V4}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WUINT32(V4)>>.

pt_mastery_update({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_mastery({_, V1}) -> 
	<<?WLIST(V1, pt_public_mastery_list)>>.

pt_reloading({_, V1, V2, V3}) -> 
	<<?WUINT64(V1), ?WUINT32(V2), ?WLIST(V3, pt_public_equip_id_state_list)>>.

pt_team_req_cancle({_, V1}) -> 
	<<?WUINT64(V1)>>.

pt_team_ask_cancle({_, V1}) -> 
	<<?WUINT64(V1)>>.

pt_team_destroy(_) -> 
	<<>>.

pt_team_member_leave({_, V1}) -> 
	<<?WUINT64(V1)>>.

pt_team_leader_chg({_, V1}) -> 
	<<?WUINT64(V1)>>.

pt_team_ans_req({_, V1, V2}) -> 
	<<?WUINT64(V1), ?WUINT32(V2)>>.

pt_team_req({_, V1, V2, V3}) -> 
	<<?WUINT64(V1), ?WSTRING(V2), ?WBYTE(V3)>>.

pt_team_ans_ask({_, V1, V2}) -> 
	<<?WUINT64(V1), ?WUINT32(V2)>>.

pt_team_ask({_, V1, V2}) -> 
	<<?WUINT64(V1), ?WSTRING(V2)>>.

pt_team_member_chg({_, V1}) -> 
	<<?WLIST(V1, pt_public_team_member_list)>>.

pt_team_info({_, V1, V2, V3, V4}) -> 
	<<?WUINT32(V1), ?WUINT64(V2), ?WUINT64(V3), ?WLIST(V4, pt_public_team_member_list)>>.

pt_entourage_create({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3)>>.

pt_update_base({_, V1, V2}) -> 
	<<?WUINT64(V1), ?WLIST(V2, pt_public_property)>>.

pt_action_two_int({_, V1, V2, V3}) -> 
	<<?WINT32(V1), ?WUINT64(V2), ?WUINT64(V3)>>.

pt_all_skill({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WLIST(V2, pt_public_normal_skill_list)>>.

pt_req_task_list(_) -> 
	<<>>.

pt_finish_task_response({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_del_task({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_finish_task({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_accept_task({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_entourage_info({_, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14, V15, V16}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WUINT32(V4), ?WUINT32(V5), ?WUINT32(V6), ?WUINT32(V7), ?WUINT32(V8), ?WUINT32(V9), ?WUINT32(V10), ?WUINT32(V11), ?WLIST(V12, pt_public_skill_list), ?WLIST(V13, pt_public_equip_list), ?WLIST(V14, pt_public_property_list), ?WLIST(V15, pt_public_entourage_rune_list), ?WLIST(V16, pt_public_entourage_fetter_info)>>.

pt_entourage_list({_, V1}) -> 
	<<?WLIST(V1, pt_public_entourage_list)>>.

pt_scene_transform({_, V1, V2, V3, V4, V5, V6, V7}) -> 
	<<?WUINT64(V1), ?WUINT32(V2), ?WUINT32(V3), ?WFLOAT(V4), ?WFLOAT(V5), ?WFLOAT(V6), ?WFLOAT(V7)>>.

pt_lost_item_active({_, V1}) -> 
	<<?WUINT32(V1)>>.

pt_lost_item_lev({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3)>>.

pt_lost_item_get({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3)>>.

pt_lost_item({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WLIST(V3, pt_public_lost_list)>>.

pt_item_chg({_, V1}) -> 
	<<?WLIST(V1, pt_public_item_des)>>.

pt_item_info({_, V1, V2, V3, V4}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WLIST(V4, pt_public_item_des)>>.

pt_scene_skill_aleret_cancel({_, V1, V2, V3, V4}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WUINT32(V4)>>.

pt_scene_skill_aleret({_, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14, V15, V16}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WUINT32(V4), ?WFLOAT(V5), ?WFLOAT(V6), ?WFLOAT(V7), ?WFLOAT(V8), ?WUINT32(V9), ?WFLOAT(V10), ?WFLOAT(V11), ?WFLOAT(V12), ?WFLOAT(V13), ?WFLOAT(V14), ?WFLOAT(V15), ?WFLOAT(V16)>>.

pt_scene_hide({_, V1}) -> 
	<<?WLIST(V1, pt_public_scene_objs)>>.

pt_scene_usr_team_chg({_, V1, V2, V3}) -> 
	<<?WUINT64(V1), ?WUINT32(V2), ?WUINT32(V3)>>.

pt_scene_delete_trap({_, V1}) -> 
	<<?WUINT32(V1)>>.

pt_scene_add_trap({_, V1}) -> 
	<<?WLIST(V1, pt_public_scene_trap)>>.

pt_scene_delete_arrow({_, V1}) -> 
	<<?WUINT32(V1)>>.

pt_scene_add_arrow({_, V1}) -> 
	<<?WLIST(V1, pt_public_scene_arrow)>>.

pt_scene_pickup({_, V1}) -> 
	<<?WLIST(V1, pt_public_pickup_des)>>.

pt_scene_drop({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WLIST(V2, pt_public_drop_des)>>.

pt_scene_break_persistent(_) -> 
	<<>>.

pt_scene_remove_buff({_, V1, V2, V3}) -> 
	<<?WUINT64(V1), ?WUINT32(V2), ?WUINT32(V3)>>.

pt_scene_chg_buff({_, V1, V2, V3, V4, V5, V6, V7, V8, V9}) -> 
	<<?WUINT64(V1), ?WUINT32(V2), ?WUINT32(V3), ?WUINT32(V4), ?WUINT32(V5), ?WUINT32(V6), ?WUINT32(V7), ?WUINT32(V8), ?WUINT32(V9)>>.

pt_scene_property({_, V1, V2}) -> 
	<<?WUINT64(V1), ?WLIST(V2, pt_public_property)>>.

pt_scene_skill_effect({_, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14, V15, V16, V17, V18}) -> 
	<<?WUINT32(V1), ?WUINT64(V2), ?WUINT32(V3), ?WUINT32(V4), ?WUINT32(V5), ?WUINT32(V6), ?WFLOAT(V7), ?WFLOAT(V8), ?WFLOAT(V9), ?WFLOAT(V10), ?WUINT64(V11), ?WFLOAT(V12), ?WFLOAT(V13), ?WFLOAT(V14), ?WFLOAT(V15), ?WFLOAT(V16), ?WFLOAT(V17), ?WLIST(V18, pt_public_skill_effect)>>.

pt_scene_skill({_, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT64(V3), ?WFLOAT(V4), ?WFLOAT(V5), ?WFLOAT(V6), ?WFLOAT(V7), ?WUINT64(V8), ?WFLOAT(V9), ?WFLOAT(V10), ?WFLOAT(V11)>>.

pt_scene_fly_by_fly_point({_, V1}) -> 
	<<?WINT32(V1)>>.

pt_scene_dec({_, V1}) -> 
	<<?WUINT64(V1)>>.

pt_scene_add({_, V1, V2, V3, V4, V5, V6, V7}) -> 
	<<?WLIST(V1, pt_public_scene_ply), ?WLIST(V2, pt_public_scene_monster), ?WLIST(V3, pt_public_scene_item), ?WLIST(V4, pt_public_scene_entourage), ?WLIST(V5, pt_public_usr_equip_list), ?WLIST(V6, pt_public_pet_list), ?WLIST(V7, pt_public_camp_model_list)>>.

pt_niubi({_, V1}) -> 
	<<?WUINT64(V1)>>.

pt_scene_move({_, V1, V2, V3, V4, V5}) -> 
	<<?WUINT64(V1), ?WUINT32(V2), ?WFLOAT(V3), ?WBYTE(V4), ?WLIST(V5, pt_public_point3)>>.

pt_medicine({_, V1}) -> 
	<<?WLIST(V1, pt_public_buff_list)>>.

pt_draw_base({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_relife_succeed({_, V1}) -> 
	<<?WUINT32(V1)>>.

pt_ggb_battle_waiting({_, V1}) -> 
	<<?WUINT32(V1)>>.

pt_ggb_battle_result({_, V1, V2, V3, V4, V5, V6, V7}) -> 
	<<?WBYTE(V1), ?WSTRING(V2), ?WSTRING(V3), ?WBYTE(V4), ?WSTRING(V5), ?WSTRING(V6), ?WBYTE(V7)>>.

pt_ggb_nofity({_, V1}) -> 
	<<?WBYTE(V1)>>.

pt_ggb_battle_log({_, V1, V2}) -> 
	<<?WBYTE(V1), ?WLIST(V2, pt_public_ggb_battle_record)>>.

pt_ggb_scene_report({_, V1, V2}) -> 
	<<?WBYTE(V1), ?WLIST(V2, string)>>.

pt_ggb_scene_brief_info({_, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12}) -> 
	<<?WSTRING(V1), ?WSTRING(V2), ?WBYTE(V3), ?WBYTE(V4), ?WBYTE(V5), ?WBYTE(V6), ?WSTRING(V7), ?WSTRING(V8), ?WBYTE(V9), ?WBYTE(V10), ?WBYTE(V11), ?WBYTE(V12)>>.

pt_ggb_group_info({_, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14, V15, V16, V17, V18, V19, V20, V21, V22, V23, V24, V25}) -> 
	<<?WBYTE(V1), ?WBYTE(V2), ?WBYTE(V3), ?WINT32(V4), ?WUINT64(V5), ?WSTRING(V6), ?WSTRING(V7), ?WUINT32(V8), ?WBYTE(V9), ?WBYTE(V10), ?WBYTE(V11), ?WBYTE(V12), ?WUINT16(V13), ?WUINT16(V14), ?WINT32(V15), ?WUINT64(V16), ?WSTRING(V17), ?WSTRING(V18), ?WUINT32(V19), ?WBYTE(V20), ?WBYTE(V21), ?WBYTE(V22), ?WBYTE(V23), ?WUINT16(V24), ?WUINT16(V25)>>.

pt_ggb_my_team_info({_, V1, V2, V3, V4, V5, V6, V7}) -> 
	<<?WBYTE(V1), ?WBYTE(V2), ?WBYTE(V3), ?WBYTE(V4), ?WBYTE(V5), ?WSTRING(V6), ?WSTRING(V7)>>.

pt_ggb_info({_, V1, V2, V3, V4, V5, V6}) -> 
	<<?WBYTE(V1), ?WBYTE(V2), ?WBYTE(V3), ?WBYTE(V4), ?WLIST(V5, pt_public_ggb_first_period_detail), ?WLIST(V6, pt_public_ggb_second_period_detail)>>.

pt_charge_card({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WINT32(V2)>>.

pt_last_called_hero({_, V1}) -> 
	<<?WLIST(V1, pt_public_combat_entourage_list)>>.

pt_net_chg_code({_, V1}) -> 
	<<?WUINT32(V1)>>.

pt_ping(_) -> 
	<<>>.

pt_action_list({_, V1, V2}) -> 
	<<?WINT32(V1), ?WLIST(V2, pt_public_id_list)>>.

pt_action_float({_, V1, V2}) -> 
	<<?WINT32(V1), ?WFLOAT(V2)>>.

pt_action_string({_, V1, V2}) -> 
	<<?WINT32(V1), ?WSTRING(V2)>>.

pt_action_int({_, V1, V2}) -> 
	<<?WINT32(V1), ?WUINT64(V2)>>.

pt_action({_, V1}) -> 
	<<?WINT32(V1)>>.

pt_delete_usr({_, V1}) -> 
	<<?WUINT64(V1)>>.

pt_req_delete_usr({_, V1}) -> 
	<<?WUINT64(V1)>>.

pt_create_usr_list({_, V1}) -> 
	<<?WLIST(V1, pt_public_create_usr_info)>>.

pt_req_create_usr({_, V1}) -> 
	<<?WSTRING(V1)>>.

pt_scene_info({_, V1, V2}) -> 
	<<?WUINT16(V1), ?WUINT32(V2)>>.

pt_load_scene_finish({_, V1}) -> 
	<<?WUINT32(V1)>>.

pt_req_load_scene({_, V1, V2, V3, V4, V5, V6}) -> 
	<<?WUINT32(V1), ?WFLOAT(V2), ?WFLOAT(V3), ?WFLOAT(V4), ?WFLOAT(V5), ?WFLOAT(V6)>>.

pt_usr_enter_scene(_) -> 
	<<>>.

pt_usr_info({_, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12}) -> 
	<<?WUINT64(V1), ?WSTRING(V2), ?WUINT32(V3), ?WUINT32(V4), ?WUINT32(V5), ?WUINT32(V6), ?WSTRING(V7), ?WLIST(V8, pt_public_resource_list), ?WUINT32(V9), ?WUINT32(V10), ?WUINT32(V11), ?WUINT32(V12)>>.

pt_usr_enter({_, V1, V2, V3}) -> 
	<<?WUINT64(V1), ?WBYTE(V2), ?WUINT32(V3)>>.

pt_net_info({_, V1, V2, V3, V4}) -> 
	<<?WSTRING(V1), ?WUINT32(V2), ?WUINT64(V3), ?WUINT32(V4)>>.

pt_queue_info({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_req_net({_, V1, V2}) -> 
	<<?WUINT64(V1), ?WUINT32(V2)>>.

pt_usr_list({_, V1, V2, V3, V4}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WLIST(V3, pt_public_create_usr_info), ?WUINT32(V4)>>.

pt_error_info({_, V1, V2}) -> 
	<<?WINT32(V1), ?WLIST(V2, pt_public_normal_info)>>.

pt_login_robot({_, V1, V2, V3, V4}) -> 
	<<?WSTRING(V1), ?WSTRING(V2), ?WUINT32(V3), ?WUINT32(V4)>>.

pt_login({_, V1, V2, V3}) -> 
	<<?WSTRING(V1), ?WSTRING(V2), ?WUINT32(V3)>>.

pt_grow_fund_info({_, V1, V2, V3, V4}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WUINT32(V4)>>.

pt_daily_acc_cost({_, V1, V2, V3, V4, V5}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WSTRING(V4), ?WLIST(V5, pt_public_daily_acc_cost_des)>>.

pt_daily_acc_recharge_info({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WLIST(V3, pt_public_daily_acc_recharge_des)>>.

pt_download_reward({_, V1, V2}) -> 
	<<?WUINT64(V1), ?WUINT32(V2)>>.

pt_relife_task_info({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WLIST(V2, pt_public_relife_task_info)>>.

pt_cast_shenqi_skill({_, V1, V2, V3, V4, V5}) -> 
	<<?WUINT32(V1), ?WUINT64(V2), ?WFLOAT(V3), ?WFLOAT(V4), ?WFLOAT(V5)>>.

pt_shenqi_skill_effect({_, V1, V2, V3, V4, V5, V6, V7, V8}) -> 
	<<?WUINT64(V1), ?WUINT32(V2), ?WUINT32(V3), ?WUINT64(V4), ?WFLOAT(V5), ?WFLOAT(V6), ?WFLOAT(V7), ?WLIST(V8, pt_public_skill_effect)>>.

