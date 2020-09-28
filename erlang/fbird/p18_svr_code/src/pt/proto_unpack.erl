%% @doc 这个文件自动生成的，请不要修改
-module(proto_unpack).
-compile(export_all).
-include("proto_helper.hrl").

pt_break_succ(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{{pt_break_succ, V1}, B1}.

pt_daily_task_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RLIST(B1, pt_public_task_list),
	{{pt_daily_task_info, V1, V2}, B2}.

pt_guild_tec_info(B0) -> 
	{V1, B1} = ?RBYTE(B0),
	{V2, B2} = ?RBYTE(B1),
	{V3, B3} = ?RLIST(B2, pt_public_two_int),
	{{pt_guild_tec_info, V1, V2, V3}, B3}.

pt_main_task_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RLIST(B3, pt_public_task_list),
	{{pt_main_task_info, V1, V2, V3, V4}, B4}.

pt_item_detail_info(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_item_des),
	{{pt_item_detail_info, V1}, B1}.

pt_offline_reward(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RLIST(B1, pt_public_item_list),
	{{pt_offline_reward, V1, V2}, B2}.

pt_scene_hero_prop_change(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{{pt_scene_hero_prop_change, V1, V2, V3}, B3}.

pt_guide_info(B0) -> 
	{V1, B1} = ?RLIST(B0, uint32),
	{{pt_guide_info, V1}, B1}.

pt_other_usr_info(B0) -> 
	{V1, B1} = ?RBYTE(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RBYTE(B2),
	{V4, B4} = ?RBYTE(B3),
	{V5, B5} = ?RSTRING(B4),
	{V6, B6} = ?RSTRING(B5),
	{V7, B7} = ?RUINT32(B6),
	{V8, B8} = ?RLIST(B7, pt_public_on_battle_heros),
	{V9, B9} = ?RLIST(B8, pt_public_item_des),
	{{pt_other_usr_info, V1, V2, V3, V4, V5, V6, V7, V8, V9}, B9}.

pt_search_friends_result(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_pending_list),
	{{pt_search_friends_result, V1}, B1}.

pt_recommend_friends_info(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_pending_list),
	{{pt_recommend_friends_info, V1}, B1}.

pt_friends_apply_info(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_pending_list),
	{{pt_friends_apply_info, V1}, B1}.

pt_friends_info(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_friend_list),
	{{pt_friends_info, V1}, B1}.

pt_hero_expedition_hero_hp(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_left_hp),
	{{pt_hero_expedition_hero_hp, V1}, B1}.

pt_hero_expedition_scene_result(B0) -> 
	{V1, B1} = ?RBYTE(B0),
	{V2, B2} = ?RLIST(B1, pt_public_item_list),
	{V3, B3} = ?RLIST(B2, pt_public_scene_damage_list),
	{V4, B4} = ?RLIST(B3, pt_public_scene_damage_list),
	{{pt_hero_expedition_scene_result, V1, V2, V3, V4}, B4}.

pt_scene_copy_id(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{{pt_scene_copy_id, V1}, B1}.

pt_act_copy_scene_result(B0) -> 
	{V1, B1} = ?RBYTE(B0),
	{V2, B2} = ?RLIST(B1, pt_public_item_list),
	{V3, B3} = ?RLIST(B2, pt_public_item_list),
	{V4, B4} = ?RLIST(B3, pt_public_scene_damage_list),
	{V5, B5} = ?RLIST(B4, pt_public_scene_damage_list),
	{{pt_act_copy_scene_result, V1, V2, V3, V4, V5}, B5}.

pt_act_copy_scene_data(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RLIST(B1, pt_public_item_list),
	{{pt_act_copy_scene_data, V1, V2}, B2}.

pt_hero_expedition_succ(B0) -> 
	{{pt_hero_expedition_succ}, B0}.

pt_on_scene_heros(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_on_battle_data),
	{{pt_on_scene_heros, V1}, B1}.

pt_hero_expedition_info(B0) -> 
	{V1, B1} = ?RBYTE(B0),
	{V2, B2} = ?RBYTE(B1),
	{V3, B3} = ?RBYTE(B2),
	{V4, B4} = ?RBYTE(B3),
	{V5, B5} = ?RBYTE(B4),
	{V6, B6} = ?RBYTE(B5),
	{V7, B7} = ?RBYTE(B6),
	{V8, B8} = ?RLIST(B7, pt_public_expedition_pos),
	{V9, B9} = ?RLIST(B8, pt_public_expedition_sub_event),
	{{pt_hero_expedition_info, V1, V2, V3, V4, V5, V6, V7, V8, V9}, B9}.

pt_act_copy_info(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_act_copy),
	{{pt_act_copy_info, V1}, B1}.

pt_draw_record(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RLIST(B1, pt_public_draw_record_list),
	{{pt_draw_record, V1, V2}, B2}.

pt_high_turntable_result(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RLIST(B2, pt_public_turntable_list),
	{{pt_high_turntable_result, V1, V2, V3}, B3}.

pt_normal_turntable_result(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RLIST(B1, pt_public_item_list),
	{{pt_normal_turntable_result, V1, V2}, B2}.

pt_turntable_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RLIST(B2, pt_public_turntable_list),
	{{pt_turntable_info, V1, V2, V3}, B3}.

pt_guild_view_member_info(B0) -> 
	{V1, B1} = ?RBYTE(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RBYTE(B2),
	{V4, B4} = ?RSTRING(B3),
	{V5, B5} = ?RSTRING(B4),
	{V6, B6} = ?RUINT32(B5),
	{V7, B7} = ?RLIST(B6, pt_public_on_battle_heros),
	{V8, B8} = ?RLIST(B7, pt_public_item_des),
	{{pt_guild_view_member_info, V1, V2, V3, V4, V5, V6, V7, V8}, B8}.

pt_draw_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RLIST(B1, pt_public_draw_list),
	{{pt_draw_info, V1, V2}, B2}.

pt_draw_result(B0) -> 
	{V1, B1} = ?RBYTE(B0),
	{V2, B2} = ?RLIST(B1, pt_public_item_list),
	{{pt_draw_result, V1, V2}, B2}.

pt_recommend_guild_list(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_guild_info_list),
	{{pt_recommend_guild_list, V1}, B1}.

pt_create_guild(B0) -> 
	{V1, B1} = ?RBYTE(B0),
	{V2, B2} = ?RSTRING(B1),
	{V3, B3} = ?RSTRING(B2),
	{{pt_create_guild, V1, V2, V3}, B3}.

pt_entourage_substitution_result(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{{pt_entourage_substitution_result, V1}, B1}.

pt_defender_zhenfa(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_defender_zhenfa, V1, V2}, B2}.

pt_shenqi_update(B0) -> 
	{V1, B1} = ?RBYTE(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_shenqi_update, V1, V2}, B2}.

pt_shenqi_illustration(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_illustration_info),
	{{pt_shenqi_illustration, V1}, B1}.

pt_on_battle_heros(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_on_battle_data),
	{{pt_on_battle_heros, V1}, B1}.

pt_arena_challenge_single_info(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RLIST(B3, pt_public_entourage_info_list),
	{{pt_arena_challenge_single_info, V1, V2, V3, V4}, B4}.

pt_time_reward(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{{pt_time_reward, V1}, B1}.

pt_action_data_and_two_int_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RINT64(B1),
	{V3, B3} = ?RLIST(B2, pt_public_two_int),
	{{pt_action_data_and_two_int_list, V1, V2, V3}, B3}.

pt_item_num_update(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_two_int),
	{{pt_item_num_update, V1}, B1}.

pt_hero_illustration(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_illustration_info),
	{{pt_hero_illustration, V1}, B1}.

pt_arena_challenge_info(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_challenge_list),
	{{pt_arena_challenge_info, V1}, B1}.

pt_update_resource(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_resource_list),
	{{pt_update_resource, V1}, B1}.

pt_entourage_update(B0) -> 
	{V1, B1} = ?RBYTE(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_entourage_update, V1, V2}, B2}.

pt_arena_challenge(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RINT64(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RLIST(B4, pt_public_two_int),
	{{pt_arena_challenge, V1, V2, V3, V4, V5}, B5}.

pt_scene_monster_die(B0) -> 
	{V1, B1} = ?RINT32(B0),
	{{pt_scene_monster_die, V1}, B1}.

pt_scene_end(B0) -> 
	{V1, B1} = ?RINT32(B0),
	{{pt_scene_end, V1}, B1}.

pt_main_scene_result(B0) -> 
	{V1, B1} = ?RINT32(B0),
	{V2, B2} = ?RINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RUINT32(B4),
	{V6, B6} = ?RLIST(B5, pt_public_item_list),
	{V7, B7} = ?RLIST(B6, pt_public_scene_damage_list),
	{V8, B8} = ?RLIST(B7, pt_public_scene_damage_list),
	{{pt_main_scene_result, V1, V2, V3, V4, V5, V6, V7, V8}, B8}.

pt_main_scene_status(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{{pt_main_scene_status, V1}, B1}.

pt_action_two_int_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RLIST(B1, pt_public_two_int),
	{{pt_action_two_int_list, V1, V2}, B2}.

pt_hero_attr_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RLIST(B2, pt_public_attr_info),
	{{pt_hero_attr_info, V1, V2, V3}, B3}.

pt_gm_act_turntable_draw_result(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RLIST(B1, pt_public_item_list),
	{{pt_gm_act_turntable_draw_result, V1, V2}, B2}.

pt_gm_act_turntable(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RSTRING(B3),
	{V5, B5} = ?RLIST(B4, pt_public_act_turntable_des),
	{{pt_gm_act_turntable, V1, V2, V3, V4, V5}, B5}.

pt_gm_act_rmb_package(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RSTRING(B3),
	{V5, B5} = ?RLIST(B4, pt_public_act_rmb_package_des),
	{{pt_gm_act_rmb_package, V1, V2, V3, V4, V5}, B5}.

pt_gm_act_diamond_package(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RSTRING(B3),
	{V5, B5} = ?RLIST(B4, pt_public_act_diamond_package_des),
	{{pt_gm_act_diamond_package, V1, V2, V3, V4, V5}, B5}.

pt_gm_act_point_package(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RSTRING(B3),
	{V5, B5} = ?RLIST(B4, pt_public_act_point_package_des),
	{{pt_gm_act_point_package, V1, V2, V3, V4, V5}, B5}.

pt_gm_activity(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_activity_list),
	{{pt_gm_activity, V1}, B1}.

pt_gm_act_acc_login(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RSTRING(B4),
	{V6, B6} = ?RLIST(B5, pt_public_acc_login_des),
	{{pt_gm_act_acc_login, V1, V2, V3, V4, V5, V6}, B6}.

pt_gm_act_single_recharge(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RSTRING(B3),
	{V5, B5} = ?RLIST(B4, pt_public_single_recharge_des),
	{{pt_gm_act_single_recharge, V1, V2, V3, V4, V5}, B5}.

pt_arnea_store_info(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_arena_store_info_list),
	{{pt_arnea_store_info, V1}, B1}.

pt_arnea_task_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{{pt_arnea_task_info, V1, V2, V3}, B3}.

pt_arnea_season_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_arnea_season_info, V1, V2}, B2}.

pt_mystery_gift_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RSTRING(B2),
	{V4, B4} = ?RLIST(B3, pt_public_mystery_gift_info_des),
	{{pt_mystery_gift_info, V1, V2, V3, V4}, B4}.

pt_god_costume_draw(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RLIST(B1, pt_public_item_list),
	{{pt_god_costume_draw, V1, V2}, B2}.

pt_god_costume_illustration_info(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_id_list),
	{V2, B2} = ?RLIST(B1, pt_public_id_list),
	{{pt_god_costume_illustration_info, V1, V2}, B2}.

pt_god_costume_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_god_costume_info, V1, V2}, B2}.

pt_legendary_level_exp_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RLIST(B1, pt_public_legendary_exp_buy_list),
	{{pt_legendary_level_exp_info, V1, V2}, B2}.

pt_legendary_level_start(B0) -> 
	{V1, B1} = ?RSTRING(B0),
	{{pt_legendary_level_start, V1}, B1}.

pt_entourage_challenge(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RLIST(B3, pt_public_entourage_challenge_info),
	{{pt_entourage_challenge, V1, V2, V3, V4}, B4}.

pt_legendary_level_info(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_legendary_level_info_list),
	{{pt_legendary_level_info, V1}, B1}.

pt_system_time_zone(B0) -> 
	{V1, B1} = ?RINT32(B0),
	{{pt_system_time_zone, V1}, B1}.

pt_new_entourage_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RUINT32(B4),
	{V6, B6} = ?RUINT32(B5),
	{V7, B7} = ?RUINT32(B6),
	{V8, B8} = ?RUINT32(B7),
	{V9, B9} = ?RUINT32(B8),
	{V10, B10} = ?RUINT32(B9),
	{V11, B11} = ?RUINT32(B10),
	{V12, B12} = ?RUINT32(B11),
	{{pt_new_entourage_info, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12}, B12}.

pt_special_upgrade(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{{pt_special_upgrade, V1}, B1}.

pt_return_investment_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RSTRING(B2),
	{V4, B4} = ?RLIST(B3, pt_public_return_investment_des),
	{{pt_return_investment_info, V1, V2, V3, V4}, B4}.

pt_random_gift_package(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{{pt_random_gift_package, V1, V2, V3, V4}, B4}.

pt_guild_impeach(B0) -> 
	{V1, B1} = ?RSTRING(B0),
	{{pt_guild_impeach, V1}, B1}.

pt_head_suit_info(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_head_list),
	{{pt_head_suit_info, V1}, B1}.

pt_head_lev_info(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_head_list),
	{{pt_head_lev_info, V1}, B1}.

pt_shenqi_awaken(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{{pt_shenqi_awaken, V1}, B1}.

pt_melleboss_revive(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{{pt_melleboss_revive, V1}, B1}.

pt_revive_info_new(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{{pt_revive_info_new, V1, V2, V3}, B3}.

pt_melle_boss_scene_info(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{{pt_melle_boss_scene_info, V1, V2, V3, V4}, B4}.

pt_scene_change_camp(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_scene_change_camp, V1, V2}, B2}.

pt_melleboss_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RLIST(B3, pt_public_melleboss_list),
	{{pt_melleboss_info, V1, V2, V3, V4}, B4}.

pt_maze_ranklist(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RLIST(B2, pt_public_maze_ranklist),
	{{pt_maze_ranklist, V1, V2, V3}, B3}.

pt_lottery_carousel_list(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_id_list),
	{{pt_lottery_carousel_list, V1}, B1}.

pt_gm_act_lottery_carousel(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RSTRING(B3),
	{V5, B5} = ?RLIST(B4, pt_public_act_lottery_carousel_des),
	{{pt_gm_act_lottery_carousel, V1, V2, V3, V4, V5}, B5}.

pt_gm_act_literature_collection(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RSTRING(B3),
	{V5, B5} = ?RLIST(B4, pt_public_act_literature_collection_des),
	{{pt_gm_act_literature_collection, V1, V2, V3, V4, V5}, B5}.

pt_global_guild_ranklist_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RLIST(B3, pt_public_global_guild_ranklist),
	{{pt_global_guild_ranklist_info, V1, V2, V3, V4}, B4}.

pt_sailing_guard_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RLIST(B2, pt_public_guard_list),
	{{pt_sailing_guard_info, V1, V2, V3}, B3}.

pt_sailing_plunder_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RLIST(B1, pt_public_plunder_list),
	{{pt_sailing_plunder_info, V1, V2}, B2}.

pt_sailing_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RUINT32(B4),
	{V6, B6} = ?RUINT32(B5),
	{V7, B7} = ?RUINT32(B6),
	{V8, B8} = ?RSTRING(B7),
	{V9, B9} = ?RUINT32(B8),
	{V10, B10} = ?RUINT32(B9),
	{V11, B11} = ?RLIST(B10, pt_public_sailing_record),
	{{pt_sailing_info, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11}, B11}.

pt_maze_event(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RSTRING(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RUINT32(B4),
	{V6, B6} = ?RUINT32(B5),
	{V7, B7} = ?RUINT32(B6),
	{V8, B8} = ?RSTRING(B7),
	{V9, B9} = ?RUINT32(B8),
	{{pt_maze_event, V1, V2, V3, V4, V5, V6, V7, V8, V9}, B9}.

pt_maze_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RUINT32(B4),
	{V6, B6} = ?RUINT32(B5),
	{V7, B7} = ?RUINT32(B6),
	{V8, B8} = ?RUINT32(B7),
	{V9, B9} = ?RUINT32(B8),
	{V10, B10} = ?RLIST(B9, pt_public_item_list),
	{V11, B11} = ?RLIST(B10, pt_public_maze_record),
	{{pt_maze_info, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11}, B11}.

pt_mining_list(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_mining_list_des),
	{{pt_mining_list, V1}, B1}.

pt_mining_info(B0) -> 
	{V1, B1} = ?RBYTE(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RUINT32(B4),
	{V6, B6} = ?RUINT32(B5),
	{V7, B7} = ?RUINT32(B6),
	{V8, B8} = ?RUINT16(B7),
	{V9, B9} = ?RUINT16(B8),
	{V10, B10} = ?RUINT16(B9),
	{V11, B11} = ?RLIST(B10, pt_public_property_list),
	{V12, B12} = ?RLIST(B11, pt_public_mining_defend_des),
	{{pt_mining_info, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12}, B12}.

pt_ele_pearl_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RUINT32(B4),
	{{pt_ele_pearl_info, V1, V2, V3, V4, V5}, B5}.

pt_talent_draw(B0) -> 
	{V1, B1} = ?RLIST(B0, uint32),
	{V2, B2} = ?RLIST(B1, pt_public_item_list),
	{{pt_talent_draw, V1, V2}, B2}.

pt_talent_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RLIST(B1, pt_public_talent_skill_des),
	{{pt_talent_info, V1, V2}, B2}.

pt_gm_act_recharge_point(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RSTRING(B3),
	{V5, B5} = ?RLIST(B4, pt_public_act_recharge_point_des),
	{{pt_gm_act_recharge_point, V1, V2, V3, V4, V5}, B5}.

pt_praise_reward(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_praise_reward, V1, V2}, B2}.

pt_gm_act_limit_double_recharge(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RSTRING(B2),
	{{pt_gm_act_limit_double_recharge, V1, V2, V3}, B3}.

pt_global_arena_result(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RUINT32(B4),
	{V6, B6} = ?RLIST(B5, pt_public_item_list),
	{{pt_global_arena_result, V1, V2, V3, V4, V5, V6}, B6}.

pt_global_arena_match_start(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{{pt_global_arena_match_start, V1}, B1}.

pt_global_arena_match_succ(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{{pt_global_arena_match_succ, V1}, B1}.

pt_global_last_arena_ranklist(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RLIST(B1, pt_public_global_arena_last_ranklist_info),
	{{pt_global_last_arena_ranklist, V1, V2}, B2}.

pt_global_arena_ranklist(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RLIST(B1, pt_public_global_arena_ranklist_info),
	{{pt_global_arena_ranklist, V1, V2}, B2}.

pt_global_arena_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RUINT32(B4),
	{V6, B6} = ?RLIST(B5, pt_public_global_arena_daily_task),
	{V7, B7} = ?RUINT32(B6),
	{V8, B8} = ?RLIST(B7, pt_public_global_arena_daily_log),
	{V9, B9} = ?RUINT32(B8),
	{V10, B10} = ?RUINT32(B9),
	{V11, B11} = ?RUINT32(B10),
	{{pt_global_arena_info, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11}, B11}.

pt_guild_operation(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{{pt_guild_operation, V1}, B1}.

pt_guild_blessing_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{{pt_guild_blessing_info, V1}, B1}.

pt_worldlevel_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_worldlevel_info, V1, V2}, B2}.

pt_usr_title(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{V2, B2} = ?RUINT16(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RLIST(B3, pt_public_title_chpprof),
	{{pt_usr_title, V1, V2, V3, V4}, B4}.

pt_req_entourage_create_model(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_req_entourage_create_model, V1, V2}, B2}.

pt_entourage_create_model(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RUINT32(B4),
	{V6, B6} = ?RUINT32(B5),
	{V7, B7} = ?RUINT32(B6),
	{V8, B8} = ?RUINT32(B7),
	{{pt_entourage_create_model, V1, V2, V3, V4, V5, V6, V7, V8}, B8}.

pt_entourage_revive_new(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{{pt_entourage_revive_new, V1}, B1}.

pt_entourage_die_new(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_dead_entourage_list),
	{{pt_entourage_die_new, V1}, B1}.

pt_entourage_succeed_new(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_entourage_succeed_new, V1, V2}, B2}.

pt_entourage_info_new(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RLIST(B4, pt_public_property_list),
	{{pt_entourage_info_new, V1, V2, V3, V4, V5}, B5}.

pt_entourage_list_new(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_entourage_list),
	{{pt_entourage_list_new, V1}, B1}.

pt_sign_day(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{{pt_sign_day, V1}, B1}.

pt_entourage_property(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_property_list),
	{{pt_entourage_property, V1}, B1}.

pt_action_string_and_data(B0) -> 
	{V1, B1} = ?RINT32(B0),
	{V2, B2} = ?RINT32(B1),
	{V3, B3} = ?RSTRING(B2),
	{{pt_action_string_and_data, V1, V2, V3}, B3}.

pt_rechargejifen_shop(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RSTRING(B4),
	{V6, B6} = ?RLIST(B5, pt_public_jifen_shop),
	{{pt_rechargejifen_shop, V1, V2, V3, V4, V5, V6}, B6}.

pt_consumejifen_shop(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RSTRING(B4),
	{V6, B6} = ?RLIST(B5, pt_public_jifen_shop),
	{{pt_consumejifen_shop, V1, V2, V3, V4, V5, V6}, B6}.

pt_recharge_global_rank_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RUINT32(B4),
	{V6, B6} = ?RUINT32(B5),
	{V7, B7} = ?RSTRING(B6),
	{V8, B8} = ?RLIST(B7, pt_public_global_rewards_info),
	{V9, B9} = ?RLIST(B8, pt_public_recharge_global_rank_list),
	{{pt_recharge_global_rank_info, V1, V2, V3, V4, V5, V6, V7, V8, V9}, B9}.

pt_consume_global_rank_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RUINT32(B4),
	{V6, B6} = ?RUINT32(B5),
	{V7, B7} = ?RSTRING(B6),
	{V8, B8} = ?RLIST(B7, pt_public_global_rewards_info),
	{V9, B9} = ?RLIST(B8, pt_public_consume_global_rank_list),
	{{pt_consume_global_rank_info, V1, V2, V3, V4, V5, V6, V7, V8, V9}, B9}.

pt_usr_head(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RLIST(B2, pt_public_usrid_list),
	{{pt_usr_head, V1, V2, V3}, B3}.

pt_entourage_debt_exchange_succ(B0) -> 
	{V1, B1} = ?RSTRING(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_entourage_debt_exchange_succ, V1, V2}, B2}.

pt_limit_achievement_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RSTRING(B2),
	{V4, B4} = ?RLIST(B3, pt_public_limit_achievement_des),
	{{pt_limit_achievement_info, V1, V2, V3, V4}, B4}.

pt_continuous_recharge_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RSTRING(B3),
	{V5, B5} = ?RLIST(B4, pt_public_continuous_recharge_des),
	{{pt_continuous_recharge_info, V1, V2, V3, V4, V5}, B5}.

pt_entourage_rune_info(B0) -> 
	{V1, B1} = ?RINT32(B0),
	{V2, B2} = ?RINT32(B1),
	{V3, B3} = ?RINT32(B2),
	{V4, B4} = ?RINT32(B3),
	{V5, B5} = ?RLIST(B4, pt_public_property_list),
	{{pt_entourage_rune_info, V1, V2, V3, V4, V5}, B5}.

pt_action_list_and_data(B0) -> 
	{V1, B1} = ?RINT32(B0),
	{V2, B2} = ?RLIST(B1, pt_public_id_list),
	{V3, B3} = ?RINT32(B2),
	{{pt_action_list_and_data, V1, V2, V3}, B3}.

pt_action_tri_int(B0) -> 
	{V1, B1} = ?RINT32(B0),
	{V2, B2} = ?RINT64(B1),
	{V3, B3} = ?RINT64(B2),
	{V4, B4} = ?RINT64(B3),
	{{pt_action_tri_int, V1, V2, V3, V4}, B4}.

pt_entourage_revive(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{{pt_entourage_revive, V1}, B1}.

pt_entourage_die(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{{pt_entourage_die, V1}, B1}.

pt_gm_act_limit_summon(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RSTRING(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RUINT32(B4),
	{V6, B6} = ?RLIST(B5, pt_public_limit_summon_rank_reward_des),
	{V7, B7} = ?RLIST(B6, pt_public_limit_summon_ranking_des),
	{{pt_gm_act_limit_summon, V1, V2, V3, V4, V5, V6, V7}, B7}.

pt_all_system_activity(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_system_activity_info),
	{{pt_all_system_activity, V1}, B1}.

pt_system_activity_limitboss(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_system_activity_limitboss, V1, V2}, B2}.

pt_system_activity(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_system_activity, V1, V2}, B2}.

pt_gm_act_lv_rank(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RSTRING(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RLIST(B4, pt_public_lv_rank_reward_des),
	{V6, B6} = ?RLIST(B5, pt_public_gm_act_lv_rank_des),
	{{pt_gm_act_lv_rank, V1, V2, V3, V4, V5, V6}, B6}.

pt_random_task(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RUINT32(B4),
	{V6, B6} = ?RUINT32(B5),
	{V7, B7} = ?RUINT32(B6),
	{V8, B8} = ?RUINT32(B7),
	{{pt_random_task, V1, V2, V3, V4, V5, V6, V7, V8}, B8}.

pt_gm_act_reset_recharge(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RSTRING(B2),
	{V4, B4} = ?RLIST(B3, pt_public_gm_act_reset_recharge_des),
	{{pt_gm_act_reset_recharge, V1, V2, V3, V4}, B4}.

pt_artifact_fast(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{{pt_artifact_fast, V1, V2, V3}, B3}.

pt_revive_notify(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_revive_notify, V1, V2}, B2}.

pt_client_error_report(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RSTRING(B1),
	{{pt_client_error_report, V1, V2}, B2}.

pt_gm_act_package(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RSTRING(B2),
	{V4, B4} = ?RLIST(B3, pt_public_gm_act_package_des),
	{{pt_gm_act_package, V1, V2, V3, V4}, B4}.

pt_gm_act_treasure_record(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RLIST(B1, pt_public_treasure_record_des),
	{{pt_gm_act_treasure_record, V1, V2}, B2}.

pt_gm_act_treasure(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RSTRING(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RUINT32(B4),
	{V6, B6} = ?RUINT32(B5),
	{V7, B7} = ?RUINT32(B6),
	{V8, B8} = ?RUINT32(B7),
	{V9, B9} = ?RLIST(B8, pt_public_item_list),
	{V10, B10} = ?RLIST(B9, pt_public_item_list),
	{V11, B11} = ?RLIST(B10, pt_public_item_list),
	{V12, B12} = ?RLIST(B11, pt_public_treasure_exchange_des),
	{V13, B13} = ?RLIST(B12, pt_public_treasure_rank_reward_des),
	{V14, B14} = ?RLIST(B13, pt_public_treasure_ranking_des),
	{{pt_gm_act_treasure, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14}, B14}.

pt_recharge_return(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_recharge_return, V1, V2}, B2}.

pt_copy_data(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_copy_data, V1, V2}, B2}.

pt_worldboss_inspire(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{{pt_worldboss_inspire, V1}, B1}.

pt_worldboss_damage_rank(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RLIST(B1, pt_public_worldboss_damage_info),
	{{pt_worldboss_damage_rank, V1, V2}, B2}.

pt_worldboss_times(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_worldboss_times, V1, V2}, B2}.

pt_worldboss_list(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_worldboss_info),
	{{pt_worldboss_list, V1}, B1}.

pt_building_upgrade_complete(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{{pt_building_upgrade_complete, V1}, B1}.

pt_home_building_produce_begin(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{{pt_home_building_produce_begin, V1}, B1}.

pt_home_building_upgrade_begin(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{{pt_home_building_upgrade_begin, V1}, B1}.

pt_home_building_req_produce(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RLIST(B1, uint8),
	{{pt_home_building_req_produce, V1, V2}, B2}.

pt_home_building_gather_succ(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{{pt_home_building_gather_succ, V1}, B1}.

pt_home_building_factory_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RUINT32(B4),
	{V6, B6} = ?RLIST(B5, pt_public_item_list),
	{{pt_home_building_factory_info, V1, V2, V3, V4, V5, V6}, B6}.

pt_home_building_mine_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RLIST(B3, pt_public_home_building_worker_info),
	{V5, B5} = ?RLIST(B4, pt_public_home_building_worker_info),
	{V6, B6} = ?RUINT32(B5),
	{{pt_home_building_mine_info, V1, V2, V3, V4, V5, V6}, B6}.

pt_home_building_common_detail(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_home_building_common_detail, V1, V2}, B2}.

pt_home_building_list(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{V2, B2} = ?RLIST(B1, pt_public_home_building_base_info),
	{{pt_home_building_list, V1, V2}, B2}.

pt_online_status(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{V2, B2} = ?RBYTE(B1),
	{{pt_online_status, V1, V2}, B2}.

pt_barrier_rewards_info(B0) -> 
	{V1, B1} = ?RINT32(B0),
	{V2, B2} = ?RLIST(B1, pt_public_barrier_rewards_des),
	{{pt_barrier_rewards_info, V1, V2}, B2}.

pt_recent_chat(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_recent_chat_msg),
	{{pt_recent_chat, V1}, B1}.

pt_shenqi_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{{pt_shenqi_info, V1}, B1}.

pt_gm_act_double(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RSTRING(B2),
	{V4, B4} = ?RLIST(B3, pt_public_gm_act_double_des),
	{{pt_gm_act_double, V1, V2, V3, V4}, B4}.

pt_gm_act_discount(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RSTRING(B2),
	{V4, B4} = ?RLIST(B3, pt_public_gm_act_discount_des),
	{{pt_gm_act_discount, V1, V2, V3, V4}, B4}.

pt_acc_cost(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RSTRING(B2),
	{V4, B4} = ?RSTRING(B3),
	{V5, B5} = ?RUINT32(B4),
	{V6, B6} = ?RLIST(B5, pt_public_acc_cost_des),
	{{pt_acc_cost, V1, V2, V3, V4, V5, V6}, B6}.

pt_gm_act_drop(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RSTRING(B2),
	{{pt_gm_act_drop, V1, V2, V3}, B3}.

pt_gm_act_sale(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RSTRING(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RLIST(B4, pt_public_gm_act_sale_des),
	{{pt_gm_act_sale, V1, V2, V3, V4, V5}, B5}.

pt_gm_act_exchange(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RSTRING(B2),
	{V4, B4} = ?RLIST(B3, pt_public_gm_act_exchange_des),
	{{pt_gm_act_exchange, V1, V2, V3, V4}, B4}.

pt_gm_act_week_task(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RSTRING(B2),
	{V4, B4} = ?RLIST(B3, pt_public_gm_act_week_task_des),
	{{pt_gm_act_week_task, V1, V2, V3, V4}, B4}.

pt_show_fetched_reward(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_friend_name_list),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RLIST(B2, pt_public_item_list),
	{{pt_show_fetched_reward, V1, V2, V3}, B3}.

pt_acc_recharge_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RSTRING(B2),
	{V4, B4} = ?RLIST(B3, pt_public_acc_recharge_des),
	{{pt_acc_recharge_info, V1, V2, V3, V4}, B4}.

pt_req_guild_stone_get(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{{pt_req_guild_stone_get, V1}, B1}.

pt_guild_stone_donation(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_guild_stone_donation, V1, V2}, B2}.

pt_req_guild_stone_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RLIST(B1, pt_public_guild_stone_list),
	{V3, B3} = ?RUINT32(B2),
	{{pt_req_guild_stone_info, V1, V2, V3}, B3}.

pt_task_step_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{{pt_task_step_info, V1, V2, V3, V4}, B4}.

pt_task_step(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_task_step, V1, V2}, B2}.

pt_req_fly_planes(B0) -> 
	{V1, B1} = ?RINT32(B0),
	{{pt_req_fly_planes, V1}, B1}.

pt_stroy_reward_info(B0) -> 
	{V1, B1} = ?RLIST(B0, uint32),
	{{pt_stroy_reward_info, V1}, B1}.

pt_story_show(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_story_show, V1, V2}, B2}.

pt_update_guild_inspire_times(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{{pt_update_guild_inspire_times, V1}, B1}.

pt_update_guild_boss_reward(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RLIST(B1, pt_public_id_list),
	{V3, B3} = ?RLIST(B2, pt_public_id_list),
	{{pt_update_guild_boss_reward, V1, V2, V3}, B3}.

pt_time_reward_item(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RLIST(B1, pt_public_time_reward),
	{{pt_time_reward_item, V1, V2}, B2}.

pt_time_reward_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RLIST(B2, uint32),
	{V4, B4} = ?RUINT32(B3),
	{{pt_time_reward_info, V1, V2, V3, V4}, B4}.

pt_req_setting_pick_item(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{{pt_req_setting_pick_item, V1, V2, V3}, B3}.

pt_update_quick_fight_info(B0) -> 
	{V1, B1} = ?RINT32(B0),
	{V2, B2} = ?RINT32(B1),
	{V3, B3} = ?RINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RUINT32(B4),
	{V6, B6} = ?RUINT32(B5),
	{V7, B7} = ?RLIST(B6, pt_public_item_list),
	{{pt_update_quick_fight_info, V1, V2, V3, V4, V5, V6, V7}, B7}.

pt_req_quick_fight(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{{pt_req_quick_fight, V1}, B1}.

pt_clear_skill_cd(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{{pt_clear_skill_cd, V1}, B1}.

pt_bslx(B0) -> 
	{{pt_bslx}, B0}.

pt_compose_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RUINT32(B4),
	{V6, B6} = ?RUINT32(B5),
	{V7, B7} = ?RUINT32(B6),
	{V8, B8} = ?RUINT32(B7),
	{V9, B9} = ?RLIST(B8, uint32),
	{V10, B10} = ?RLIST(B9, uint32),
	{V11, B11} = ?RLIST(B10, uint32),
	{V12, B12} = ?RUINT32(B11),
	{V13, B13} = ?RUINT32(B12),
	{V14, B14} = ?RUINT32(B13),
	{V15, B15} = ?RUINT32(B14),
	{V16, B16} = ?RUINT32(B15),
	{V17, B17} = ?RUINT32(B16),
	{{pt_compose_info, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14, V15, V16, V17}, B17}.

pt_melting_suc(B0) -> 
	{V1, B1} = ?RINT32(B0),
	{{pt_melting_suc, V1}, B1}.

pt_req_melting(B0) -> 
	{V1, B1} = ?RLIST(B0, uint32),
	{{pt_req_melting, V1}, B1}.

pt_sdk_auth_failed(B0) -> 
	{V1, B1} = ?RSTRING(B0),
	{{pt_sdk_auth_failed, V1}, B1}.

pt_flash_gift_bag_time(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_flash_gift_bag_time, V1, V2}, B2}.

pt_flash_gift_bag_info(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_flash_gift_bag_list),
	{{pt_flash_gift_bag_info, V1}, B1}.

pt_sky_ladder_scene_result(B0) -> 
	{V1, B1} = ?RINT32(B0),
	{{pt_sky_ladder_scene_result, V1}, B1}.

pt_sky_ladder_reward(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_reward_info),
	{{pt_sky_ladder_reward, V1}, B1}.

pt_sky_ladder_info(B0) -> 
	{V1, B1} = ?RINT32(B0),
	{V2, B2} = ?RINT32(B1),
	{V3, B3} = ?RINT32(B2),
	{V4, B4} = ?RINT32(B3),
	{V5, B5} = ?RINT32(B4),
	{V6, B6} = ?RINT32(B5),
	{V7, B7} = ?RINT32(B6),
	{V8, B8} = ?RINT32(B7),
	{{pt_sky_ladder_info, V1, V2, V3, V4, V5, V6, V7, V8}, B8}.

pt_artifact_forging(B0) -> 
	{{pt_artifact_forging}, B0}.

pt_pet_book(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_pet_skill_books),
	{{pt_pet_book, V1}, B1}.

pt_join_hero_challenge(B0) -> 
	{V1, B1} = ?RLIST(B0, uint32),
	{{pt_join_hero_challenge, V1}, B1}.

pt_pet_collect(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_pet_coll_info),
	{{pt_pet_collect, V1}, B1}.

pt_hero_challenge_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_hero_challenge_info, V1, V2}, B2}.

pt_mystery_store_buy(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_mystery_store_item_list),
	{{pt_mystery_store_buy, V1}, B1}.

pt_mystery_store_data(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RLIST(B1, pt_public_mystery_store_item_list),
	{{pt_mystery_store_data, V1, V2}, B2}.

pt_stamina_time(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{{pt_stamina_time, V1}, B1}.

pt_copy_time_rewards(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RLIST(B1, uint32),
	{{pt_copy_time_rewards, V1, V2}, B2}.

pt_military_skill(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RLIST(B1, pt_public_military_skill_info),
	{{pt_military_skill, V1, V2}, B2}.

pt_glory_sword(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{{pt_glory_sword, V1}, B1}.

pt_lost_item_recover(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{{pt_lost_item_recover, V1, V2, V3}, B3}.

pt_dress_suit_data(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_id_list),
	{{pt_dress_suit_data, V1}, B1}.

pt_recharge_package_data(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{{pt_recharge_package_data, V1}, B1}.

pt_turning_wheel_hide(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_turning_wheel_hide, V1, V2}, B2}.

pt_turning_wheel_config(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_turning_wheel_config_list),
	{{pt_turning_wheel_config, V1}, B1}.

pt_gm_continu_recharge_reward(B0) -> 
	{{pt_gm_continu_recharge_reward}, B0}.

pt_gm_continu_recharge_close(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_gm_continu_recharge_close, V1, V2}, B2}.

pt_gm_continu_recharge(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_diamond_lev_list),
	{{pt_gm_continu_recharge, V1}, B1}.

pt_rank_recharge_activity_time(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_rank_recharge_activity_time, V1, V2}, B2}.

pt_rank_consume_activity_time(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_rank_consume_activity_time, V1, V2}, B2}.

pt_recharge_rank_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RLIST(B1, pt_public_recharge_rank_list),
	{{pt_recharge_rank_info, V1, V2}, B2}.

pt_consume_rank_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RLIST(B1, pt_public_consume_rank_list),
	{{pt_consume_rank_info, V1, V2}, B2}.

pt_treasure_times(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{{pt_treasure_times, V1}, B1}.

pt_treasure_all_rewards(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RLIST(B2, pt_public_treasure_rewards_info),
	{{pt_treasure_all_rewards, V1, V2, V3}, B3}.

pt_extreme_luxury_gift(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_extreme_luxury_gift_info),
	{V2, B2} = ?RLIST(B1, pt_public_extreme_ranklist),
	{{pt_extreme_luxury_gift, V1, V2}, B2}.

pt_treasure_rewards(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_treasure_rewards_info),
	{{pt_treasure_rewards, V1}, B1}.

pt_treasure_activity_time(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_treasure_activity_time, V1, V2}, B2}.

pt_all_people_info(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_all_people_info),
	{{pt_all_people_info, V1}, B1}.

pt_share_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{{pt_share_info, V1}, B1}.

pt_other_usr_skill_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RLIST(B1, pt_public_other_usr_skill),
	{{pt_other_usr_skill_info, V1, V2}, B2}.

pt_flying_shoes(B0) -> 
	{{pt_flying_shoes}, B0}.

pt_entourage_mastery_grow(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_entourage_mastery_info),
	{{pt_entourage_mastery_grow, V1}, B1}.

pt_give_red_tips(B0) -> 
	{{pt_give_red_tips}, B0}.

pt_rev_red_response(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{{pt_rev_red_response, V1, V2, V3, V4}, B4}.

pt_pwd_red_info(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_pwd_red_list),
	{{pt_pwd_red_info, V1}, B1}.

pt_give_pwd_red(B0) -> 
	{V1, B1} = ?RSTRING(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{{pt_give_pwd_red, V1, V2, V3}, B3}.

pt_abyss_box(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_abyss_box, V1, V2}, B2}.

pt_open_svr_time_limit(B0) -> 
	{V1, B1} = ?RINT32(B0),
	{{pt_open_svr_time_limit, V1}, B1}.

pt_entourage_expedition_reward(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_id_list),
	{V2, B2} = ?RINT32(B1),
	{V3, B3} = ?RLIST(B2, pt_public_item_list),
	{V4, B4} = ?RINT32(B3),
	{{pt_entourage_expedition_reward, V1, V2, V3, V4}, B4}.

pt_call_up_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RINT64(B1),
	{V3, B3} = ?RSTRING(B2),
	{V4, B4} = ?RUINT32(B3),
	{{pt_call_up_info, V1, V2, V3, V4}, B4}.

pt_send_red_packet_info(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{V2, B2} = ?RSTRING(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RUINT32(B4),
	{{pt_send_red_packet_info, V1, V2, V3, V4, V5}, B5}.

pt_guild_team_copy_succeed(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_get_success_list),
	{{pt_guild_team_copy_succeed, V1}, B1}.

pt_guild_call_upon_broadcast(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{{pt_guild_call_upon_broadcast, V1}, B1}.

pt_req_guild_call_upon(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{{pt_req_guild_call_upon, V1, V2, V3, V4}, B4}.

pt_guild_team_info(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_guild_team_list),
	{{pt_guild_team_info, V1}, B1}.

pt_guild_team_copy_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RINT64(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RLIST(B3, pt_public_guild_team_copy_list),
	{{pt_guild_team_copy_info, V1, V2, V3, V4}, B4}.

pt_climb_tower_first_reward(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{{pt_climb_tower_first_reward, V1}, B1}.

pt_climb_tower_fast(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{{pt_climb_tower_fast, V1}, B1}.

pt_climb_tower_reset(B0) -> 
	{{pt_climb_tower_reset}, B0}.

pt_red_packet_rewards(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{{pt_red_packet_rewards, V1}, B1}.

pt_red_packet_surplus_time(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RUINT32(B4),
	{{pt_red_packet_surplus_time, V1, V2, V3, V4, V5}, B5}.

pt_climb_tower_data(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RLIST(B4, pt_public_climb_tower_first_reward),
	{{pt_climb_tower_data, V1, V2, V3, V4, V5}, B5}.

pt_team_process(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{{pt_team_process, V1, V2, V3}, B3}.

pt_inscription_info(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_inscription_list),
	{{pt_inscription_info, V1}, B1}.

pt_strength_oven_info(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_strength_oven_list),
	{{pt_strength_oven_info, V1}, B1}.

pt_expedition_request(B0) -> 
	{V1, B1} = ?RINT32(B0),
	{V2, B2} = ?RLIST(B1, pt_public_exped_entourage_list),
	{{pt_expedition_request, V1, V2}, B2}.

pt_rent_entourage_info(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_rent_entourage_list),
	{{pt_rent_entourage_info, V1}, B1}.

pt_exped_task(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RLIST(B2, pt_public_id_list),
	{{pt_exped_task, V1, V2, V3}, B3}.

pt_doing_exped_task(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_expedition_list),
	{{pt_doing_exped_task, V1}, B1}.

pt_rent_entourage(B0) -> 
	{V1, B1} = ?RINT32(B0),
	{V2, B2} = ?RINT32(B1),
	{{pt_rent_entourage, V1, V2}, B2}.

pt_seven_day_target_succeed(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_item_list),
	{{pt_seven_day_target_succeed, V1}, B1}.

pt_seven_day_target_rewards_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RLIST(B1, pt_public_seven_day_target_rewards_list),
	{{pt_seven_day_target_rewards_info, V1, V2}, B2}.

pt_seven_day_target_info(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_seven_day_target_info_list),
	{{pt_seven_day_target_info, V1}, B1}.

pt_open_svr_five_day_camp(B0) -> 
	{{pt_open_svr_five_day_camp}, B0}.

pt_open_svr_five_day_data(B0) -> 
	{V1, B1} = ?RINT32(B0),
	{V2, B2} = ?RINT32(B1),
	{V3, B3} = ?RINT32(B2),
	{V4, B4} = ?RLIST(B3, pt_public_five_act_info),
	{{pt_open_svr_five_day_data, V1, V2, V3, V4}, B4}.

pt_open_svr_five_day_time(B0) -> 
	{V1, B1} = ?RINT32(B0),
	{{pt_open_svr_five_day_time, V1}, B1}.

pt_boss_born_and_die(B0) -> 
	{V1, B1} = ?RINT32(B0),
	{V2, B2} = ?RINT32(B1),
	{{pt_boss_born_and_die, V1, V2}, B2}.

pt_hide_boss_response(B0) -> 
	{V1, B1} = ?RINT32(B0),
	{V2, B2} = ?RINT32(B1),
	{{pt_hide_boss_response, V1, V2}, B2}.

pt_hide_boss_data(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_id_list),
	{{pt_hide_boss_data, V1}, B1}.

pt_war_ready_finish(B0) -> 
	{{pt_war_ready_finish}, B0}.

pt_scramble_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_scramble_info, V1, V2}, B2}.

pt_team_war_seq(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{{pt_team_war_seq, V1}, B1}.

pt_blacklist_info(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_blacklist_list),
	{{pt_blacklist_info, V1}, B1}.

pt_guild_impeach_president(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{{pt_guild_impeach_president, V1}, B1}.

pt_req_atlas_team_info(B0) -> 
	{{pt_req_atlas_team_info}, B0}.

pt_growth_bible_info(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_growth_bible_info),
	{{pt_growth_bible_info, V1}, B1}.

pt_usr_info_pet(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_pet_property_list),
	{V2, B2} = ?RLIST(B1, pt_public_other_pet_list),
	{V3, B3} = ?RUINT32(B2),
	{{pt_usr_info_pet, V1, V2, V3}, B3}.

pt_usr_info_mount(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RLIST(B1, pt_public_illusion_list),
	{V3, B3} = ?RLIST(B2, pt_public_mount_equip_list),
	{V4, B4} = ?RUINT32(B3),
	{{pt_usr_info_mount, V1, V2, V3, V4}, B4}.

pt_copy_notice_revive(B0) -> 
	{{pt_copy_notice_revive}, B0}.

pt_atlas_team_info(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_atlas_team_list),
	{{pt_atlas_team_info, V1}, B1}.

pt_war_damage_rank(B0) -> 
	{V1, B1} = ?RINT32(B0),
	{V2, B2} = ?RLIST(B1, pt_public_war_damage),
	{{pt_war_damage_rank, V1, V2}, B2}.

pt_update_name_succeed(B0) -> 
	{V1, B1} = ?RSTRING(B0),
	{{pt_update_name_succeed, V1}, B1}.

pt_updata_name_card(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RSTRING(B1),
	{{pt_updata_name_card, V1, V2}, B2}.

pt_scene_full_tips(B0) -> 
	{{pt_scene_full_tips}, B0}.

pt_ret_war_usr_area(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{{pt_ret_war_usr_area, V1}, B1}.

pt_ret_gamble_record(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_gamble_record),
	{{pt_ret_gamble_record, V1}, B1}.

pt_ret_guide_tag_point(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RUINT32(B4),
	{V6, B6} = ?RUINT32(B5),
	{V7, B7} = ?RUINT32(B6),
	{{pt_ret_guide_tag_point, V1, V2, V3, V4, V5, V6, V7}, B7}.

pt_ret_wheel_info(B0) -> 
	{V1, B1} = ?RUINT16(B0),
	{{pt_ret_wheel_info, V1}, B1}.

pt_national_war_start_time(B0) -> 
	{V1, B1} = ?RINT32(B0),
	{V2, B2} = ?RINT32(B1),
	{{pt_national_war_start_time, V1, V2}, B2}.

pt_national_war_tips(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_boss_info),
	{{pt_national_war_tips, V1}, B1}.

pt_flag_status(B0) -> 
	{V1, B1} = ?RINT32(B0),
	{V2, B2} = ?RINT32(B1),
	{{pt_flag_status, V1, V2}, B2}.

pt_flag_count(B0) -> 
	{V1, B1} = ?RINT32(B0),
	{V2, B2} = ?RINT32(B1),
	{V3, B3} = ?RINT32(B2),
	{{pt_flag_count, V1, V2, V3}, B3}.

pt_ret_fast_copy(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RBYTE(B1),
	{V3, B3} = ?RLIST(B2, pt_public_item_list),
	{{pt_ret_fast_copy, V1, V2, V3}, B3}.

pt_copy_rewards_info(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_item_list),
	{{pt_copy_rewards_info, V1}, B1}.

pt_picked_loginact(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RLIST(B1, pt_public_item_list),
	{{pt_picked_loginact, V1, V2}, B2}.

pt_picked_exchange(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RLIST(B1, pt_public_item_list),
	{{pt_picked_exchange, V1, V2}, B2}.

pt_picked_gift_recharge(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RLIST(B2, pt_public_item_list),
	{{pt_picked_gift_recharge, V1, V2, V3}, B3}.

pt_picked_repeat_recharge(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RLIST(B1, pt_public_item_list),
	{{pt_picked_repeat_recharge, V1, V2}, B2}.

pt_picked_single_recharge(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RLIST(B1, pt_public_item_list),
	{{pt_picked_single_recharge, V1, V2}, B2}.

pt_loginact_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RLIST(B4, pt_public_loginact_des),
	{{pt_loginact_info, V1, V2, V3, V4, V5}, B5}.

pt_exchange_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RLIST(B3, pt_public_exchange_des),
	{{pt_exchange_info, V1, V2, V3, V4}, B4}.

pt_gift_recharge_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RUINT32(B4),
	{V6, B6} = ?RUINT32(B5),
	{V7, B7} = ?RLIST(B6, pt_public_gift_des),
	{{pt_gift_recharge_info, V1, V2, V3, V4, V5, V6, V7}, B7}.

pt_repeat_recharge_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RUINT32(B4),
	{V6, B6} = ?RUINT32(B5),
	{V7, B7} = ?RLIST(B6, pt_public_repeat_des),
	{{pt_repeat_recharge_info, V1, V2, V3, V4, V5, V6, V7}, B7}.

pt_single_recharge_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RLIST(B2, pt_public_single_des),
	{{pt_single_recharge_info, V1, V2, V3}, B3}.

pt_fortress_task_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{{pt_fortress_task_info, V1, V2, V3, V4}, B4}.

pt_guild_post(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{{pt_guild_post, V1}, B1}.

pt_national_war_show_info(B0) -> 
	{V1, B1} = ?RINT32(B0),
	{V2, B2} = ?RINT32(B1),
	{V3, B3} = ?RINT32(B2),
	{{pt_national_war_show_info, V1, V2, V3}, B3}.

pt_wechat_rewards(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_wechat_rewards, V1, V2}, B2}.

pt_ret_items_buffer(B0) -> 
	{V1, B1} = ?RUINT16(B0),
	{V2, B2} = ?RLIST(B1, pt_public_item_list),
	{{pt_ret_items_buffer, V1, V2}, B2}.

pt_ret_gamble_price(B0) -> 
	{V1, B1} = ?RBYTE(B0),
	{V2, B2} = ?RLIST(B1, pt_public_id_list),
	{V3, B3} = ?RUINT16(B2),
	{{pt_ret_gamble_price, V1, V2, V3}, B3}.

pt_week_rewards_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RLIST(B1, pt_public_week_rewards_list),
	{{pt_week_rewards_info, V1, V2}, B2}.

pt_ret_gamble_info(B0) -> 
	{V1, B1} = ?RUINT16(B0),
	{V2, B2} = ?RBYTE(B1),
	{V3, B3} = ?RUINT16(B2),
	{V4, B4} = ?RUINT16(B3),
	{V5, B5} = ?RBYTE(B4),
	{V6, B6} = ?RUINT16(B5),
	{{pt_ret_gamble_info, V1, V2, V3, V4, V5, V6}, B6}.

pt_match_finish(B0) -> 
	{{pt_match_finish}, B0}.

pt_ret_gs_rewards(B0) -> 
	{V1, B1} = ?RBYTE(B0),
	{V2, B2} = ?RLIST(B1, pt_public_equip_rewards_list),
	{{pt_ret_gs_rewards, V1, V2}, B2}.

pt_equip_and_entourage_succeed(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_equip_and_entourage_succeed, V1, V2}, B2}.

pt_equip_rewards(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_equip_rewards_list),
	{{pt_equip_rewards, V1}, B1}.

pt_entourage_star_rewards(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_entourage_star_rewards),
	{{pt_entourage_star_rewards, V1}, B1}.

pt_royal_box_succeed(B0) -> 
	{V1, B1} = ?RINT32(B0),
	{V2, B2} = ?RLIST(B1, pt_public_recycle_list),
	{{pt_royal_box_succeed, V1, V2}, B2}.

pt_royal_box_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RINT32(B1),
	{V3, B3} = ?RLIST(B2, pt_public_royal_box_list),
	{{pt_royal_box_info, V1, V2, V3}, B3}.

pt_ans_match_war(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RBYTE(B1),
	{V3, B3} = ?RBYTE(B2),
	{{pt_ans_match_war, V1, V2, V3}, B3}.

pt_war_over(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RBYTE(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RLIST(B3, pt_public_item_list),
	{V5, B5} = ?RUINT32(B4),
	{V6, B6} = ?RUINT32(B5),
	{V7, B7} = ?RUINT32(B6),
	{V8, B8} = ?RUINT32(B7),
	{V9, B9} = ?RUINT32(B8),
	{V10, B10} = ?RUINT32(B9),
	{V11, B11} = ?RUINT32(B10),
	{V12, B12} = ?RUINT32(B11),
	{V13, B13} = ?RUINT32(B12),
	{{pt_war_over, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13}, B13}.

pt_ret_war_report(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RUINT16(B4),
	{V6, B6} = ?RUINT16(B5),
	{V7, B7} = ?RUINT16(B6),
	{V8, B8} = ?RUINT16(B7),
	{V9, B9} = ?RUINT16(B8),
	{{pt_ret_war_report, V1, V2, V3, V4, V5, V6, V7, V8, V9}, B9}.

pt_national_war_call_broadcast(B0) -> 
	{V1, B1} = ?RSTRING(B0),
	{{pt_national_war_call_broadcast, V1}, B1}.

pt_national_war_scrolls(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_present_entourage_scrolls),
	{{pt_national_war_scrolls, V1}, B1}.

pt_national_war_call(B0) -> 
	{V1, B1} = ?RINT32(B0),
	{{pt_national_war_call, V1}, B1}.

pt_national_war_record(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_national_war_record),
	{{pt_national_war_record, V1}, B1}.

pt_national_war_data(B0) -> 
	{V1, B1} = ?RINT32(B0),
	{V2, B2} = ?RINT32(B1),
	{V3, B3} = ?RINT32(B2),
	{V4, B4} = ?RINT32(B3),
	{V5, B5} = ?RINT32(B4),
	{V6, B6} = ?RINT32(B5),
	{V7, B7} = ?RINT32(B6),
	{V8, B8} = ?RINT32(B7),
	{{pt_national_war_data, V1, V2, V3, V4, V5, V6, V7, V8}, B8}.

pt_ret_war_times(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_war_info_list),
	{{pt_ret_war_times, V1}, B1}.

pt_entourage_star(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_entourage_star, V1, V2}, B2}.

pt_guild_task(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{{pt_guild_task, V1, V2, V3, V4}, B4}.

pt_task_rewards_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RLIST(B2, pt_public_task_rewards_list),
	{{pt_task_rewards_info, V1, V2, V3}, B3}.

pt_all_star(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{{pt_all_star, V1}, B1}.

pt_buy_coin(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RUINT32(B4),
	{V6, B6} = ?RUINT32(B5),
	{{pt_buy_coin, V1, V2, V3, V4, V5, V6}, B6}.

pt_move_sand_buff_id(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{{pt_move_sand_buff_id, V1, V2, V3}, B3}.

pt_move_sand_buff(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_move_sand_list),
	{{pt_move_sand_buff, V1}, B1}.

pt_return_quick_buy(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{{pt_return_quick_buy, V1, V2, V3}, B3}.

pt_req_quick_buy(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{{pt_req_quick_buy, V1, V2, V3}, B3}.

pt_retreve_succeed(B0) -> 
	{V1, B1} = ?RINT32(B0),
	{{pt_retreve_succeed, V1}, B1}.

pt_retrueve_info(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_retrueve_info),
	{{pt_retrueve_info, V1}, B1}.

pt_update_camp_leader(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{{pt_update_camp_leader, V1}, B1}.

pt_gen_order(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RSTRING(B1),
	{{pt_gen_order, V1, V2}, B2}.

pt_login_auth_succ(B0) -> 
	{V1, B1} = ?RSTRING(B0),
	{{pt_login_auth_succ, V1}, B1}.

pt_sdk_login(B0) -> 
	{V1, B1} = ?RSTRING(B0),
	{V2, B2} = ?RSTRING(B1),
	{V3, B3} = ?RSTRING(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RUINT32(B4),
	{V6, B6} = ?RUINT32(B5),
	{V7, B7} = ?RSTRING(B6),
	{{pt_sdk_login, V1, V2, V3, V4, V5, V6, V7}, B7}.

pt_off_line_succeed(B0) -> 
	{{pt_off_line_succeed}, B0}.

pt_off_line_exp(B0) -> 
	{V1, B1} = ?RINT32(B0),
	{V2, B2} = ?RINT32(B1),
	{V3, B3} = ?RINT32(B2),
	{V4, B4} = ?RINT32(B3),
	{V5, B5} = ?RINT32(B4),
	{{pt_off_line_exp, V1, V2, V3, V4, V5}, B5}.

pt_dart_time(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{{pt_dart_time, V1}, B1}.

pt_system_time(B0) -> 
	{V1, B1} = ?RINT32(B0),
	{V2, B2} = ?RINT32(B1),
	{{pt_system_time, V1, V2}, B2}.

pt_camp_leader_info(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{V2, B2} = ?RSTRING(B1),
	{V3, B3} = ?RINT32(B2),
	{V4, B4} = ?RINT32(B3),
	{V5, B5} = ?RINT32(B4),
	{V6, B6} = ?RINT32(B5),
	{V7, B7} = ?RINT32(B6),
	{V8, B8} = ?RLIST(B7, pt_public_deputy_list),
	{{pt_camp_leader_info, V1, V2, V3, V4, V5, V6, V7, V8}, B8}.

pt_dart_pos(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{{pt_dart_pos, V1, V2, V3}, B3}.

pt_exit_queue(B0) -> 
	{{pt_exit_queue}, B0}.

pt_ref_queue(B0) -> 
	{{pt_ref_queue}, B0}.

pt_abddart_activity(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_abddart_activity_list),
	{{pt_abddart_activity, V1}, B1}.

pt_camp_skill(B0) -> 
	{V1, B1} = ?RINT32(B0),
	{{pt_camp_skill, V1}, B1}.

pt_use_item_groupId(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_use_item_groupId),
	{{pt_use_item_groupId, V1}, B1}.

pt_dart_activity_state(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RLIST(B1, pt_public_activity_id_list),
	{{pt_dart_activity_state, V1, V2}, B2}.

pt_first_extend_recharge(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RLIST(B1, pt_public_item_list),
	{{pt_first_extend_recharge, V1, V2}, B2}.

pt_recharge_data(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_recharge_list),
	{{pt_recharge_data, V1}, B1}.

pt_entourage_fetter_info(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_entourage_fetter_info),
	{{pt_entourage_fetter_info, V1}, B1}.

pt_recharge_succ(B0) -> 
	{V1, B1} = ?RINT32(B0),
	{{pt_recharge_succ, V1}, B1}.

pt_entourage_soul_link(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_entourage_soul_link),
	{V2, B2} = ?RLIST(B1, uint32),
	{{pt_entourage_soul_link, V1, V2}, B2}.

pt_update_charge_active(B0) -> 
	{V1, B1} = ?RBYTE(B0),
	{V2, B2} = ?RINT32(B1),
	{{pt_update_charge_active, V1, V2}, B2}.

pt_ret_charge_active(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_charge_active),
	{{pt_ret_charge_active, V1}, B1}.

pt_honor_kill(B0) -> 
	{V1, B1} = ?RINT32(B0),
	{V2, B2} = ?RINT32(B1),
	{V3, B3} = ?RINT32(B2),
	{{pt_honor_kill, V1, V2, V3}, B3}.

pt_first_recharge(B0) -> 
	{V1, B1} = ?RINT32(B0),
	{V2, B2} = ?RINT32(B1),
	{V3, B3} = ?RINT32(B2),
	{V4, B4} = ?RINT32(B3),
	{{pt_first_recharge, V1, V2, V3, V4}, B4}.

pt_activity_success(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_item_list),
	{{pt_activity_success, V1}, B1}.

pt_vip_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RLIST(B1, pt_public_vip_rewards_list),
	{{pt_vip_info, V1, V2}, B2}.

pt_unlock_atlas(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_unlock_atlas_list),
	{{pt_unlock_atlas, V1}, B1}.

pt_arena_start_time(B0) -> 
	{V1, B1} = ?RINT32(B0),
	{{pt_arena_start_time, V1}, B1}.

pt_paragon_level(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_paragon_level),
	{{pt_paragon_level, V1}, B1}.

pt_item_model_clothes(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_item_model_clothes),
	{{pt_item_model_clothes, V1}, B1}.

pt_ret_achieves(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_achieve),
	{{pt_ret_achieves, V1}, B1}.

pt_scene_branching_info(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_scene_branching_info),
	{{pt_scene_branching_info, V1}, B1}.

pt_scene_load(B0) -> 
	{{pt_scene_load}, B0}.

pt_ptc_item_compound_succeed(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_get_success_list),
	{{pt_ptc_item_compound_succeed, V1}, B1}.

pt_camp_killed_military(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{{pt_camp_killed_military, V1}, B1}.

pt_chapter_succeed(B0) -> 
	{{pt_chapter_succeed}, B0}.

pt_ret_fast_trials(B0) -> 
	{V1, B1} = ?RINT32(B0),
	{V2, B2} = ?RINT32(B1),
	{V3, B3} = ?RINT32(B2),
	{V4, B4} = ?RINT32(B3),
	{V5, B5} = ?RLIST(B4, pt_public_item_list),
	{{pt_ret_fast_trials, V1, V2, V3, V4, V5}, B5}.

pt_arena_result(B0) -> 
	{V1, B1} = ?RBYTE(B0),
	{V2, B2} = ?RINT32(B1),
	{V3, B3} = ?RINT32(B2),
	{V4, B4} = ?RSTRING(B3),
	{V5, B5} = ?RSTRING(B4),
	{V6, B6} = ?RINT32(B5),
	{V7, B7} = ?RINT32(B6),
	{V8, B8} = ?RINT32(B7),
	{V9, B9} = ?RINT32(B8),
	{V10, B10} = ?RLIST(B9, pt_public_item_list),
	{V11, B11} = ?RLIST(B10, pt_public_scene_damage_list),
	{V12, B12} = ?RLIST(B11, pt_public_scene_damage_list),
	{{pt_arena_result, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12}, B12}.

pt_arena_reflush_cd(B0) -> 
	{V1, B1} = ?RINT32(B0),
	{{pt_arena_reflush_cd, V1}, B1}.

pt_arena_record_info(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_arena_record),
	{{pt_arena_record_info, V1}, B1}.

pt_challenger_reflush(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_challenge_list),
	{{pt_challenger_reflush, V1}, B1}.

pt_arena_info(B0) -> 
	{V1, B1} = ?RINT32(B0),
	{V2, B2} = ?RINT32(B1),
	{V3, B3} = ?RINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RUINT32(B4),
	{V6, B6} = ?RLIST(B5, pt_public_arena_record_list),
	{{pt_arena_info, V1, V2, V3, V4, V5, V6}, B6}.

pt_boss_lose(B0) -> 
	{V1, B1} = ?RINT32(B0),
	{{pt_boss_lose, V1}, B1}.

pt_boss_win(B0) -> 
	{V1, B1} = ?RINT32(B0),
	{V2, B2} = ?RINT32(B1),
	{V3, B3} = ?RINT32(B2),
	{V4, B4} = ?RLIST(B3, pt_public_item_list),
	{{pt_boss_win, V1, V2, V3, V4}, B4}.

pt_boss_info(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_boss_ex_info),
	{{pt_boss_info, V1}, B1}.

pt_update_monster_prop(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RLIST(B1, pt_public_property_list),
	{{pt_update_monster_prop, V1, V2}, B2}.

pt_req_quick_add_pet(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{{pt_req_quick_add_pet, V1}, B1}.

pt_guild_member_verify(B0) -> 
	{{pt_guild_member_verify}, B0}.

pt_chapter_info(B0) -> 
	{V1, B1} = ?RINT32(B0),
	{V2, B2} = ?RINT32(B1),
	{{pt_chapter_info, V1, V2}, B2}.

pt_seven_day_target_status(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_seven_day_target_status, V1, V2}, B2}.

pt_guild_notice(B0) -> 
	{V1, B1} = ?RSTRING(B0),
	{{pt_guild_notice, V1}, B1}.

pt_backpack_upgrade(B0) -> 
	{V1, B1} = ?RINT32(B0),
	{V2, B2} = ?RINT32(B1),
	{{pt_backpack_upgrade, V1, V2}, B2}.

pt_crowd_num(B0) -> 
	{V1, B1} = ?RINT32(B0),
	{{pt_crowd_num, V1}, B1}.

pt_copy_exist_time(B0) -> 
	{V1, B1} = ?RINT32(B0),
	{{pt_copy_exist_time, V1}, B1}.

pt_update_scene_usr_data(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RSTRING(B2),
	{V4, B4} = ?RUINT32(B3),
	{{pt_update_scene_usr_data, V1, V2, V3, V4}, B4}.

pt_req_continue_hc(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_drop_des),
	{{pt_req_continue_hc, V1}, B1}.

pt_guild_name(B0) -> 
	{V1, B1} = ?RSTRING(B0),
	{{pt_guild_name, V1}, B1}.

pt_item_model(B0) -> 
	{V1, B1} = ?RINT32(B0),
	{{pt_item_model, V1}, B1}.

pt_camp_activity(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RUINT32(B4),
	{V6, B6} = ?RUINT32(B5),
	{V7, B7} = ?RUINT32(B6),
	{V8, B8} = ?RUINT32(B7),
	{V9, B9} = ?RUINT32(B8),
	{V10, B10} = ?RUINT32(B9),
	{{pt_camp_activity, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10}, B10}.

pt_military_prize(B0) -> 
	{{pt_military_prize}, B0}.

pt_ret_hero_challenge(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RBYTE(B4),
	{V6, B6} = ?RLIST(B5, pt_public_entourage),
	{{pt_ret_hero_challenge, V1, V2, V3, V4, V5, V6}, B6}.

pt_camp_task(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{{pt_camp_task, V1, V2, V3}, B3}.

pt_scene_fly_scene(B0) -> 
	{V1, B1} = ?RINT32(B0),
	{{pt_scene_fly_scene, V1}, B1}.

pt_ret_risks_info(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_trial_nums),
	{{pt_ret_risks_info, V1}, B1}.

pt_worship_response(B0) -> 
	{{pt_worship_response}, B0}.

pt_can_worship(B0) -> 
	{V1, B1} = ?RINT32(B0),
	{{pt_can_worship, V1}, B1}.

pt_task_rewards_succeed(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_get_success_list),
	{{pt_task_rewards_succeed, V1}, B1}.

pt_wanted_task(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{{pt_wanted_task, V1, V2, V3, V4}, B4}.

pt_update_camp(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{V2, B2} = ?RINT32(B1),
	{{pt_update_camp, V1, V2}, B2}.

pt_ret_trials_info(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_trial_nums),
	{V2, B2} = ?RLIST(B1, pt_public_int32x4),
	{{pt_ret_trials_info, V1, V2}, B2}.

pt_join_camp(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{{pt_join_camp, V1}, B1}.

pt_vote_succ(B0) -> 
	{{pt_vote_succ}, B0}.

pt_camp_vote_data(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RLIST(B1, pt_public_camp_vote_list),
	{{pt_camp_vote_data, V1, V2}, B2}.

pt_archaeology_reward(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_draw_item_list),
	{{pt_archaeology_reward, V1}, B1}.

pt_archaeology(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RUINT32(B4),
	{{pt_archaeology, V1, V2, V3, V4, V5}, B5}.

pt_broadcast_ride_info(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{V2, B2} = ?RBYTE(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RUINT32(B4),
	{V6, B6} = ?RUINT32(B5),
	{V7, B7} = ?RUINT32(B6),
	{V8, B8} = ?RUINT32(B7),
	{V9, B9} = ?RUINT32(B8),
	{V10, B10} = ?RUINT32(B9),
	{{pt_broadcast_ride_info, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10}, B10}.

pt_item_info_return(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_item_des),
	{{pt_item_info_return, V1}, B1}.

pt_draw_times(B0) -> 
	{V1, B1} = ?RBYTE(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RLIST(B2, pt_public_draw_times),
	{{pt_draw_times, V1, V2, V3}, B3}.

pt_draw(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_draw_item_list),
	{{pt_draw, V1}, B1}.

pt_submit_ready(B0) -> 
	{V1, B1} = ?RSTRING(B0),
	{{pt_submit_ready, V1}, B1}.

pt_match_succ(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RLIST(B2, pt_public_match_succ_list),
	{{pt_match_succ, V1, V2, V3}, B3}.

pt_usr_info_entourage(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_entourage_info_list),
	{{pt_usr_info_entourage, V1}, B1}.

pt_usr_info_lost_item(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_lost_item_info),
	{{pt_usr_info_lost_item, V1}, B1}.

pt_usr_info_property(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RSTRING(B3),
	{V5, B5} = ?RUINT32(B4),
	{V6, B6} = ?RUINT32(B5),
	{V7, B7} = ?RUINT32(B6),
	{V8, B8} = ?RUINT32(B7),
	{V9, B9} = ?RUINT32(B8),
	{V10, B10} = ?RUINT32(B9),
	{V11, B11} = ?RUINT32(B10),
	{V12, B12} = ?RUINT32(B11),
	{V13, B13} = ?RUINT32(B12),
	{V14, B14} = ?RUINT32(B13),
	{V15, B15} = ?RUINT32(B14),
	{V16, B16} = ?RUINT32(B15),
	{V17, B17} = ?RUINT32(B16),
	{V18, B18} = ?RUINT32(B17),
	{V19, B19} = ?RUINT32(B18),
	{V20, B20} = ?RUINT32(B19),
	{V21, B21} = ?RUINT32(B20),
	{V22, B22} = ?RUINT32(B21),
	{V23, B23} = ?RUINT32(B22),
	{V24, B24} = ?RUINT32(B23),
	{V25, B25} = ?RUINT32(B24),
	{V26, B26} = ?RUINT32(B25),
	{V27, B27} = ?RUINT32(B26),
	{V28, B28} = ?RUINT32(B27),
	{V29, B29} = ?RUINT32(B28),
	{V30, B30} = ?RUINT32(B29),
	{V31, B31} = ?RUINT32(B30),
	{V32, B32} = ?RUINT32(B31),
	{V33, B33} = ?RUINT32(B32),
	{V34, B34} = ?RUINT32(B33),
	{V35, B35} = ?RUINT32(B34),
	{V36, B36} = ?RUINT32(B35),
	{{pt_usr_info_property, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14, V15, V16, V17, V18, V19, V20, V21, V22, V23, V24, V25, V26, V27, V28, V29, V30, V31, V32, V33, V34, V35, V36}, B36}.

pt_usr_info_equi(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{V2, B2} = ?RSTRING(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RUINT32(B4),
	{V6, B6} = ?RUINT32(B5),
	{V7, B7} = ?RUINT32(B6),
	{V8, B8} = ?RUINT32(B7),
	{V9, B9} = ?RUINT32(B8),
	{V10, B10} = ?RUINT32(B9),
	{V11, B11} = ?RUINT32(B10),
	{V12, B12} = ?RUINT32(B11),
	{V13, B13} = ?RLIST(B12, pt_public_item_des),
	{V14, B14} = ?RLIST(B13, pt_public_other_gem_list),
	{{pt_usr_info_equi, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14}, B14}.

pt_start_match(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_start_match, V1, V2}, B2}.

pt_match_ready_cancel(B0) -> 
	{{pt_match_ready_cancel}, B0}.

pt_stop_match(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_stop_match, V1, V2}, B2}.

pt_req_match(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{{pt_req_match, V1}, B1}.

pt_rewards_return(B0) -> 
	{V1, B1} = ?RINT32(B0),
	{V2, B2} = ?RINT32(B1),
	{V3, B3} = ?RLIST(B2, pt_public_rewards_receive_list),
	{{pt_rewards_return, V1, V2, V3}, B3}.

pt_ret_skin_list(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_r_skin),
	{{pt_ret_skin_list, V1}, B1}.

pt_receive_rewards_succeed(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_get_success_list),
	{{pt_receive_rewards_succeed, V1}, B1}.

pt_ret_ride_prop(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_prop_entry),
	{{pt_ret_ride_prop, V1}, B1}.

pt_ret_ride_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RBYTE(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RBYTE(B4),
	{V6, B6} = ?RUINT32(B5),
	{V7, B7} = ?RUINT32(B6),
	{V8, B8} = ?RUINT32(B7),
	{V9, B9} = ?RUINT32(B8),
	{V10, B10} = ?RUINT32(B9),
	{V11, B11} = ?RUINT32(B10),
	{V12, B12} = ?RUINT32(B11),
	{V13, B13} = ?RUINT32(B12),
	{V14, B14} = ?RLIST(B13, pt_public_r_skin),
	{{pt_ret_ride_info, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14}, B14}.

pt_ranklist(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RLIST(B2, pt_public_ranklist),
	{{pt_ranklist, V1, V2, V3}, B3}.

pt_ret_scene_teams(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_team_info),
	{{pt_ret_scene_teams, V1}, B1}.

pt_mdf_team_info(B0) -> 
	{V1, B1} = ?RBYTE(B0),
	{V2, B2} = ?RBYTE(B1),
	{V3, B3} = ?RBYTE(B2),
	{V4, B4} = ?RBYTE(B3),
	{{pt_mdf_team_info, V1, V2, V3, V4}, B4}.

pt_update_usr_discrib(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{V2, B2} = ?RUINT16(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RSTRING(B3),
	{{pt_update_usr_discrib, V1, V2, V3, V4}, B4}.

pt_break_timer(B0) -> 
	{{pt_break_timer}, B0}.

pt_start_timer(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{{pt_start_timer, V1}, B1}.

pt_use_someone_title(B0) -> 
	{V1, B1} = ?RUINT16(B0),
	{{pt_use_someone_title, V1}, B1}.

pt_guild_copy_damage_ranking(B0) -> 
	{V1, B1} = ?RINT32(B0),
	{V2, B2} = ?RLIST(B1, pt_public_guild_copy_damage_ranking),
	{{pt_guild_copy_damage_ranking, V1, V2}, B2}.

pt_guild_copy_enter(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_guild_copy_enter_list),
	{{pt_guild_copy_enter, V1}, B1}.

pt_guild_copy_trophy(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_guild_copy_trophy_list),
	{{pt_guild_copy_trophy, V1}, B1}.

pt_guild_copy_list(B0) -> 
	{V1, B1} = ?RINT32(B0),
	{V2, B2} = ?RINT32(B1),
	{V3, B3} = ?RLIST(B2, pt_public_guild_copy_list),
	{{pt_guild_copy_list, V1, V2, V3}, B3}.

pt_monster_affiliation(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_monster_affiliation),
	{{pt_monster_affiliation, V1}, B1}.

pt_guild_building_list(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_guild_building_list),
	{{pt_guild_building_list, V1}, B1}.

pt_donation_record_list(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_donation_record_list),
	{{pt_donation_record_list, V1}, B1}.

pt_copy_win(B0) -> 
	{V1, B1} = ?RINT32(B0),
	{V2, B2} = ?RINT32(B1),
	{V3, B3} = ?RINT32(B2),
	{V4, B4} = ?RINT32(B3),
	{V5, B5} = ?RINT32(B4),
	{V6, B6} = ?RINT32(B5),
	{V7, B7} = ?RINT32(B6),
	{V8, B8} = ?RINT32(B7),
	{V9, B9} = ?RLIST(B8, pt_public_item_list),
	{V10, B10} = ?RLIST(B9, pt_public_item_list),
	{V11, B11} = ?RLIST(B10, pt_public_common_rank),
	{{pt_copy_win, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11}, B11}.

pt_invite_join_guild(B0) -> 
	{V1, B1} = ?RSTRING(B0),
	{V2, B2} = ?RSTRING(B1),
	{{pt_invite_join_guild, V1, V2}, B2}.

pt_update_mail(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_update_mails),
	{{pt_update_mail, V1}, B1}.

pt_read_mail_item(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_id_list),
	{{pt_read_mail_item, V1}, B1}.

pt_del_mail(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_id_list),
	{{pt_del_mail, V1}, B1}.

pt_mail_content(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RSTRING(B1),
	{V3, B3} = ?RSTRING(B2),
	{V4, B4} = ?RLIST(B3, pt_public_item_list),
	{{pt_mail_content, V1, V2, V3, V4}, B4}.

pt_req_mail(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_mail_list),
	{{pt_req_mail, V1}, B1}.

pt_ret_titles(B0) -> 
	{V1, B1} = ?RUINT16(B0),
	{V2, B2} = ?RLIST(B1, pt_public_title_obj),
	{{pt_ret_titles, V1, V2}, B2}.

pt_acquire_new_title(B0) -> 
	{V1, B1} = ?RUINT16(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_acquire_new_title, V1, V2}, B2}.

pt_scene_jump(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{V2, B2} = ?RFLOAT(B1),
	{V3, B3} = ?RFLOAT(B2),
	{V4, B4} = ?RFLOAT(B3),
	{V5, B5} = ?RFLOAT(B4),
	{{pt_scene_jump, V1, V2, V3, V4, V5}, B5}.

pt_req_jump(B0) -> 
	{{pt_req_jump}, B0}.

pt_req_chat(B0) -> 
	{V1, B1} = ?RSTRING(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RSTRING(B2),
	{{pt_req_chat, V1, V2, V3}, B3}.

pt_chat(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{V2, B2} = ?RINT64(B1),
	{V3, B3} = ?RSTRING(B2),
	{V4, B4} = ?RSTRING(B3),
	{V5, B5} = ?RUINT32(B4),
	{V6, B6} = ?RUINT32(B5),
	{V7, B7} = ?RLIST(B6, string),
	{V8, B8} = ?RUINT32(B7),
	{V9, B9} = ?RUINT32(B8),
	{V10, B10} = ?RUINT32(B9),
	{V11, B11} = ?RUINT32(B10),
	{V12, B12} = ?RSTRING(B11),
	{V13, B13} = ?RINT64(B12),
	{V14, B14} = ?RUINT32(B13),
	{{pt_chat, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14}, B14}.

pt_entourage_succeed(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_get_success_list),
	{{pt_entourage_succeed, V1}, B1}.

pt_item_recoin_return(B0) -> 
	{V1, B1} = ?RLIST(B0, uint32),
	{{pt_item_recoin_return, V1}, B1}.

pt_item_recoin(B0) -> 
	{V1, B1} = ?RINT32(B0),
	{V2, B2} = ?RLIST(B1, uint32),
	{{pt_item_recoin, V1, V2}, B2}.

pt_guild_succeed(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RLIST(B1, pt_public_guild_operation_list),
	{{pt_guild_succeed, V1, V2}, B2}.

pt_members_entry(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_guild_members_entry_list),
	{{pt_members_entry, V1}, B1}.

pt_guild_commonality(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{V2, B2} = ?RBYTE(B1),
	{V3, B3} = ?RSTRING(B2),
	{V4, B4} = ?RINT32(B3),
	{V5, B5} = ?RINT32(B4),
	{V6, B6} = ?RINT32(B5),
	{V7, B7} = ?RINT32(B6),
	{V8, B8} = ?RINT32(B7),
	{V9, B9} = ?RUINT32(B8),
	{V10, B10} = ?RSTRING(B9),
	{{pt_guild_commonality, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10}, B10}.

pt_guild_member_info(B0) -> 
	{V1, B1} = ?RBYTE(B0),
	{V2, B2} = ?RLIST(B1, pt_public_guild_member_list),
	{{pt_guild_member_info, V1, V2}, B2}.

pt_all_guild_list_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RLIST(B1, pt_public_guild_info_list),
	{{pt_all_guild_list_info, V1, V2}, B2}.

pt_revive_times(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_revive_times, V1, V2}, B2}.

pt_get_success(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_get_success_list),
	{{pt_get_success, V1}, B1}.

pt_copy_times(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_copy_times),
	{V2, B2} = ?RLIST(B1, uint32),
	{{pt_copy_times, V1, V2}, B2}.

pt_open_box_get_item(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_item_list),
	{{pt_open_box_get_item, V1}, B1}.

pt_revive(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RFLOAT(B2),
	{V4, B4} = ?RFLOAT(B3),
	{V5, B5} = ?RFLOAT(B4),
	{{pt_revive, V1, V2, V3, V4, V5}, B5}.

pt_progress_bar_end(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{{pt_progress_bar_end, V1, V2, V3}, B3}.

pt_progress_bar_begin(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_progress_bar_begin, V1, V2}, B2}.

pt_activity_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RLIST(B1, pt_public_activity_info),
	{V3, B3} = ?RLIST(B2, uint32),
	{{pt_activity_info, V1, V2, V3}, B3}.

pt_return_sign(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{{pt_return_sign, V1, V2, V3}, B3}.

pt_req_item_recycle(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_recycle_list),
	{{pt_req_item_recycle, V1}, B1}.

pt_say_notify(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_say_notify, V1, V2}, B2}.

pt_scene_item(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{{pt_scene_item, V1}, B1}.

pt_return_gem_update(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_gem_list),
	{{pt_return_gem_update, V1}, B1}.

pt_req_gem_update(B0) -> 
	{V1, B1} = ?RINT32(B0),
	{V2, B2} = ?RINT32(B1),
	{V3, B3} = ?RINT32(B2),
	{{pt_req_gem_update, V1, V2, V3}, B3}.

pt_store_buy(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{{pt_store_buy, V1, V2, V3}, B3}.

pt_store_info(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_store_info),
	{V2, B2} = ?RLIST(B1, pt_public_usr_buy_cell_info),
	{{pt_store_info, V1, V2}, B2}.

pt_pet(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{{pt_pet, V1, V2, V3, V4}, B4}.

pt_mastery_update(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_mastery_update, V1, V2}, B2}.

pt_mastery(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_mastery_list),
	{{pt_mastery, V1}, B1}.

pt_reloading(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RLIST(B2, pt_public_equip_id_state_list),
	{{pt_reloading, V1, V2, V3}, B3}.

pt_team_req_cancle(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{{pt_team_req_cancle, V1}, B1}.

pt_team_ask_cancle(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{{pt_team_ask_cancle, V1}, B1}.

pt_team_destroy(B0) -> 
	{{pt_team_destroy}, B0}.

pt_team_member_leave(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{{pt_team_member_leave, V1}, B1}.

pt_team_leader_chg(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{{pt_team_leader_chg, V1}, B1}.

pt_team_ans_req(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_team_ans_req, V1, V2}, B2}.

pt_team_req(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{V2, B2} = ?RSTRING(B1),
	{V3, B3} = ?RBYTE(B2),
	{{pt_team_req, V1, V2, V3}, B3}.

pt_team_ans_ask(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_team_ans_ask, V1, V2}, B2}.

pt_team_ask(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{V2, B2} = ?RSTRING(B1),
	{{pt_team_ask, V1, V2}, B2}.

pt_team_member_chg(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_team_member_list),
	{{pt_team_member_chg, V1}, B1}.

pt_team_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RINT64(B1),
	{V3, B3} = ?RINT64(B2),
	{V4, B4} = ?RLIST(B3, pt_public_team_member_list),
	{{pt_team_info, V1, V2, V3, V4}, B4}.

pt_entourage_create(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{{pt_entourage_create, V1, V2, V3}, B3}.

pt_update_base(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{V2, B2} = ?RLIST(B1, pt_public_property),
	{{pt_update_base, V1, V2}, B2}.

pt_action_two_int(B0) -> 
	{V1, B1} = ?RINT32(B0),
	{V2, B2} = ?RINT64(B1),
	{V3, B3} = ?RINT64(B2),
	{{pt_action_two_int, V1, V2, V3}, B3}.

pt_all_skill(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RLIST(B1, pt_public_normal_skill_list),
	{{pt_all_skill, V1, V2}, B2}.

pt_req_task_list(B0) -> 
	{{pt_req_task_list}, B0}.

pt_finish_task_response(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_finish_task_response, V1, V2}, B2}.

pt_del_task(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_del_task, V1, V2}, B2}.

pt_finish_task(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_finish_task, V1, V2}, B2}.

pt_accept_task(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_accept_task, V1, V2}, B2}.

pt_entourage_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RUINT32(B4),
	{V6, B6} = ?RUINT32(B5),
	{V7, B7} = ?RUINT32(B6),
	{V8, B8} = ?RUINT32(B7),
	{V9, B9} = ?RUINT32(B8),
	{V10, B10} = ?RUINT32(B9),
	{V11, B11} = ?RUINT32(B10),
	{V12, B12} = ?RLIST(B11, pt_public_skill_list),
	{V13, B13} = ?RLIST(B12, pt_public_equip_list),
	{V14, B14} = ?RLIST(B13, pt_public_property_list),
	{V15, B15} = ?RLIST(B14, pt_public_entourage_rune_list),
	{V16, B16} = ?RLIST(B15, pt_public_entourage_fetter_info),
	{{pt_entourage_info, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14, V15, V16}, B16}.

pt_entourage_list(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_entourage_list),
	{{pt_entourage_list, V1}, B1}.

pt_scene_transform(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RFLOAT(B3),
	{V5, B5} = ?RFLOAT(B4),
	{V6, B6} = ?RFLOAT(B5),
	{V7, B7} = ?RFLOAT(B6),
	{{pt_scene_transform, V1, V2, V3, V4, V5, V6, V7}, B7}.

pt_lost_item_active(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{{pt_lost_item_active, V1}, B1}.

pt_lost_item_lev(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{{pt_lost_item_lev, V1, V2, V3}, B3}.

pt_lost_item_get(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{{pt_lost_item_get, V1, V2, V3}, B3}.

pt_lost_item(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RLIST(B2, pt_public_lost_list),
	{{pt_lost_item, V1, V2, V3}, B3}.

pt_item_chg(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_item_des),
	{{pt_item_chg, V1}, B1}.

pt_item_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RLIST(B3, pt_public_item_des),
	{{pt_item_info, V1, V2, V3, V4}, B4}.

pt_scene_skill_aleret_cancel(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{{pt_scene_skill_aleret_cancel, V1, V2, V3, V4}, B4}.

pt_scene_skill_aleret(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RFLOAT(B4),
	{V6, B6} = ?RFLOAT(B5),
	{V7, B7} = ?RFLOAT(B6),
	{V8, B8} = ?RFLOAT(B7),
	{V9, B9} = ?RUINT32(B8),
	{V10, B10} = ?RFLOAT(B9),
	{V11, B11} = ?RFLOAT(B10),
	{V12, B12} = ?RFLOAT(B11),
	{V13, B13} = ?RFLOAT(B12),
	{V14, B14} = ?RFLOAT(B13),
	{V15, B15} = ?RFLOAT(B14),
	{V16, B16} = ?RFLOAT(B15),
	{{pt_scene_skill_aleret, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14, V15, V16}, B16}.

pt_scene_hide(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_scene_objs),
	{{pt_scene_hide, V1}, B1}.

pt_scene_usr_team_chg(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{{pt_scene_usr_team_chg, V1, V2, V3}, B3}.

pt_scene_delete_trap(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{{pt_scene_delete_trap, V1}, B1}.

pt_scene_add_trap(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_scene_trap),
	{{pt_scene_add_trap, V1}, B1}.

pt_scene_delete_arrow(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{{pt_scene_delete_arrow, V1}, B1}.

pt_scene_add_arrow(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_scene_arrow),
	{{pt_scene_add_arrow, V1}, B1}.

pt_scene_pickup(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_pickup_des),
	{{pt_scene_pickup, V1}, B1}.

pt_scene_drop(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RLIST(B1, pt_public_drop_des),
	{{pt_scene_drop, V1, V2}, B2}.

pt_scene_break_persistent(B0) -> 
	{{pt_scene_break_persistent}, B0}.

pt_scene_remove_buff(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{{pt_scene_remove_buff, V1, V2, V3}, B3}.

pt_scene_chg_buff(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RUINT32(B4),
	{V6, B6} = ?RUINT32(B5),
	{V7, B7} = ?RUINT32(B6),
	{V8, B8} = ?RUINT32(B7),
	{V9, B9} = ?RUINT32(B8),
	{{pt_scene_chg_buff, V1, V2, V3, V4, V5, V6, V7, V8, V9}, B9}.

pt_scene_property(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{V2, B2} = ?RLIST(B1, pt_public_property),
	{{pt_scene_property, V1, V2}, B2}.

pt_scene_skill_effect(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RINT64(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RUINT32(B4),
	{V6, B6} = ?RUINT32(B5),
	{V7, B7} = ?RFLOAT(B6),
	{V8, B8} = ?RFLOAT(B7),
	{V9, B9} = ?RFLOAT(B8),
	{V10, B10} = ?RFLOAT(B9),
	{V11, B11} = ?RINT64(B10),
	{V12, B12} = ?RFLOAT(B11),
	{V13, B13} = ?RFLOAT(B12),
	{V14, B14} = ?RFLOAT(B13),
	{V15, B15} = ?RFLOAT(B14),
	{V16, B16} = ?RFLOAT(B15),
	{V17, B17} = ?RFLOAT(B16),
	{V18, B18} = ?RLIST(B17, pt_public_skill_effect),
	{{pt_scene_skill_effect, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14, V15, V16, V17, V18}, B18}.

pt_scene_skill(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RINT64(B2),
	{V4, B4} = ?RFLOAT(B3),
	{V5, B5} = ?RFLOAT(B4),
	{V6, B6} = ?RFLOAT(B5),
	{V7, B7} = ?RFLOAT(B6),
	{V8, B8} = ?RINT64(B7),
	{V9, B9} = ?RFLOAT(B8),
	{V10, B10} = ?RFLOAT(B9),
	{V11, B11} = ?RFLOAT(B10),
	{{pt_scene_skill, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11}, B11}.

pt_scene_fly_by_fly_point(B0) -> 
	{V1, B1} = ?RINT32(B0),
	{{pt_scene_fly_by_fly_point, V1}, B1}.

pt_scene_dec(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{{pt_scene_dec, V1}, B1}.

pt_scene_add(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_scene_ply),
	{V2, B2} = ?RLIST(B1, pt_public_scene_monster),
	{V3, B3} = ?RLIST(B2, pt_public_scene_item),
	{V4, B4} = ?RLIST(B3, pt_public_scene_entourage),
	{V5, B5} = ?RLIST(B4, pt_public_usr_equip_list),
	{V6, B6} = ?RLIST(B5, pt_public_pet_list),
	{V7, B7} = ?RLIST(B6, pt_public_camp_model_list),
	{{pt_scene_add, V1, V2, V3, V4, V5, V6, V7}, B7}.

pt_niubi(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{{pt_niubi, V1}, B1}.

pt_scene_move(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RFLOAT(B2),
	{V4, B4} = ?RBYTE(B3),
	{V5, B5} = ?RLIST(B4, pt_public_point3),
	{{pt_scene_move, V1, V2, V3, V4, V5}, B5}.

pt_medicine(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_buff_list),
	{{pt_medicine, V1}, B1}.

pt_draw_base(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_draw_base, V1, V2}, B2}.

pt_relife_succeed(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{{pt_relife_succeed, V1}, B1}.

pt_ggb_battle_waiting(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{{pt_ggb_battle_waiting, V1}, B1}.

pt_ggb_battle_result(B0) -> 
	{V1, B1} = ?RBYTE(B0),
	{V2, B2} = ?RSTRING(B1),
	{V3, B3} = ?RSTRING(B2),
	{V4, B4} = ?RBYTE(B3),
	{V5, B5} = ?RSTRING(B4),
	{V6, B6} = ?RSTRING(B5),
	{V7, B7} = ?RBYTE(B6),
	{{pt_ggb_battle_result, V1, V2, V3, V4, V5, V6, V7}, B7}.

pt_ggb_nofity(B0) -> 
	{V1, B1} = ?RBYTE(B0),
	{{pt_ggb_nofity, V1}, B1}.

pt_ggb_battle_log(B0) -> 
	{V1, B1} = ?RBYTE(B0),
	{V2, B2} = ?RLIST(B1, pt_public_ggb_battle_record),
	{{pt_ggb_battle_log, V1, V2}, B2}.

pt_ggb_scene_report(B0) -> 
	{V1, B1} = ?RBYTE(B0),
	{V2, B2} = ?RLIST(B1, string),
	{{pt_ggb_scene_report, V1, V2}, B2}.

pt_ggb_scene_brief_info(B0) -> 
	{V1, B1} = ?RSTRING(B0),
	{V2, B2} = ?RSTRING(B1),
	{V3, B3} = ?RBYTE(B2),
	{V4, B4} = ?RBYTE(B3),
	{V5, B5} = ?RBYTE(B4),
	{V6, B6} = ?RBYTE(B5),
	{V7, B7} = ?RSTRING(B6),
	{V8, B8} = ?RSTRING(B7),
	{V9, B9} = ?RBYTE(B8),
	{V10, B10} = ?RBYTE(B9),
	{V11, B11} = ?RBYTE(B10),
	{V12, B12} = ?RBYTE(B11),
	{{pt_ggb_scene_brief_info, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12}, B12}.

pt_ggb_group_info(B0) -> 
	{V1, B1} = ?RBYTE(B0),
	{V2, B2} = ?RBYTE(B1),
	{V3, B3} = ?RBYTE(B2),
	{V4, B4} = ?RINT32(B3),
	{V5, B5} = ?RINT64(B4),
	{V6, B6} = ?RSTRING(B5),
	{V7, B7} = ?RSTRING(B6),
	{V8, B8} = ?RUINT32(B7),
	{V9, B9} = ?RBYTE(B8),
	{V10, B10} = ?RBYTE(B9),
	{V11, B11} = ?RBYTE(B10),
	{V12, B12} = ?RBYTE(B11),
	{V13, B13} = ?RUINT16(B12),
	{V14, B14} = ?RUINT16(B13),
	{V15, B15} = ?RINT32(B14),
	{V16, B16} = ?RINT64(B15),
	{V17, B17} = ?RSTRING(B16),
	{V18, B18} = ?RSTRING(B17),
	{V19, B19} = ?RUINT32(B18),
	{V20, B20} = ?RBYTE(B19),
	{V21, B21} = ?RBYTE(B20),
	{V22, B22} = ?RBYTE(B21),
	{V23, B23} = ?RBYTE(B22),
	{V24, B24} = ?RUINT16(B23),
	{V25, B25} = ?RUINT16(B24),
	{{pt_ggb_group_info, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14, V15, V16, V17, V18, V19, V20, V21, V22, V23, V24, V25}, B25}.

pt_ggb_my_team_info(B0) -> 
	{V1, B1} = ?RBYTE(B0),
	{V2, B2} = ?RBYTE(B1),
	{V3, B3} = ?RBYTE(B2),
	{V4, B4} = ?RBYTE(B3),
	{V5, B5} = ?RBYTE(B4),
	{V6, B6} = ?RSTRING(B5),
	{V7, B7} = ?RSTRING(B6),
	{{pt_ggb_my_team_info, V1, V2, V3, V4, V5, V6, V7}, B7}.

pt_ggb_info(B0) -> 
	{V1, B1} = ?RBYTE(B0),
	{V2, B2} = ?RBYTE(B1),
	{V3, B3} = ?RBYTE(B2),
	{V4, B4} = ?RBYTE(B3),
	{V5, B5} = ?RLIST(B4, pt_public_ggb_first_period_detail),
	{V6, B6} = ?RLIST(B5, pt_public_ggb_second_period_detail),
	{{pt_ggb_info, V1, V2, V3, V4, V5, V6}, B6}.

pt_charge_card(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RINT32(B1),
	{{pt_charge_card, V1, V2}, B2}.

pt_last_called_hero(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_combat_entourage_list),
	{{pt_last_called_hero, V1}, B1}.

pt_net_chg_code(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{{pt_net_chg_code, V1}, B1}.

pt_ping(B0) -> 
	{{pt_ping}, B0}.

pt_action_list(B0) -> 
	{V1, B1} = ?RINT32(B0),
	{V2, B2} = ?RLIST(B1, pt_public_id_list),
	{{pt_action_list, V1, V2}, B2}.

pt_action_float(B0) -> 
	{V1, B1} = ?RINT32(B0),
	{V2, B2} = ?RFLOAT(B1),
	{{pt_action_float, V1, V2}, B2}.

pt_action_string(B0) -> 
	{V1, B1} = ?RINT32(B0),
	{V2, B2} = ?RSTRING(B1),
	{{pt_action_string, V1, V2}, B2}.

pt_action_int(B0) -> 
	{V1, B1} = ?RINT32(B0),
	{V2, B2} = ?RINT64(B1),
	{{pt_action_int, V1, V2}, B2}.

pt_action(B0) -> 
	{V1, B1} = ?RINT32(B0),
	{{pt_action, V1}, B1}.

pt_delete_usr(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{{pt_delete_usr, V1}, B1}.

pt_req_delete_usr(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{{pt_req_delete_usr, V1}, B1}.

pt_create_usr_list(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_create_usr_info),
	{{pt_create_usr_list, V1}, B1}.

pt_req_create_usr(B0) -> 
	{V1, B1} = ?RSTRING(B0),
	{{pt_req_create_usr, V1}, B1}.

pt_scene_info(B0) -> 
	{V1, B1} = ?RUINT16(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_scene_info, V1, V2}, B2}.

pt_load_scene_finish(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{{pt_load_scene_finish, V1}, B1}.

pt_req_load_scene(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RFLOAT(B1),
	{V3, B3} = ?RFLOAT(B2),
	{V4, B4} = ?RFLOAT(B3),
	{V5, B5} = ?RFLOAT(B4),
	{V6, B6} = ?RFLOAT(B5),
	{{pt_req_load_scene, V1, V2, V3, V4, V5, V6}, B6}.

pt_usr_enter_scene(B0) -> 
	{{pt_usr_enter_scene}, B0}.

pt_usr_info(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{V2, B2} = ?RSTRING(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RUINT32(B4),
	{V6, B6} = ?RUINT32(B5),
	{V7, B7} = ?RSTRING(B6),
	{V8, B8} = ?RLIST(B7, pt_public_resource_list),
	{V9, B9} = ?RUINT32(B8),
	{V10, B10} = ?RUINT32(B9),
	{V11, B11} = ?RUINT32(B10),
	{V12, B12} = ?RUINT32(B11),
	{{pt_usr_info, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12}, B12}.

pt_usr_enter(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{V2, B2} = ?RBYTE(B1),
	{V3, B3} = ?RUINT32(B2),
	{{pt_usr_enter, V1, V2, V3}, B3}.

pt_net_info(B0) -> 
	{V1, B1} = ?RSTRING(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RINT64(B2),
	{V4, B4} = ?RUINT32(B3),
	{{pt_net_info, V1, V2, V3, V4}, B4}.

pt_queue_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_queue_info, V1, V2}, B2}.

pt_req_net(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_req_net, V1, V2}, B2}.

pt_usr_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RLIST(B2, pt_public_create_usr_info),
	{V4, B4} = ?RUINT32(B3),
	{{pt_usr_list, V1, V2, V3, V4}, B4}.

pt_error_info(B0) -> 
	{V1, B1} = ?RINT32(B0),
	{V2, B2} = ?RLIST(B1, pt_public_normal_info),
	{{pt_error_info, V1, V2}, B2}.

pt_login_robot(B0) -> 
	{V1, B1} = ?RSTRING(B0),
	{V2, B2} = ?RSTRING(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{{pt_login_robot, V1, V2, V3, V4}, B4}.

pt_login(B0) -> 
	{V1, B1} = ?RSTRING(B0),
	{V2, B2} = ?RSTRING(B1),
	{V3, B3} = ?RUINT32(B2),
	{{pt_login, V1, V2, V3}, B3}.

pt_grow_fund_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{{pt_grow_fund_info, V1, V2, V3, V4}, B4}.

pt_daily_acc_cost(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RSTRING(B3),
	{V5, B5} = ?RLIST(B4, pt_public_daily_acc_cost_des),
	{{pt_daily_acc_cost, V1, V2, V3, V4, V5}, B5}.

pt_daily_acc_recharge_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RLIST(B2, pt_public_daily_acc_recharge_des),
	{{pt_daily_acc_recharge_info, V1, V2, V3}, B3}.

pt_download_reward(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_download_reward, V1, V2}, B2}.

pt_relife_task_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RLIST(B1, pt_public_relife_task_info),
	{{pt_relife_task_info, V1, V2}, B2}.

pt_cast_shenqi_skill(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RINT64(B1),
	{V3, B3} = ?RFLOAT(B2),
	{V4, B4} = ?RFLOAT(B3),
	{V5, B5} = ?RFLOAT(B4),
	{{pt_cast_shenqi_skill, V1, V2, V3, V4, V5}, B5}.

pt_shenqi_skill_effect(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RINT64(B3),
	{V5, B5} = ?RFLOAT(B4),
	{V6, B6} = ?RFLOAT(B5),
	{V7, B7} = ?RFLOAT(B6),
	{V8, B8} = ?RLIST(B7, pt_public_skill_effect),
	{{pt_shenqi_skill_effect, V1, V2, V3, V4, V5, V6, V7, V8}, B8}.

