%% @doc 这个文件自动生成的，请不要修改
-module(proto_write_common).
-compile(export_all).
-include("proto_helper.hrl").


pt_public_task_list({_, V1, V2, V3}) -> 
	<<?WBYTE(V1), ?WUINT32(V2), ?WBYTE(V3)>>.

pt_public_pending_list({_, V1, V2, V3, V4}) -> 
	<<?WUINT64(V1), ?WSTRING(V2), ?WUINT32(V3), ?WUINT32(V4)>>.

pt_public_friend_list({_, V1, V2, V3, V4, V5, V6, V7, V8}) -> 
	<<?WUINT64(V1), ?WSTRING(V2), ?WSTRING(V3), ?WUINT32(V4), ?WUINT32(V5), ?WUINT32(V6), ?WUINT32(V7), ?WUINT32(V8)>>.

pt_public_left_hp({_, V1, V2}) -> 
	<<?WUINT64(V1), ?WUINT32(V2)>>.

pt_public_on_battle_data({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WLIST(V3, pt_public_on_battle_heros)>>.

pt_public_draw_record_list({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WLIST(V2, pt_public_item_list)>>.

pt_public_turntable_list({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WINT32(V2), ?WLIST(V3, pt_public_item_list)>>.

pt_public_draw_list({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_public_expedition_sub_event({_, V1, V2}) -> 
	<<?WBYTE(V1), ?WBYTE(V2)>>.

pt_public_expedition_pos({_, V1, V2, V3}) -> 
	<<?WBYTE(V1), ?WBYTE(V2), ?WBYTE(V3)>>.

pt_public_act_copy({_, V1, V2, V3, V4, V5, V6}) -> 
	<<?WBYTE(V1), ?WUINT32(V2), ?WUINT32(V3), ?WBYTE(V4), ?WBYTE(V5), ?WUINT32(V6)>>.

pt_public_arena_record_list({_, V1, V2, V3, V4, V5, V6}) -> 
	<<?WUINT64(V1), ?WSTRING(V2), ?WUINT32(V3), ?WUINT32(V4), ?WUINT32(V5), ?WUINT32(V6)>>.

pt_public_illustration_info({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_public_on_battle_heros({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WBYTE(V3)>>.

pt_public_act_turntable_point_reward_list({_, V1, V2, V3, V4, V5}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WLIST(V3, pt_public_item_list), ?WSTRING(V4), ?WUINT32(V5)>>.

pt_public_act_turntable_reward_list({_, V1, V2, V3, V4}) -> 
	<<?WUINT32(V1), ?WLIST(V2, pt_public_item_list), ?WUINT32(V3), ?WUINT32(V4)>>.

pt_public_act_turntable_des({_, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10}) -> 
	<<?WLIST(V1, pt_public_act_turntable_reward_list), ?WLIST(V2, pt_public_item_list), ?WLIST(V3, pt_public_item_list), ?WLIST(V4, pt_public_item_list), ?WSTRING(V5), ?WUINT32(V6), ?WUINT32(V7), ?WUINT32(V8), ?WUINT32(V9), ?WLIST(V10, pt_public_act_turntable_point_reward_list)>>.

pt_public_act_rmb_package_des({_, V1, V2, V3, V4, V5}) -> 
	<<?WUINT32(V1), ?WLIST(V2, pt_public_item_list), ?WLIST(V3, pt_public_item_list), ?WUINT32(V4), ?WUINT32(V5)>>.

pt_public_act_diamond_package_des({_, V1, V2, V3, V4, V5, V6, V7}) -> 
	<<?WUINT32(V1), ?WSTRING(V2), ?WSTRING(V3), ?WLIST(V4, pt_public_item_list), ?WLIST(V5, pt_public_item_list), ?WUINT32(V6), ?WUINT32(V7)>>.

pt_public_act_point_package_box_des({_, V1, V2, V3, V4, V5, V6, V7, V8, V9}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WUINT32(V4), ?WUINT32(V5), ?WSTRING(V6), ?WSTRING(V7), ?WLIST(V8, pt_public_item_list), ?WLIST(V9, pt_public_item_list)>>.

pt_public_act_point_package_des({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WSTRING(V2), ?WLIST(V3, pt_public_act_point_package_box_des)>>.

pt_public_activity_list({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WSTRING(V2), ?WSTRING(V3)>>.

pt_public_scene_damage_list({_, V1, V2, V3, V4}) -> 
	<<?WUINT64(V1), ?WBYTE(V2), ?WBYTE(V3), ?WUINT32(V4)>>.

pt_public_acc_login_des({_, V1, V2, V3, V4}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WLIST(V4, pt_public_item_list)>>.

pt_public_single_recharge_des({_, V1, V2, V3, V4, V5, V6, V7}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WLIST(V3, pt_public_item_list), ?WUINT32(V4), ?WUINT32(V5), ?WUINT32(V6), ?WUINT32(V7)>>.

pt_public_arena_store_info_list({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_public_legendary_exp_buy_list({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_public_entourage_challenge_info({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3)>>.

pt_public_legendary_level_info_list({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_public_return_investment_reward_list({_, V1, V2, V3, V4}) -> 
	<<?WUINT32(V1), ?WSTRING(V2), ?WUINT32(V3), ?WLIST(V4, pt_public_item_list)>>.

pt_public_mystery_gift_info_des({_, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WSTRING(V3), ?WSTRING(V4), ?WUINT32(V5), ?WUINT32(V6), ?WUINT32(V7), ?WSTRING(V8), ?WSTRING(V9), ?WLIST(V10, pt_public_item_list)>>.

pt_public_return_investment_des({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WLIST(V3, pt_public_return_investment_reward_list)>>.

pt_public_head_list({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_public_melleboss_list({_, V1, V2, V3, V4}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WUINT32(V4)>>.

pt_public_maze_ranklist({_, V1, V2, V3}) -> 
	<<?WSTRING(V1), ?WUINT32(V2), ?WUINT32(V3)>>.

pt_public_carousel_item_list({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3)>>.

pt_public_point_reward_list_des({_, V1, V2, V3, V4}) -> 
	<<?WUINT32(V1), ?WSTRING(V2), ?WUINT32(V3), ?WLIST(V4, pt_public_item_list)>>.

pt_public_point_ranklist_des({_, V1, V2, V3, V4, V5, V6}) -> 
	<<?WUINT64(V1), ?WSTRING(V2), ?WUINT32(V3), ?WSTRING(V4), ?WUINT32(V5), ?WLIST(V6, pt_public_item_list)>>.

pt_public_act_lottery_carousel_des({_, V1, V2, V3, V4, V5, V6, V7, V8}) -> 
	<<?WLIST(V1, pt_public_carousel_item_list), ?WUINT32(V2), ?WUINT32(V3), ?WUINT32(V4), ?WUINT32(V5), ?WUINT32(V6), ?WLIST(V7, pt_public_point_ranklist_des), ?WLIST(V8, pt_public_point_reward_list_des)>>.

pt_public_act_literature_collection_des({_, V1, V2, V3, V4, V5}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WLIST(V4, pt_public_item_list), ?WLIST(V5, pt_public_item_list)>>.

pt_public_global_guild_ranklist({_, V1, V2, V3, V4, V5, V6}) -> 
	<<?WUINT32(V1), ?WSTRING(V2), ?WUINT32(V3), ?WSTRING(V4), ?WUINT32(V5), ?WUINT32(V6)>>.

pt_public_mining_list_des({_, V1, V2, V3, V4, V5, V6}) -> 
	<<?WUINT64(V1), ?WSTRING(V2), ?WUINT32(V3), ?WBYTE(V4), ?WUINT32(V5), ?WUINT32(V6)>>.

pt_public_mining_defend_des({_, V1, V2, V3, V4}) -> 
	<<?WBYTE(V1), ?WSTRING(V2), ?WUINT32(V3), ?WUINT32(V4)>>.

pt_public_guard_list({_, V1, V2, V3, V4, V5}) -> 
	<<?WUINT32(V1), ?WUINT64(V2), ?WSTRING(V3), ?WUINT32(V4), ?WUINT32(V5)>>.

pt_public_plunder_list({_, V1, V2, V3, V4, V5, V6, V7, V8, V9}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT64(V3), ?WSTRING(V4), ?WSTRING(V5), ?WUINT32(V6), ?WSTRING(V7), ?WUINT32(V8), ?WUINT32(V9)>>.

pt_public_sailing_record({_, V1, V2, V3, V4, V5}) -> 
	<<?WUINT32(V1), ?WSTRING(V2), ?WSTRING(V3), ?WSTRING(V4), ?WUINT32(V5)>>.

pt_public_maze_record({_, V1, V2, V3, V4, V5, V6, V7, V8}) -> 
	<<?WUINT64(V1), ?WSTRING(V2), ?WUINT32(V3), ?WSTRING(V4), ?WUINT32(V5), ?WUINT32(V6), ?WUINT32(V7), ?WLIST(V8, pt_public_item_list)>>.

pt_public_act_recharge_total_des({_, V1, V2, V3, V4, V5, V6}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WSTRING(V4), ?WLIST(V5, pt_public_item_list), ?WUINT32(V6)>>.

pt_public_act_recharge_own_des({_, V1, V2, V3, V4, V5, V6}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WSTRING(V4), ?WLIST(V5, pt_public_item_list), ?WUINT32(V6)>>.

pt_public_act_recharge_ranklist_des({_, V1, V2, V3, V4, V5, V6, V7}) -> 
	<<?WUINT64(V1), ?WUINT32(V2), ?WUINT32(V3), ?WUINT32(V4), ?WSTRING(V5), ?WLIST(V6, pt_public_item_list), ?WUINT32(V7)>>.

pt_public_act_recharge_point_des({_, V1, V2, V3, V4, V5, V6}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WLIST(V4, pt_public_act_recharge_ranklist_des), ?WLIST(V5, pt_public_act_recharge_own_des), ?WLIST(V6, pt_public_act_recharge_total_des)>>.

pt_public_global_arena_last_ranklist_info({_, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13}) -> 
	<<?WUINT64(V1), ?WSTRING(V2), ?WUINT32(V3), ?WUINT32(V4), ?WUINT32(V5), ?WUINT32(V6), ?WUINT32(V7), ?WUINT32(V8), ?WUINT32(V9), ?WUINT32(V10), ?WUINT32(V11), ?WUINT32(V12), ?WSTRING(V13)>>.

pt_public_global_arena_ranklist_info({_, V1, V2, V3, V4, V5, V6, V7, V8, V9}) -> 
	<<?WSTRING(V1), ?WUINT32(V2), ?WUINT32(V3), ?WUINT32(V4), ?WUINT32(V5), ?WUINT32(V6), ?WUINT32(V7), ?WUINT32(V8), ?WSTRING(V9)>>.

pt_public_global_arena_daily_log({_, V1, V2, V3, V4, V5}) -> 
	<<?WSTRING(V1), ?WUINT32(V2), ?WUINT32(V3), ?WUINT32(V4), ?WUINT32(V5)>>.

pt_public_global_arena_daily_task({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_public_guild_operation_list({_, V1, V2, V3, V4}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WSTRING(V3), ?WSTRING(V4)>>.

pt_public_title_chpprof({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3)>>.

pt_public_jifen_shop({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3)>>.

pt_public_global_rewards_info({_, V1, V2}) -> 
	<<?WSTRING(V1), ?WLIST(V2, pt_public_item_list)>>.

pt_public_recharge_global_rank_list({_, V1, V2, V3, V4}) -> 
	<<?WUINT32(V1), ?WSTRING(V2), ?WSTRING(V3), ?WUINT32(V4)>>.

pt_public_consume_global_rank_list({_, V1, V2, V3, V4}) -> 
	<<?WUINT32(V1), ?WSTRING(V2), ?WSTRING(V3), ?WUINT32(V4)>>.

pt_public_talent_skill_des({_, V1, V2}) -> 
	<<?WBYTE(V1), ?WUINT32(V2)>>.

pt_public_guild_ranklist({_, V1, V2, V3, V4}) -> 
	<<?WUINT64(V1), ?WSTRING(V2), ?WUINT32(V3), ?WUINT32(V4)>>.

pt_public_ggb_team_pos_info({_, V1, V2, V3, V4, V5, V6, V7}) -> 
	<<?WBYTE(V1), ?WBYTE(V2), ?WUINT32(V3), ?WUINT32(V4), ?WBYTE(V5), ?WSTRING(V6), ?WSTRING(V7)>>.

pt_public_ggb_battle_record({_, V1, V2, V3, V4, V5, V6, V7, V8, V9}) -> 
	<<?WBYTE(V1), ?WBYTE(V2), ?WBYTE(V3), ?WSTRING(V4), ?WSTRING(V5), ?WUINT32(V6), ?WSTRING(V7), ?WSTRING(V8), ?WUINT32(V9)>>.

pt_public_ggb_second_period_detail({_, V1, V2}) -> 
	<<?WBYTE(V1), ?WLIST(V2, pt_public_ggb_team_pos_info)>>.

pt_public_ggb_first_period_detail({_, V1, V2, V3}) -> 
	<<?WBYTE(V1), ?WBYTE(V2), ?WLIST(V3, pt_public_ggb_battle_record)>>.

pt_public_usrid_list({_, V1}) -> 
	<<?WUINT32(V1)>>.

pt_public_limit_achievement_ranking_des({_, V1, V2, V3, V4, V5, V6}) -> 
	<<?WUINT32(V1), ?WUINT64(V2), ?WUINT32(V3), ?WUINT32(V4), ?WSTRING(V5), ?WUINT32(V6)>>.

pt_public_limit_achievement_total_des({_, V1, V2, V3, V4, V5, V6}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WSTRING(V4), ?WLIST(V5, pt_public_item_list), ?WUINT32(V6)>>.

pt_public_limit_achievement_own_des({_, V1, V2, V3, V4, V5, V6}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WSTRING(V4), ?WLIST(V5, pt_public_item_list), ?WUINT32(V6)>>.

pt_public_limit_achievement_day_des({_, V1, V2, V3, V4, V5, V6}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WSTRING(V4), ?WLIST(V5, pt_public_item_list), ?WUINT32(V6)>>.

pt_public_limit_achievement_des({_, V1, V2, V3, V4, V5, V6, V7}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WLIST(V4, pt_public_limit_achievement_day_des), ?WLIST(V5, pt_public_limit_achievement_own_des), ?WLIST(V6, pt_public_limit_achievement_total_des), ?WLIST(V7, pt_public_limit_achievement_ranking_des)>>.

pt_public_continuous_recharge_reward_des({_, V1, V2, V3, V4, V5}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WLIST(V3, pt_public_item_list), ?WSTRING(V4), ?WUINT32(V5)>>.

pt_public_continuous_recharge_des({_, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10}) -> 
	<<?WUINT32(V1), ?WSTRING(V2), ?WLIST(V3, pt_public_item_list), ?WUINT32(V4), ?WUINT32(V5), ?WUINT32(V6), ?WSTRING(V7), ?WLIST(V8, pt_public_item_list), ?WUINT32(V9), ?WLIST(V10, pt_public_continuous_recharge_reward_des)>>.

pt_public_entourage_rune_list({_, V1, V2, V3, V4}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WLIST(V4, pt_public_property_list)>>.

pt_public_dead_entourage_list({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_public_combat_entourage_list({_, V1}) -> 
	<<?WUINT32(V1)>>.

pt_public_limit_summon_rank_reward_des({_, V1, V2, V3, V4, V5}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WLIST(V4, pt_public_item_list), ?WSTRING(V5)>>.

pt_public_limit_summon_ranking_des({_, V1, V2, V3, V4, V5, V6}) -> 
	<<?WUINT32(V1), ?WUINT64(V2), ?WUINT32(V3), ?WUINT32(V4), ?WSTRING(V5), ?WUINT32(V6)>>.

pt_public_system_activity_info({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_public_gm_act_reset_recharge_des({_, V1, V2}) -> 
	<<?WSTRING(V1), ?WSTRING(V2)>>.

pt_public_institue_skill_list({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3)>>.

pt_public_help_work_list({_, V1, V2, V3, V4, V5, V6, V7, V8}) -> 
	<<?WUINT32(V1), ?WUINT64(V2), ?WSTRING(V3), ?WUINT32(V4), ?WUINT32(V5), ?WUINT32(V6), ?WUINT32(V7), ?WUINT32(V8)>>.

pt_public_friend_name_list({_, V1}) -> 
	<<?WSTRING(V1)>>.

pt_public_buff_list({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_public_treasure_record_des({_, V1, V2}) -> 
	<<?WSTRING(V1), ?WUINT32(V2)>>.

pt_public_treasure_exchange_des({_, V1, V2, V3, V4, V5}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WUINT32(V4), ?WUINT32(V5)>>.

pt_public_treasure_ranking_des({_, V1, V2, V3, V4, V5, V6}) -> 
	<<?WUINT32(V1), ?WUINT64(V2), ?WUINT32(V3), ?WUINT32(V4), ?WSTRING(V5), ?WUINT32(V6)>>.

pt_public_treasure_rank_reward_des({_, V1, V2, V3, V4, V5}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WLIST(V4, pt_public_item_list), ?WSTRING(V5)>>.

pt_public_home_building_worker_info({_, V1, V2, V3, V4, V5, V6}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WSTRING(V3), ?WUINT32(V4), ?WUINT32(V5), ?WFLOAT(V6)>>.

pt_public_home_building_base_info({_, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14, V15, V16}) -> 
	<<?WUINT32(V1), ?WBYTE(V2), ?WUINT32(V3), ?WUINT32(V4), ?WUINT32(V5), ?WUINT32(V6), ?WUINT32(V7), ?WLIST(V8, pt_public_friend_name_list), ?WLIST(V9, pt_public_item_list), ?WUINT32(V10), ?WUINT32(V11), ?WUINT32(V12), ?WUINT32(V13), ?WLIST(V14, pt_public_help_work_list), ?WLIST(V15, pt_public_help_work_list), ?WLIST(V16, pt_public_institue_skill_list)>>.

pt_public_worldboss_damage_info({_, V1, V2, V3, V4, V5}) -> 
	<<?WUINT32(V1), ?WUINT64(V2), ?WSTRING(V3), ?WUINT32(V4), ?WUINT32(V5)>>.

pt_public_worldboss_info({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3)>>.

pt_public_recent_chat_msg({_, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13}) -> 
	<<?WUINT64(V1), ?WUINT64(V2), ?WSTRING(V3), ?WSTRING(V4), ?WUINT32(V5), ?WUINT32(V6), ?WLIST(V7, string), ?WUINT32(V8), ?WUINT32(V9), ?WUINT32(V10), ?WUINT32(V11), ?WUINT64(V12), ?WSTRING(V13)>>.

pt_public_lv_rank_reward_des({_, V1, V2, V3, V4}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WLIST(V3, pt_public_item_list), ?WSTRING(V4)>>.

pt_public_gm_act_lv_rank_des({_, V1, V2, V3, V4, V5, V6}) -> 
	<<?WUINT32(V1), ?WUINT64(V2), ?WUINT32(V3), ?WUINT32(V4), ?WSTRING(V5), ?WUINT32(V6)>>.

pt_public_gm_act_package_des({_, V1, V2, V3, V4, V5, V6, V7, V8}) -> 
	<<?WUINT32(V1), ?WSTRING(V2), ?WSTRING(V3), ?WLIST(V4, pt_public_item_list), ?WUINT32(V5), ?WUINT32(V6), ?WUINT32(V7), ?WSTRING(V8)>>.

pt_public_gm_act_double_des({_, V1, V2, V3, V4, V5}) -> 
	<<?WUINT32(V1), ?WSTRING(V2), ?WSTRING(V3), ?WUINT32(V4), ?WLIST(V5, pt_public_item_list)>>.

pt_public_gm_act_discount_des({_, V1, V2, V3, V4}) -> 
	<<?WUINT32(V1), ?WSTRING(V2), ?WSTRING(V3), ?WUINT32(V4)>>.

pt_public_gm_act_sale_des({_, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WSTRING(V4), ?WLIST(V5, pt_public_item_list), ?WUINT32(V6), ?WUINT32(V7), ?WUINT32(V8), ?WUINT32(V9), ?WUINT32(V10), ?WUINT32(V11)>>.

pt_public_gm_act_exchange_des({_, V1, V2, V3, V4, V5, V6, V7}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WSTRING(V3), ?WUINT32(V4), ?WUINT32(V5), ?WLIST(V6, pt_public_item_list), ?WLIST(V7, pt_public_item_list)>>.

pt_public_daily_acc_cost_des({_, V1, V2, V3, V4}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WLIST(V4, pt_public_item_list)>>.

pt_public_acc_cost_des({_, V1, V2, V3, V4}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WLIST(V4, pt_public_item_list)>>.

pt_public_barrier_rewards_des({_, V1, V2, V3, V4}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WUINT32(V4)>>.

pt_public_gm_act_week_task_des({_, V1, V2, V3, V4, V5, V6, V7}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WSTRING(V3), ?WUINT32(V4), ?WLIST(V5, uint32), ?WUINT32(V6), ?WLIST(V7, pt_public_item_list)>>.

pt_public_daily_acc_recharge_des({_, V1, V2, V3, V4, V5, V6, V7}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WUINT32(V4), ?WSTRING(V5), ?WSTRING(V6), ?WLIST(V7, pt_public_item_list)>>.

pt_public_acc_recharge_des({_, V1, V2, V3, V4, V5, V6, V7}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WUINT32(V4), ?WSTRING(V5), ?WSTRING(V6), ?WLIST(V7, pt_public_item_list)>>.

pt_public_guild_stone_list({_, V1, V2, V3, V4}) -> 
	<<?WUINT64(V1), ?WSTRING(V2), ?WUINT32(V3), ?WUINT32(V4)>>.

pt_public_time_reward({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_public_flash_gift_bag_list({_, V1, V2, V3, V4, V5}) -> 
	<<?WUINT32(V1), ?WLIST(V2, pt_public_item_list), ?WUINT32(V3), ?WUINT32(V4), ?WUINT32(V5)>>.

pt_public_reward_info({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_public_boss_ex_info({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3)>>.

pt_public_mystery_store_item_list({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_public_military_skill_info({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_public_turning_wheel_config_list({_, V1, V2, V3, V4}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WINT32(V3), ?WFLOAT(V4)>>.

pt_public_diamond_lev_list({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WLIST(V3, pt_public_stat_item_list)>>.

pt_public_stat_item_list({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3)>>.

pt_public_recharge_rank_list({_, V1, V2, V3, V4, V5}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WSTRING(V3), ?WUINT32(V4), ?WLIST(V5, pt_public_treasure_rewards_info)>>.

pt_public_consume_rank_list({_, V1, V2, V3, V4, V5}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WSTRING(V3), ?WUINT32(V4), ?WLIST(V5, pt_public_treasure_rewards_info)>>.

pt_public_extreme_ranklist({_, V1, V2, V3, V4}) -> 
	<<?WUINT32(V1), ?WSTRING(V2), ?WUINT32(V3), ?WUINT32(V4)>>.

pt_public_extreme_luxury_gift_info({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WLIST(V3, pt_public_treasure_rewards_info)>>.

pt_public_treasure_rewards_info({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_public_all_people_info({_, V1, V2, V3, V4}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WLIST(V4, pt_public_treasure_rewards_info)>>.

pt_public_other_usr_skill({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_public_entourage_mastery_list({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_public_entourage_mastery_info({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WLIST(V2, pt_public_entourage_mastery_list)>>.

pt_public_pwd_red_list({_, V1, V2, V3, V4, V5}) -> 
	<<?WUINT64(V1), ?WSTRING(V2), ?WUINT32(V3), ?WSTRING(V4), ?WUINT32(V5)>>.

pt_public_guild_team_list({_, V1, V2, V3, V4, V5, V6, V7, V8}) -> 
	<<?WUINT64(V1), ?WUINT32(V2), ?WSTRING(V3), ?WUINT32(V4), ?WUINT32(V5), ?WUINT32(V6), ?WUINT32(V7), ?WUINT32(V8)>>.

pt_public_guild_team_copy_list({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_public_climb_tower_first_reward({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_public_inscription_list({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_public_exped_entourage_list({_, V1, V2}) -> 
	<<?WUINT64(V1), ?WUINT32(V2)>>.

pt_public_rent_entourage_list({_, V1, V2, V3, V4, V5}) -> 
	<<?WUINT64(V1), ?WUINT32(V2), ?WUINT32(V3), ?WUINT32(V4), ?WUINT32(V5)>>.

pt_public_expedition_list({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3)>>.

pt_public_strength_oven_list({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3)>>.

pt_public_seven_day_target_rewards_list({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3)>>.

pt_public_seven_day_target_info_list({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3)>>.

pt_public_five_act_info({_, V1, V2, V3}) -> 
	<<?WSTRING(V1), ?WUINT32(V2), ?WSTRING(V3)>>.

pt_public_war_info_list({_, V1, V2, V3, V4}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WUINT32(V4)>>.

pt_public_blacklist_list({_, V1, V2, V3, V4, V5, V6}) -> 
	<<?WUINT64(V1), ?WUINT32(V2), ?WUINT32(V3), ?WSTRING(V4), ?WUINT32(V5), ?WUINT32(V6)>>.

pt_public_growth_bible_info({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_public_other_gem_list({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_public_other_pet_list({_, V1}) -> 
	<<?WUINT32(V1)>>.

pt_public_pet_property_list({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_public_mount_equip_list({_, V1}) -> 
	<<?WUINT32(V1)>>.

pt_public_atlas_team_list({_, V1, V2, V3, V4, V5, V6}) -> 
	<<?WUINT64(V1), ?WSTRING(V2), ?WUINT32(V3), ?WUINT32(V4), ?WUINT32(V5), ?WUINT32(V6)>>.

pt_public_war_damage({_, V1, V2, V3}) -> 
	<<?WINT32(V1), ?WSTRING(V2), ?WINT32(V3)>>.

pt_public_illusion_list({_, V1}) -> 
	<<?WUINT32(V1)>>.

pt_public_gamble_record({_, V1, V2, V3}) -> 
	<<?WSTRING(V1), ?WINT32(V2), ?WINT32(V3)>>.

pt_public_deputy_list({_, V1, V2, V3, V4, V5, V6}) -> 
	<<?WUINT64(V1), ?WSTRING(V2), ?WINT32(V3), ?WINT32(V4), ?WINT32(V5), ?WINT32(V6)>>.

pt_public_loginact_des({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WLIST(V3, pt_public_item_list)>>.

pt_public_exchange_des({_, V1, V2, V3, V4, V5}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WLIST(V4, pt_public_item_list), ?WLIST(V5, pt_public_item_list)>>.

pt_public_gift_des({_, V1, V2, V3, V4}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WLIST(V4, pt_public_item_list)>>.

pt_public_repeat_des({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WLIST(V2, pt_public_item_list)>>.

pt_public_single_des({_, V1, V2, V3, V4, V5, V6}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WUINT32(V4), ?WUINT32(V5), ?WLIST(V6, pt_public_item_list)>>.

pt_public_week_rewards_list({_, V1}) -> 
	<<?WUINT32(V1)>>.

pt_public_equip_rewards_list({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_public_entourage_star_rewards({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_public_royal_box_list({_, V1, V2, V3, V4}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WUINT32(V4)>>.

pt_public_national_war_record({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3)>>.

pt_public_present_entourage_scrolls({_, V1, V2, V3, V4}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WUINT32(V4)>>.

pt_public_task_rewards_list({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_public_move_sand_list({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3)>>.

pt_public_retrueve_info({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_public_abddart_activity_list({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3)>>.

pt_public_use_item_groupId({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_public_activity_id_list({_, V1}) -> 
	<<?WUINT32(V1)>>.

pt_public_recharge_list({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_public_entourage_soul_link({_, V1, V2, V3, V4}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WUINT32(V4)>>.

pt_public_entourage_fetter_info({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_public_charge_active({_, V1, V2, V3, V4}) -> 
	<<?WBYTE(V1), ?WBYTE(V2), ?WINT32(V3), ?WINT32(V4)>>.

pt_public_vip_rewards_list({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_public_unlock_atlas_list({_, V1}) -> 
	<<?WUINT32(V1)>>.

pt_public_paragon_level({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_public_item_model_clothes({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT16(V3)>>.

pt_public_achieve({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3)>>.

pt_public_scene_branching_info({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_public_int32x4({_, V1, V2, V3, V4}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WUINT32(V4)>>.

pt_public_arena_record({_, V1, V2, V3, V4}) -> 
	<<?WSTRING(V1), ?WUINT32(V2), ?WUINT32(V3), ?WUINT32(V4)>>.

pt_public_challenge_list({_, V1, V2, V3}) -> 
	<<?WUINT64(V1), ?WUINT32(V2), ?WSTRING(V3)>>.

pt_public_boss_info({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_public_resource_list({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_public_entourage({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_public_camp_model_list({_, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11}) -> 
	<<?WUINT64(V1), ?WSTRING(V2), ?WUINT32(V3), ?WFLOAT(V4), ?WFLOAT(V5), ?WFLOAT(V6), ?WFLOAT(V7), ?WUINT32(V8), ?WUINT32(V9), ?WUINT32(V10), ?WLIST(V11, pt_public_id_list)>>.

pt_public_trial_nums({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WBYTE(V2)>>.

pt_public_camp_vote_list({_, V1, V2, V3, V4, V5, V6}) -> 
	<<?WUINT32(V1), ?WUINT64(V2), ?WUINT32(V3), ?WSTRING(V4), ?WUINT32(V5), ?WUINT32(V6)>>.

pt_public_draw_item_list({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3)>>.

pt_public_draw_times({_, V1, V2, V3, V4, V5}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WUINT32(V4), ?WUINT32(V5)>>.

pt_public_lost_item_info({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3)>>.

pt_public_entourage_info_list({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3)>>.

pt_public_match_succ_list({_, V1, V2, V3}) -> 
	<<?WSTRING(V1), ?WUINT32(V2), ?WUINT32(V3)>>.

pt_public_rewards_receive_list({_, V1}) -> 
	<<?WUINT32(V1)>>.

pt_public_prop_entry({_, V1, V2}) -> 
	<<?WUINT16(V1), ?WUINT32(V2)>>.

pt_public_r_skin({_, V1, V2, V3, V4, V5, V6, V7, V8, V9}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WUINT32(V4), ?WUINT32(V5), ?WUINT32(V6), ?WUINT32(V7), ?WUINT32(V8), ?WUINT32(V9)>>.

pt_public_ranklist({_, V1, V2, V3, V4, V5, V6, V7, V8}) -> 
	<<?WUINT64(V1), ?WUINT32(V2), ?WSTRING(V3), ?WUINT32(V4), ?WUINT32(V5), ?WUINT32(V6), ?WSTRING(V7), ?WUINT32(V8)>>.

pt_public_team_info({_, V1, V2, V3, V4, V5, V6}) -> 
	<<?WUINT32(V1), ?WBYTE(V2), ?WUINT64(V3), ?WBYTE(V4), ?WUINT32(V5), ?WLIST(V6, pt_public_member_info)>>.

pt_public_member_info({_, V1, V2, V3}) -> 
	<<?WUINT64(V1), ?WBYTE(V2), ?WSTRING(V3)>>.

pt_public_scene_objs({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT64(V2)>>.

pt_public_guild_trophy_list({_, V1, V2, V3, V4}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WUINT32(V4)>>.

pt_public_guild_copy_damage_ranking({_, V1, V2, V3, V4, V5, V6, V7, V8}) -> 
	<<?WUINT32(V1), ?WUINT64(V2), ?WSTRING(V3), ?WUINT32(V4), ?WUINT32(V5), ?WUINT32(V6), ?WUINT32(V7), ?WUINT32(V8)>>.

pt_public_guild_copy_enter_list({_, V1, V2, V3, V4}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WSTRING(V3), ?WUINT32(V4)>>.

pt_public_guild_copy_trophy_list({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WLIST(V2, pt_public_guild_trophy_list)>>.

pt_public_guild_copy_list({_, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WUINT32(V4), ?WUINT32(V5), ?WUINT32(V6), ?WUINT32(V7), ?WSTRING(V8), ?WSTRING(V9), ?WUINT32(V10), ?WLIST(V11, pt_public_guild_ranklist)>>.

pt_public_monster_affiliation({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT64(V2)>>.

pt_public_update_mails({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WLIST(V2, pt_public_item_list)>>.

pt_public_donation_record_list({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WSTRING(V2), ?WUINT32(V3)>>.

pt_public_guild_building_list({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3)>>.

pt_public_id_list({_, V1}) -> 
	<<?WUINT32(V1)>>.

pt_public_title_obj({_, V1, V2}) -> 
	<<?WUINT16(V1), ?WUINT32(V2)>>.

pt_public_mail_list({_, V1, V2, V3, V4, V5, V6}) -> 
	<<?WUINT32(V1), ?WSTRING(V2), ?WUINT32(V3), ?WUINT32(V4), ?WUINT32(V5), ?WUINT32(V6)>>.

pt_public_guild_members_entry_list({_, V1, V2, V3, V4, V5, V6}) -> 
	<<?WUINT64(V1), ?WSTRING(V2), ?WUINT32(V3), ?WUINT32(V4), ?WUINT32(V5), ?WUINT32(V6)>>.

pt_public_guild_member_list({_, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11}) -> 
	<<?WUINT64(V1), ?WUINT32(V2), ?WSTRING(V3), ?WUINT32(V4), ?WUINT32(V5), ?WUINT32(V6), ?WUINT32(V7), ?WUINT32(V8), ?WUINT32(V9), ?WUINT32(V10), ?WUINT32(V11)>>.

pt_public_guild_info_list({_, V1, V2, V3, V4, V5, V6, V7}) -> 
	<<?WUINT64(V1), ?WSTRING(V2), ?WSTRING(V3), ?WUINT32(V4), ?WUINT32(V5), ?WUINT32(V6), ?WUINT32(V7)>>.

pt_public_get_success_list({_, V1, V2, V3, V4}) -> 
	<<?WUINT32(V1), ?WUINT64(V2), ?WUINT64(V3), ?WUINT64(V4)>>.

pt_public_common_rank({_, V1, V2, V3, V4}) -> 
	<<?WUINT32(V1), ?WUINT64(V2), ?WSTRING(V3), ?WUINT32(V4)>>.

pt_public_copy_times({_, V1, V2, V3, V4, V5}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WUINT32(V4), ?WUINT64(V5)>>.

pt_public_item_list({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3)>>.

pt_public_relife_task_info({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3)>>.

pt_public_activity_info({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3)>>.

pt_public_recycle_list({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_public_pet_list({_, V1, V2, V3}) -> 
	<<?WUINT64(V1), ?WUINT32(V2), ?WUINT32(V3)>>.

pt_public_gem_list({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3)>>.

pt_public_usr_buy_cell_info({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_public_cell_info({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WLIST(V2, pt_public_item_list)>>.

pt_public_store_info({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WLIST(V2, pt_public_cell_info)>>.

pt_public_pet_coll_info({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_public_pet_skill_books({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_public_pet_info({_, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WUINT32(V4), ?WUINT32(V5), ?WUINT32(V6), ?WUINT32(V7), ?WUINT32(V8), ?WUINT32(V9), ?WUINT32(V10), ?WUINT32(V11), ?WUINT32(V12), ?WLIST(V13, pt_public_pet_skill_books)>>.

pt_public_scene_trap({_, V1, V2, V3, V4, V5, V6, V7, V8}) -> 
	<<?WUINT64(V1), ?WUINT32(V2), ?WUINT32(V3), ?WUINT32(V4), ?WFLOAT(V5), ?WFLOAT(V6), ?WFLOAT(V7), ?WFLOAT(V8)>>.

pt_public_scene_arrow({_, V1, V2, V3, V4, V5, V6, V7, V8}) -> 
	<<?WUINT64(V1), ?WUINT32(V2), ?WUINT32(V3), ?WUINT32(V4), ?WFLOAT(V5), ?WFLOAT(V6), ?WFLOAT(V7), ?WFLOAT(V8)>>.

pt_public_equip_id_state_list({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_public_equip_id_list({_, V1}) -> 
	<<?WUINT32(V1)>>.

pt_public_usr_equip_list({_, V1, V2}) -> 
	<<?WUINT64(V1), ?WUINT32(V2)>>.

pt_public_team_member_list({_, V1, V2, V3, V4, V5, V6, V7, V8}) -> 
	<<?WUINT64(V1), ?WUINT32(V2), ?WUINT32(V3), ?WSTRING(V4), ?WUINT32(V5), ?WUINT32(V6), ?WUINT32(V7), ?WUINT32(V8)>>.

pt_public_mastery_list({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

pt_public_scene_entourage({_, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14, V15}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WUINT32(V4), ?WFLOAT(V5), ?WFLOAT(V6), ?WFLOAT(V7), ?WFLOAT(V8), ?WUINT64(V9), ?WSTRING(V10), ?WUINT32(V11), ?WUINT32(V12), ?WUINT32(V13), ?WUINT32(V14), ?WUINT32(V15)>>.

pt_public_normal_skill_list({_, V1, V2, V3, V4, V5, V6, V7, V8, V9}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WUINT32(V4), ?WUINT32(V5), ?WUINT32(V6), ?WUINT32(V7), ?WUINT32(V8), ?WUINT32(V9)>>.

pt_public_entourage_list({_, V1, V2, V3, V4}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WLIST(V3, pt_public_skill_list), ?WLIST(V4, pt_public_property_list)>>.

pt_public_property_list({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WINT32(V2)>>.

pt_public_equip_list({_, V1, V2, V3, V4}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WUINT32(V4)>>.

pt_public_skill_list({_, V1}) -> 
	<<?WUINT32(V1)>>.

pt_public_lost_list({_, V1, V2, V3, V4, V5}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WUINT32(V4), ?WUINT32(V5)>>.

pt_public_pickup_des({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3)>>.

pt_public_drop_des({_, V1, V2, V3, V4, V5, V6, V7}) -> 
	<<?WUINT32(V1), ?WUINT64(V2), ?WUINT32(V3), ?WUINT32(V4), ?WFLOAT(V5), ?WFLOAT(V6), ?WFLOAT(V7)>>.

pt_public_item_des({_, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WUINT32(V4), ?WUINT32(V5), ?WUINT32(V6), ?WUINT32(V7), ?WUINT32(V8), ?WUINT32(V9), ?WUINT32(V10), ?WUINT32(V11), ?WLIST(V12, uint32)>>.

pt_public_property({_, V1, V2, V3}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3)>>.

pt_public_skill_effect({_, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10}) -> 
	<<?WUINT64(V1), ?WUINT32(V2), ?WUINT32(V3), ?WUINT32(V4), ?WUINT32(V5), ?WUINT32(V6), ?WUINT32(V7), ?WFLOAT(V8), ?WFLOAT(V9), ?WFLOAT(V10)>>.

pt_public_scene_item({_, V1, V2, V3, V4, V5, V6, V7}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WFLOAT(V3), ?WFLOAT(V4), ?WFLOAT(V5), ?WFLOAT(V6), ?WUINT32(V7)>>.

pt_public_scene_monster({_, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14, V15, V16}) -> 
	<<?WUINT32(V1), ?WUINT32(V2), ?WUINT32(V3), ?WFLOAT(V4), ?WFLOAT(V5), ?WFLOAT(V6), ?WFLOAT(V7), ?WUINT32(V8), ?WUINT32(V9), ?WUINT32(V10), ?WUINT32(V11), ?WUINT32(V12), ?WUINT64(V13), ?WUINT64(V14), ?WSTRING(V15), ?WFLOAT(V16)>>.

pt_public_scene_ply({_, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14, V15, V16, V17, V18, V19, V20, V21, V22, V23, V24, V25, V26, V27, V28, V29, V30, V31}) -> 
	<<?WUINT64(V1), ?WSTRING(V2), ?WUINT32(V3), ?WUINT32(V4), ?WFLOAT(V5), ?WFLOAT(V6), ?WFLOAT(V7), ?WFLOAT(V8), ?WUINT32(V9), ?WUINT32(V10), ?WUINT32(V11), ?WUINT32(V12), ?WUINT32(V13), ?WUINT32(V14), ?WUINT64(V15), ?WUINT32(V16), ?WUINT32(V17), ?WUINT32(V18), ?WBYTE(V19), ?WUINT32(V20), ?WUINT32(V21), ?WUINT32(V22), ?WUINT32(V23), ?WUINT32(V24), ?WUINT32(V25), ?WSTRING(V26), ?WUINT32(V27), ?WUINT32(V28), ?WUINT32(V29), ?WUINT32(V30), ?WUINT32(V31)>>.

pt_public_create_usr_info({_, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12}) -> 
	<<?WUINT64(V1), ?WSTRING(V2), ?WUINT32(V3), ?WUINT32(V4), ?WUINT32(V5), ?WLIST(V6, pt_public_equip_id_list), ?WUINT32(V7), ?WUINT32(V8), ?WUINT32(V9), ?WUINT32(V10), ?WUINT32(V11), ?WUINT32(V12)>>.

pt_public_point3({_, V1, V2, V3}) -> 
	<<?WFLOAT(V1), ?WFLOAT(V2), ?WFLOAT(V3)>>.

pt_public_normal_info({_, V1, V2}) -> 
	<<?WINT32(V1), ?WSTRING(V2)>>.

pt_public_attr_info({_, V1, V2}) -> 
	<<?WUINT16(V1), ?WUINT32(V2)>>.

pt_public_two_int({_, V1, V2}) -> 
	<<?WUINT32(V1), ?WUINT32(V2)>>.

