%% @doc 这个文件自动生成的，请不要修改
-module(proto_read_common).
-compile(export_all).
-include("proto_helper.hrl").


pt_public_task_list(B0) -> 
	{V1, B1} = ?RBYTE(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RBYTE(B2),
	{{pt_public_task_list, V1, V2, V3}, B3}.

pt_public_pending_list(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{V2, B2} = ?RSTRING(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{{pt_public_pending_list, V1, V2, V3, V4}, B4}.

pt_public_friend_list(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{V2, B2} = ?RSTRING(B1),
	{V3, B3} = ?RSTRING(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RUINT32(B4),
	{V6, B6} = ?RUINT32(B5),
	{V7, B7} = ?RUINT32(B6),
	{V8, B8} = ?RUINT32(B7),
	{{pt_public_friend_list, V1, V2, V3, V4, V5, V6, V7, V8}, B8}.

pt_public_left_hp(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_public_left_hp, V1, V2}, B2}.

pt_public_on_battle_data(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RLIST(B2, pt_public_on_battle_heros),
	{{pt_public_on_battle_data, V1, V2, V3}, B3}.

pt_public_draw_record_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RLIST(B1, pt_public_item_list),
	{{pt_public_draw_record_list, V1, V2}, B2}.

pt_public_turntable_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RINT32(B1),
	{V3, B3} = ?RLIST(B2, pt_public_item_list),
	{{pt_public_turntable_list, V1, V2, V3}, B3}.

pt_public_draw_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_public_draw_list, V1, V2}, B2}.

pt_public_expedition_sub_event(B0) -> 
	{V1, B1} = ?RBYTE(B0),
	{V2, B2} = ?RBYTE(B1),
	{{pt_public_expedition_sub_event, V1, V2}, B2}.

pt_public_expedition_pos(B0) -> 
	{V1, B1} = ?RBYTE(B0),
	{V2, B2} = ?RBYTE(B1),
	{V3, B3} = ?RBYTE(B2),
	{{pt_public_expedition_pos, V1, V2, V3}, B3}.

pt_public_act_copy(B0) -> 
	{V1, B1} = ?RBYTE(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RBYTE(B3),
	{V5, B5} = ?RBYTE(B4),
	{V6, B6} = ?RUINT32(B5),
	{{pt_public_act_copy, V1, V2, V3, V4, V5, V6}, B6}.

pt_public_arena_record_list(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{V2, B2} = ?RSTRING(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RUINT32(B4),
	{V6, B6} = ?RUINT32(B5),
	{{pt_public_arena_record_list, V1, V2, V3, V4, V5, V6}, B6}.

pt_public_illustration_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_public_illustration_info, V1, V2}, B2}.

pt_public_on_battle_heros(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RBYTE(B2),
	{{pt_public_on_battle_heros, V1, V2, V3}, B3}.

pt_public_act_turntable_point_reward_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RLIST(B2, pt_public_item_list),
	{V4, B4} = ?RSTRING(B3),
	{V5, B5} = ?RUINT32(B4),
	{{pt_public_act_turntable_point_reward_list, V1, V2, V3, V4, V5}, B5}.

pt_public_act_turntable_reward_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RLIST(B1, pt_public_item_list),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{{pt_public_act_turntable_reward_list, V1, V2, V3, V4}, B4}.

pt_public_act_turntable_des(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_act_turntable_reward_list),
	{V2, B2} = ?RLIST(B1, pt_public_item_list),
	{V3, B3} = ?RLIST(B2, pt_public_item_list),
	{V4, B4} = ?RLIST(B3, pt_public_item_list),
	{V5, B5} = ?RSTRING(B4),
	{V6, B6} = ?RUINT32(B5),
	{V7, B7} = ?RUINT32(B6),
	{V8, B8} = ?RUINT32(B7),
	{V9, B9} = ?RUINT32(B8),
	{V10, B10} = ?RLIST(B9, pt_public_act_turntable_point_reward_list),
	{{pt_public_act_turntable_des, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10}, B10}.

pt_public_act_rmb_package_des(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RLIST(B1, pt_public_item_list),
	{V3, B3} = ?RLIST(B2, pt_public_item_list),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RUINT32(B4),
	{{pt_public_act_rmb_package_des, V1, V2, V3, V4, V5}, B5}.

pt_public_act_diamond_package_des(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RSTRING(B1),
	{V3, B3} = ?RSTRING(B2),
	{V4, B4} = ?RLIST(B3, pt_public_item_list),
	{V5, B5} = ?RLIST(B4, pt_public_item_list),
	{V6, B6} = ?RUINT32(B5),
	{V7, B7} = ?RUINT32(B6),
	{{pt_public_act_diamond_package_des, V1, V2, V3, V4, V5, V6, V7}, B7}.

pt_public_act_point_package_box_des(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RUINT32(B4),
	{V6, B6} = ?RSTRING(B5),
	{V7, B7} = ?RSTRING(B6),
	{V8, B8} = ?RLIST(B7, pt_public_item_list),
	{V9, B9} = ?RLIST(B8, pt_public_item_list),
	{{pt_public_act_point_package_box_des, V1, V2, V3, V4, V5, V6, V7, V8, V9}, B9}.

pt_public_act_point_package_des(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RSTRING(B1),
	{V3, B3} = ?RLIST(B2, pt_public_act_point_package_box_des),
	{{pt_public_act_point_package_des, V1, V2, V3}, B3}.

pt_public_activity_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RSTRING(B1),
	{V3, B3} = ?RSTRING(B2),
	{{pt_public_activity_list, V1, V2, V3}, B3}.

pt_public_scene_damage_list(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{V2, B2} = ?RBYTE(B1),
	{V3, B3} = ?RBYTE(B2),
	{V4, B4} = ?RUINT32(B3),
	{{pt_public_scene_damage_list, V1, V2, V3, V4}, B4}.

pt_public_acc_login_des(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RLIST(B3, pt_public_item_list),
	{{pt_public_acc_login_des, V1, V2, V3, V4}, B4}.

pt_public_single_recharge_des(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RLIST(B2, pt_public_item_list),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RUINT32(B4),
	{V6, B6} = ?RUINT32(B5),
	{V7, B7} = ?RUINT32(B6),
	{{pt_public_single_recharge_des, V1, V2, V3, V4, V5, V6, V7}, B7}.

pt_public_arena_store_info_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_public_arena_store_info_list, V1, V2}, B2}.

pt_public_legendary_exp_buy_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_public_legendary_exp_buy_list, V1, V2}, B2}.

pt_public_entourage_challenge_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{{pt_public_entourage_challenge_info, V1, V2, V3}, B3}.

pt_public_legendary_level_info_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_public_legendary_level_info_list, V1, V2}, B2}.

pt_public_return_investment_reward_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RSTRING(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RLIST(B3, pt_public_item_list),
	{{pt_public_return_investment_reward_list, V1, V2, V3, V4}, B4}.

pt_public_mystery_gift_info_des(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RSTRING(B2),
	{V4, B4} = ?RSTRING(B3),
	{V5, B5} = ?RUINT32(B4),
	{V6, B6} = ?RUINT32(B5),
	{V7, B7} = ?RUINT32(B6),
	{V8, B8} = ?RSTRING(B7),
	{V9, B9} = ?RSTRING(B8),
	{V10, B10} = ?RLIST(B9, pt_public_item_list),
	{{pt_public_mystery_gift_info_des, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10}, B10}.

pt_public_return_investment_des(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RLIST(B2, pt_public_return_investment_reward_list),
	{{pt_public_return_investment_des, V1, V2, V3}, B3}.

pt_public_head_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_public_head_list, V1, V2}, B2}.

pt_public_melleboss_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{{pt_public_melleboss_list, V1, V2, V3, V4}, B4}.

pt_public_maze_ranklist(B0) -> 
	{V1, B1} = ?RSTRING(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{{pt_public_maze_ranklist, V1, V2, V3}, B3}.

pt_public_carousel_item_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{{pt_public_carousel_item_list, V1, V2, V3}, B3}.

pt_public_point_reward_list_des(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RSTRING(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RLIST(B3, pt_public_item_list),
	{{pt_public_point_reward_list_des, V1, V2, V3, V4}, B4}.

pt_public_point_ranklist_des(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{V2, B2} = ?RSTRING(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RSTRING(B3),
	{V5, B5} = ?RUINT32(B4),
	{V6, B6} = ?RLIST(B5, pt_public_item_list),
	{{pt_public_point_ranklist_des, V1, V2, V3, V4, V5, V6}, B6}.

pt_public_act_lottery_carousel_des(B0) -> 
	{V1, B1} = ?RLIST(B0, pt_public_carousel_item_list),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RUINT32(B4),
	{V6, B6} = ?RUINT32(B5),
	{V7, B7} = ?RLIST(B6, pt_public_point_ranklist_des),
	{V8, B8} = ?RLIST(B7, pt_public_point_reward_list_des),
	{{pt_public_act_lottery_carousel_des, V1, V2, V3, V4, V5, V6, V7, V8}, B8}.

pt_public_act_literature_collection_des(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RLIST(B3, pt_public_item_list),
	{V5, B5} = ?RLIST(B4, pt_public_item_list),
	{{pt_public_act_literature_collection_des, V1, V2, V3, V4, V5}, B5}.

pt_public_global_guild_ranklist(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RSTRING(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RSTRING(B3),
	{V5, B5} = ?RUINT32(B4),
	{V6, B6} = ?RUINT32(B5),
	{{pt_public_global_guild_ranklist, V1, V2, V3, V4, V5, V6}, B6}.

pt_public_mining_list_des(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{V2, B2} = ?RSTRING(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RBYTE(B3),
	{V5, B5} = ?RUINT32(B4),
	{V6, B6} = ?RUINT32(B5),
	{{pt_public_mining_list_des, V1, V2, V3, V4, V5, V6}, B6}.

pt_public_mining_defend_des(B0) -> 
	{V1, B1} = ?RBYTE(B0),
	{V2, B2} = ?RSTRING(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{{pt_public_mining_defend_des, V1, V2, V3, V4}, B4}.

pt_public_guard_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RINT64(B1),
	{V3, B3} = ?RSTRING(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RUINT32(B4),
	{{pt_public_guard_list, V1, V2, V3, V4, V5}, B5}.

pt_public_plunder_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RINT64(B2),
	{V4, B4} = ?RSTRING(B3),
	{V5, B5} = ?RSTRING(B4),
	{V6, B6} = ?RUINT32(B5),
	{V7, B7} = ?RSTRING(B6),
	{V8, B8} = ?RUINT32(B7),
	{V9, B9} = ?RUINT32(B8),
	{{pt_public_plunder_list, V1, V2, V3, V4, V5, V6, V7, V8, V9}, B9}.

pt_public_sailing_record(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RSTRING(B1),
	{V3, B3} = ?RSTRING(B2),
	{V4, B4} = ?RSTRING(B3),
	{V5, B5} = ?RUINT32(B4),
	{{pt_public_sailing_record, V1, V2, V3, V4, V5}, B5}.

pt_public_maze_record(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{V2, B2} = ?RSTRING(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RSTRING(B3),
	{V5, B5} = ?RUINT32(B4),
	{V6, B6} = ?RUINT32(B5),
	{V7, B7} = ?RUINT32(B6),
	{V8, B8} = ?RLIST(B7, pt_public_item_list),
	{{pt_public_maze_record, V1, V2, V3, V4, V5, V6, V7, V8}, B8}.

pt_public_act_recharge_total_des(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RSTRING(B3),
	{V5, B5} = ?RLIST(B4, pt_public_item_list),
	{V6, B6} = ?RUINT32(B5),
	{{pt_public_act_recharge_total_des, V1, V2, V3, V4, V5, V6}, B6}.

pt_public_act_recharge_own_des(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RSTRING(B3),
	{V5, B5} = ?RLIST(B4, pt_public_item_list),
	{V6, B6} = ?RUINT32(B5),
	{{pt_public_act_recharge_own_des, V1, V2, V3, V4, V5, V6}, B6}.

pt_public_act_recharge_ranklist_des(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RSTRING(B4),
	{V6, B6} = ?RLIST(B5, pt_public_item_list),
	{V7, B7} = ?RUINT32(B6),
	{{pt_public_act_recharge_ranklist_des, V1, V2, V3, V4, V5, V6, V7}, B7}.

pt_public_act_recharge_point_des(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RLIST(B3, pt_public_act_recharge_ranklist_des),
	{V5, B5} = ?RLIST(B4, pt_public_act_recharge_own_des),
	{V6, B6} = ?RLIST(B5, pt_public_act_recharge_total_des),
	{{pt_public_act_recharge_point_des, V1, V2, V3, V4, V5, V6}, B6}.

pt_public_global_arena_last_ranklist_info(B0) -> 
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
	{V13, B13} = ?RSTRING(B12),
	{{pt_public_global_arena_last_ranklist_info, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13}, B13}.

pt_public_global_arena_ranklist_info(B0) -> 
	{V1, B1} = ?RSTRING(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RUINT32(B4),
	{V6, B6} = ?RUINT32(B5),
	{V7, B7} = ?RUINT32(B6),
	{V8, B8} = ?RUINT32(B7),
	{V9, B9} = ?RSTRING(B8),
	{{pt_public_global_arena_ranklist_info, V1, V2, V3, V4, V5, V6, V7, V8, V9}, B9}.

pt_public_global_arena_daily_log(B0) -> 
	{V1, B1} = ?RSTRING(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RUINT32(B4),
	{{pt_public_global_arena_daily_log, V1, V2, V3, V4, V5}, B5}.

pt_public_global_arena_daily_task(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_public_global_arena_daily_task, V1, V2}, B2}.

pt_public_guild_operation_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RSTRING(B2),
	{V4, B4} = ?RSTRING(B3),
	{{pt_public_guild_operation_list, V1, V2, V3, V4}, B4}.

pt_public_title_chpprof(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{{pt_public_title_chpprof, V1, V2, V3}, B3}.

pt_public_jifen_shop(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{{pt_public_jifen_shop, V1, V2, V3}, B3}.

pt_public_global_rewards_info(B0) -> 
	{V1, B1} = ?RSTRING(B0),
	{V2, B2} = ?RLIST(B1, pt_public_item_list),
	{{pt_public_global_rewards_info, V1, V2}, B2}.

pt_public_recharge_global_rank_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RSTRING(B1),
	{V3, B3} = ?RSTRING(B2),
	{V4, B4} = ?RUINT32(B3),
	{{pt_public_recharge_global_rank_list, V1, V2, V3, V4}, B4}.

pt_public_consume_global_rank_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RSTRING(B1),
	{V3, B3} = ?RSTRING(B2),
	{V4, B4} = ?RUINT32(B3),
	{{pt_public_consume_global_rank_list, V1, V2, V3, V4}, B4}.

pt_public_talent_skill_des(B0) -> 
	{V1, B1} = ?RBYTE(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_public_talent_skill_des, V1, V2}, B2}.

pt_public_guild_ranklist(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{V2, B2} = ?RSTRING(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{{pt_public_guild_ranklist, V1, V2, V3, V4}, B4}.

pt_public_ggb_team_pos_info(B0) -> 
	{V1, B1} = ?RBYTE(B0),
	{V2, B2} = ?RBYTE(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RBYTE(B4),
	{V6, B6} = ?RSTRING(B5),
	{V7, B7} = ?RSTRING(B6),
	{{pt_public_ggb_team_pos_info, V1, V2, V3, V4, V5, V6, V7}, B7}.

pt_public_ggb_battle_record(B0) -> 
	{V1, B1} = ?RBYTE(B0),
	{V2, B2} = ?RBYTE(B1),
	{V3, B3} = ?RBYTE(B2),
	{V4, B4} = ?RSTRING(B3),
	{V5, B5} = ?RSTRING(B4),
	{V6, B6} = ?RUINT32(B5),
	{V7, B7} = ?RSTRING(B6),
	{V8, B8} = ?RSTRING(B7),
	{V9, B9} = ?RUINT32(B8),
	{{pt_public_ggb_battle_record, V1, V2, V3, V4, V5, V6, V7, V8, V9}, B9}.

pt_public_ggb_second_period_detail(B0) -> 
	{V1, B1} = ?RBYTE(B0),
	{V2, B2} = ?RLIST(B1, pt_public_ggb_team_pos_info),
	{{pt_public_ggb_second_period_detail, V1, V2}, B2}.

pt_public_ggb_first_period_detail(B0) -> 
	{V1, B1} = ?RBYTE(B0),
	{V2, B2} = ?RBYTE(B1),
	{V3, B3} = ?RLIST(B2, pt_public_ggb_battle_record),
	{{pt_public_ggb_first_period_detail, V1, V2, V3}, B3}.

pt_public_usrid_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{{pt_public_usrid_list, V1}, B1}.

pt_public_limit_achievement_ranking_des(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RINT64(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RSTRING(B4),
	{V6, B6} = ?RUINT32(B5),
	{{pt_public_limit_achievement_ranking_des, V1, V2, V3, V4, V5, V6}, B6}.

pt_public_limit_achievement_total_des(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RSTRING(B3),
	{V5, B5} = ?RLIST(B4, pt_public_item_list),
	{V6, B6} = ?RUINT32(B5),
	{{pt_public_limit_achievement_total_des, V1, V2, V3, V4, V5, V6}, B6}.

pt_public_limit_achievement_own_des(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RSTRING(B3),
	{V5, B5} = ?RLIST(B4, pt_public_item_list),
	{V6, B6} = ?RUINT32(B5),
	{{pt_public_limit_achievement_own_des, V1, V2, V3, V4, V5, V6}, B6}.

pt_public_limit_achievement_day_des(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RSTRING(B3),
	{V5, B5} = ?RLIST(B4, pt_public_item_list),
	{V6, B6} = ?RUINT32(B5),
	{{pt_public_limit_achievement_day_des, V1, V2, V3, V4, V5, V6}, B6}.

pt_public_limit_achievement_des(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RLIST(B3, pt_public_limit_achievement_day_des),
	{V5, B5} = ?RLIST(B4, pt_public_limit_achievement_own_des),
	{V6, B6} = ?RLIST(B5, pt_public_limit_achievement_total_des),
	{V7, B7} = ?RLIST(B6, pt_public_limit_achievement_ranking_des),
	{{pt_public_limit_achievement_des, V1, V2, V3, V4, V5, V6, V7}, B7}.

pt_public_continuous_recharge_reward_des(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RLIST(B2, pt_public_item_list),
	{V4, B4} = ?RSTRING(B3),
	{V5, B5} = ?RUINT32(B4),
	{{pt_public_continuous_recharge_reward_des, V1, V2, V3, V4, V5}, B5}.

pt_public_continuous_recharge_des(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RSTRING(B1),
	{V3, B3} = ?RLIST(B2, pt_public_item_list),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RUINT32(B4),
	{V6, B6} = ?RUINT32(B5),
	{V7, B7} = ?RSTRING(B6),
	{V8, B8} = ?RLIST(B7, pt_public_item_list),
	{V9, B9} = ?RUINT32(B8),
	{V10, B10} = ?RLIST(B9, pt_public_continuous_recharge_reward_des),
	{{pt_public_continuous_recharge_des, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10}, B10}.

pt_public_entourage_rune_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RLIST(B3, pt_public_property_list),
	{{pt_public_entourage_rune_list, V1, V2, V3, V4}, B4}.

pt_public_dead_entourage_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_public_dead_entourage_list, V1, V2}, B2}.

pt_public_combat_entourage_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{{pt_public_combat_entourage_list, V1}, B1}.

pt_public_limit_summon_rank_reward_des(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RLIST(B3, pt_public_item_list),
	{V5, B5} = ?RSTRING(B4),
	{{pt_public_limit_summon_rank_reward_des, V1, V2, V3, V4, V5}, B5}.

pt_public_limit_summon_ranking_des(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RINT64(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RSTRING(B4),
	{V6, B6} = ?RUINT32(B5),
	{{pt_public_limit_summon_ranking_des, V1, V2, V3, V4, V5, V6}, B6}.

pt_public_system_activity_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_public_system_activity_info, V1, V2}, B2}.

pt_public_gm_act_reset_recharge_des(B0) -> 
	{V1, B1} = ?RSTRING(B0),
	{V2, B2} = ?RSTRING(B1),
	{{pt_public_gm_act_reset_recharge_des, V1, V2}, B2}.

pt_public_institue_skill_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{{pt_public_institue_skill_list, V1, V2, V3}, B3}.

pt_public_help_work_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RINT64(B1),
	{V3, B3} = ?RSTRING(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RUINT32(B4),
	{V6, B6} = ?RUINT32(B5),
	{V7, B7} = ?RUINT32(B6),
	{V8, B8} = ?RUINT32(B7),
	{{pt_public_help_work_list, V1, V2, V3, V4, V5, V6, V7, V8}, B8}.

pt_public_friend_name_list(B0) -> 
	{V1, B1} = ?RSTRING(B0),
	{{pt_public_friend_name_list, V1}, B1}.

pt_public_buff_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_public_buff_list, V1, V2}, B2}.

pt_public_treasure_record_des(B0) -> 
	{V1, B1} = ?RSTRING(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_public_treasure_record_des, V1, V2}, B2}.

pt_public_treasure_exchange_des(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RUINT32(B4),
	{{pt_public_treasure_exchange_des, V1, V2, V3, V4, V5}, B5}.

pt_public_treasure_ranking_des(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RINT64(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RSTRING(B4),
	{V6, B6} = ?RUINT32(B5),
	{{pt_public_treasure_ranking_des, V1, V2, V3, V4, V5, V6}, B6}.

pt_public_treasure_rank_reward_des(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RLIST(B3, pt_public_item_list),
	{V5, B5} = ?RSTRING(B4),
	{{pt_public_treasure_rank_reward_des, V1, V2, V3, V4, V5}, B5}.

pt_public_home_building_worker_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RSTRING(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RUINT32(B4),
	{V6, B6} = ?RFLOAT(B5),
	{{pt_public_home_building_worker_info, V1, V2, V3, V4, V5, V6}, B6}.

pt_public_home_building_base_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RBYTE(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RUINT32(B4),
	{V6, B6} = ?RUINT32(B5),
	{V7, B7} = ?RUINT32(B6),
	{V8, B8} = ?RLIST(B7, pt_public_friend_name_list),
	{V9, B9} = ?RLIST(B8, pt_public_item_list),
	{V10, B10} = ?RUINT32(B9),
	{V11, B11} = ?RUINT32(B10),
	{V12, B12} = ?RUINT32(B11),
	{V13, B13} = ?RUINT32(B12),
	{V14, B14} = ?RLIST(B13, pt_public_help_work_list),
	{V15, B15} = ?RLIST(B14, pt_public_help_work_list),
	{V16, B16} = ?RLIST(B15, pt_public_institue_skill_list),
	{{pt_public_home_building_base_info, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14, V15, V16}, B16}.

pt_public_worldboss_damage_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RINT64(B1),
	{V3, B3} = ?RSTRING(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RUINT32(B4),
	{{pt_public_worldboss_damage_info, V1, V2, V3, V4, V5}, B5}.

pt_public_worldboss_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{{pt_public_worldboss_info, V1, V2, V3}, B3}.

pt_public_recent_chat_msg(B0) -> 
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
	{V12, B12} = ?RINT64(B11),
	{V13, B13} = ?RSTRING(B12),
	{{pt_public_recent_chat_msg, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13}, B13}.

pt_public_lv_rank_reward_des(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RLIST(B2, pt_public_item_list),
	{V4, B4} = ?RSTRING(B3),
	{{pt_public_lv_rank_reward_des, V1, V2, V3, V4}, B4}.

pt_public_gm_act_lv_rank_des(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RINT64(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RSTRING(B4),
	{V6, B6} = ?RUINT32(B5),
	{{pt_public_gm_act_lv_rank_des, V1, V2, V3, V4, V5, V6}, B6}.

pt_public_gm_act_package_des(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RSTRING(B1),
	{V3, B3} = ?RSTRING(B2),
	{V4, B4} = ?RLIST(B3, pt_public_item_list),
	{V5, B5} = ?RUINT32(B4),
	{V6, B6} = ?RUINT32(B5),
	{V7, B7} = ?RUINT32(B6),
	{V8, B8} = ?RSTRING(B7),
	{{pt_public_gm_act_package_des, V1, V2, V3, V4, V5, V6, V7, V8}, B8}.

pt_public_gm_act_double_des(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RSTRING(B1),
	{V3, B3} = ?RSTRING(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RLIST(B4, pt_public_item_list),
	{{pt_public_gm_act_double_des, V1, V2, V3, V4, V5}, B5}.

pt_public_gm_act_discount_des(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RSTRING(B1),
	{V3, B3} = ?RSTRING(B2),
	{V4, B4} = ?RUINT32(B3),
	{{pt_public_gm_act_discount_des, V1, V2, V3, V4}, B4}.

pt_public_gm_act_sale_des(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RSTRING(B3),
	{V5, B5} = ?RLIST(B4, pt_public_item_list),
	{V6, B6} = ?RUINT32(B5),
	{V7, B7} = ?RUINT32(B6),
	{V8, B8} = ?RUINT32(B7),
	{V9, B9} = ?RUINT32(B8),
	{V10, B10} = ?RUINT32(B9),
	{V11, B11} = ?RUINT32(B10),
	{{pt_public_gm_act_sale_des, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11}, B11}.

pt_public_gm_act_exchange_des(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RSTRING(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RUINT32(B4),
	{V6, B6} = ?RLIST(B5, pt_public_item_list),
	{V7, B7} = ?RLIST(B6, pt_public_item_list),
	{{pt_public_gm_act_exchange_des, V1, V2, V3, V4, V5, V6, V7}, B7}.

pt_public_daily_acc_cost_des(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RLIST(B3, pt_public_item_list),
	{{pt_public_daily_acc_cost_des, V1, V2, V3, V4}, B4}.

pt_public_acc_cost_des(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RLIST(B3, pt_public_item_list),
	{{pt_public_acc_cost_des, V1, V2, V3, V4}, B4}.

pt_public_barrier_rewards_des(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{{pt_public_barrier_rewards_des, V1, V2, V3, V4}, B4}.

pt_public_gm_act_week_task_des(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RSTRING(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RLIST(B4, uint32),
	{V6, B6} = ?RUINT32(B5),
	{V7, B7} = ?RLIST(B6, pt_public_item_list),
	{{pt_public_gm_act_week_task_des, V1, V2, V3, V4, V5, V6, V7}, B7}.

pt_public_daily_acc_recharge_des(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RSTRING(B4),
	{V6, B6} = ?RSTRING(B5),
	{V7, B7} = ?RLIST(B6, pt_public_item_list),
	{{pt_public_daily_acc_recharge_des, V1, V2, V3, V4, V5, V6, V7}, B7}.

pt_public_acc_recharge_des(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RSTRING(B4),
	{V6, B6} = ?RSTRING(B5),
	{V7, B7} = ?RLIST(B6, pt_public_item_list),
	{{pt_public_acc_recharge_des, V1, V2, V3, V4, V5, V6, V7}, B7}.

pt_public_guild_stone_list(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{V2, B2} = ?RSTRING(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{{pt_public_guild_stone_list, V1, V2, V3, V4}, B4}.

pt_public_time_reward(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_public_time_reward, V1, V2}, B2}.

pt_public_flash_gift_bag_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RLIST(B1, pt_public_item_list),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RUINT32(B4),
	{{pt_public_flash_gift_bag_list, V1, V2, V3, V4, V5}, B5}.

pt_public_reward_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_public_reward_info, V1, V2}, B2}.

pt_public_boss_ex_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{{pt_public_boss_ex_info, V1, V2, V3}, B3}.

pt_public_mystery_store_item_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_public_mystery_store_item_list, V1, V2}, B2}.

pt_public_military_skill_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_public_military_skill_info, V1, V2}, B2}.

pt_public_turning_wheel_config_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RINT32(B2),
	{V4, B4} = ?RFLOAT(B3),
	{{pt_public_turning_wheel_config_list, V1, V2, V3, V4}, B4}.

pt_public_diamond_lev_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RLIST(B2, pt_public_stat_item_list),
	{{pt_public_diamond_lev_list, V1, V2, V3}, B3}.

pt_public_stat_item_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{{pt_public_stat_item_list, V1, V2, V3}, B3}.

pt_public_recharge_rank_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RSTRING(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RLIST(B4, pt_public_treasure_rewards_info),
	{{pt_public_recharge_rank_list, V1, V2, V3, V4, V5}, B5}.

pt_public_consume_rank_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RSTRING(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RLIST(B4, pt_public_treasure_rewards_info),
	{{pt_public_consume_rank_list, V1, V2, V3, V4, V5}, B5}.

pt_public_extreme_ranklist(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RSTRING(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{{pt_public_extreme_ranklist, V1, V2, V3, V4}, B4}.

pt_public_extreme_luxury_gift_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RLIST(B2, pt_public_treasure_rewards_info),
	{{pt_public_extreme_luxury_gift_info, V1, V2, V3}, B3}.

pt_public_treasure_rewards_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_public_treasure_rewards_info, V1, V2}, B2}.

pt_public_all_people_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RLIST(B3, pt_public_treasure_rewards_info),
	{{pt_public_all_people_info, V1, V2, V3, V4}, B4}.

pt_public_other_usr_skill(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_public_other_usr_skill, V1, V2}, B2}.

pt_public_entourage_mastery_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_public_entourage_mastery_list, V1, V2}, B2}.

pt_public_entourage_mastery_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RLIST(B1, pt_public_entourage_mastery_list),
	{{pt_public_entourage_mastery_info, V1, V2}, B2}.

pt_public_pwd_red_list(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{V2, B2} = ?RSTRING(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RSTRING(B3),
	{V5, B5} = ?RUINT32(B4),
	{{pt_public_pwd_red_list, V1, V2, V3, V4, V5}, B5}.

pt_public_guild_team_list(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RSTRING(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RUINT32(B4),
	{V6, B6} = ?RUINT32(B5),
	{V7, B7} = ?RUINT32(B6),
	{V8, B8} = ?RUINT32(B7),
	{{pt_public_guild_team_list, V1, V2, V3, V4, V5, V6, V7, V8}, B8}.

pt_public_guild_team_copy_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_public_guild_team_copy_list, V1, V2}, B2}.

pt_public_climb_tower_first_reward(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_public_climb_tower_first_reward, V1, V2}, B2}.

pt_public_inscription_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_public_inscription_list, V1, V2}, B2}.

pt_public_exped_entourage_list(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_public_exped_entourage_list, V1, V2}, B2}.

pt_public_rent_entourage_list(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RUINT32(B4),
	{{pt_public_rent_entourage_list, V1, V2, V3, V4, V5}, B5}.

pt_public_expedition_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{{pt_public_expedition_list, V1, V2, V3}, B3}.

pt_public_strength_oven_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{{pt_public_strength_oven_list, V1, V2, V3}, B3}.

pt_public_seven_day_target_rewards_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{{pt_public_seven_day_target_rewards_list, V1, V2, V3}, B3}.

pt_public_seven_day_target_info_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{{pt_public_seven_day_target_info_list, V1, V2, V3}, B3}.

pt_public_five_act_info(B0) -> 
	{V1, B1} = ?RSTRING(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RSTRING(B2),
	{{pt_public_five_act_info, V1, V2, V3}, B3}.

pt_public_war_info_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{{pt_public_war_info_list, V1, V2, V3, V4}, B4}.

pt_public_blacklist_list(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RSTRING(B3),
	{V5, B5} = ?RUINT32(B4),
	{V6, B6} = ?RUINT32(B5),
	{{pt_public_blacklist_list, V1, V2, V3, V4, V5, V6}, B6}.

pt_public_growth_bible_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_public_growth_bible_info, V1, V2}, B2}.

pt_public_other_gem_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_public_other_gem_list, V1, V2}, B2}.

pt_public_other_pet_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{{pt_public_other_pet_list, V1}, B1}.

pt_public_pet_property_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_public_pet_property_list, V1, V2}, B2}.

pt_public_mount_equip_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{{pt_public_mount_equip_list, V1}, B1}.

pt_public_atlas_team_list(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{V2, B2} = ?RSTRING(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RUINT32(B4),
	{V6, B6} = ?RUINT32(B5),
	{{pt_public_atlas_team_list, V1, V2, V3, V4, V5, V6}, B6}.

pt_public_war_damage(B0) -> 
	{V1, B1} = ?RINT32(B0),
	{V2, B2} = ?RSTRING(B1),
	{V3, B3} = ?RINT32(B2),
	{{pt_public_war_damage, V1, V2, V3}, B3}.

pt_public_illusion_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{{pt_public_illusion_list, V1}, B1}.

pt_public_gamble_record(B0) -> 
	{V1, B1} = ?RSTRING(B0),
	{V2, B2} = ?RINT32(B1),
	{V3, B3} = ?RINT32(B2),
	{{pt_public_gamble_record, V1, V2, V3}, B3}.

pt_public_deputy_list(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{V2, B2} = ?RSTRING(B1),
	{V3, B3} = ?RINT32(B2),
	{V4, B4} = ?RINT32(B3),
	{V5, B5} = ?RINT32(B4),
	{V6, B6} = ?RINT32(B5),
	{{pt_public_deputy_list, V1, V2, V3, V4, V5, V6}, B6}.

pt_public_loginact_des(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RLIST(B2, pt_public_item_list),
	{{pt_public_loginact_des, V1, V2, V3}, B3}.

pt_public_exchange_des(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RLIST(B3, pt_public_item_list),
	{V5, B5} = ?RLIST(B4, pt_public_item_list),
	{{pt_public_exchange_des, V1, V2, V3, V4, V5}, B5}.

pt_public_gift_des(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RLIST(B3, pt_public_item_list),
	{{pt_public_gift_des, V1, V2, V3, V4}, B4}.

pt_public_repeat_des(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RLIST(B1, pt_public_item_list),
	{{pt_public_repeat_des, V1, V2}, B2}.

pt_public_single_des(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RUINT32(B4),
	{V6, B6} = ?RLIST(B5, pt_public_item_list),
	{{pt_public_single_des, V1, V2, V3, V4, V5, V6}, B6}.

pt_public_week_rewards_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{{pt_public_week_rewards_list, V1}, B1}.

pt_public_equip_rewards_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_public_equip_rewards_list, V1, V2}, B2}.

pt_public_entourage_star_rewards(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_public_entourage_star_rewards, V1, V2}, B2}.

pt_public_royal_box_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{{pt_public_royal_box_list, V1, V2, V3, V4}, B4}.

pt_public_national_war_record(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{{pt_public_national_war_record, V1, V2, V3}, B3}.

pt_public_present_entourage_scrolls(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{{pt_public_present_entourage_scrolls, V1, V2, V3, V4}, B4}.

pt_public_task_rewards_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_public_task_rewards_list, V1, V2}, B2}.

pt_public_move_sand_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{{pt_public_move_sand_list, V1, V2, V3}, B3}.

pt_public_retrueve_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_public_retrueve_info, V1, V2}, B2}.

pt_public_abddart_activity_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{{pt_public_abddart_activity_list, V1, V2, V3}, B3}.

pt_public_use_item_groupId(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_public_use_item_groupId, V1, V2}, B2}.

pt_public_activity_id_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{{pt_public_activity_id_list, V1}, B1}.

pt_public_recharge_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_public_recharge_list, V1, V2}, B2}.

pt_public_entourage_soul_link(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{{pt_public_entourage_soul_link, V1, V2, V3, V4}, B4}.

pt_public_entourage_fetter_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_public_entourage_fetter_info, V1, V2}, B2}.

pt_public_charge_active(B0) -> 
	{V1, B1} = ?RBYTE(B0),
	{V2, B2} = ?RBYTE(B1),
	{V3, B3} = ?RINT32(B2),
	{V4, B4} = ?RINT32(B3),
	{{pt_public_charge_active, V1, V2, V3, V4}, B4}.

pt_public_vip_rewards_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_public_vip_rewards_list, V1, V2}, B2}.

pt_public_unlock_atlas_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{{pt_public_unlock_atlas_list, V1}, B1}.

pt_public_paragon_level(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_public_paragon_level, V1, V2}, B2}.

pt_public_item_model_clothes(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT16(B2),
	{{pt_public_item_model_clothes, V1, V2, V3}, B3}.

pt_public_achieve(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{{pt_public_achieve, V1, V2, V3}, B3}.

pt_public_scene_branching_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_public_scene_branching_info, V1, V2}, B2}.

pt_public_int32x4(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{{pt_public_int32x4, V1, V2, V3, V4}, B4}.

pt_public_arena_record(B0) -> 
	{V1, B1} = ?RSTRING(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{{pt_public_arena_record, V1, V2, V3, V4}, B4}.

pt_public_challenge_list(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RSTRING(B2),
	{{pt_public_challenge_list, V1, V2, V3}, B3}.

pt_public_boss_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_public_boss_info, V1, V2}, B2}.

pt_public_resource_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_public_resource_list, V1, V2}, B2}.

pt_public_entourage(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_public_entourage, V1, V2}, B2}.

pt_public_camp_model_list(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{V2, B2} = ?RSTRING(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RFLOAT(B3),
	{V5, B5} = ?RFLOAT(B4),
	{V6, B6} = ?RFLOAT(B5),
	{V7, B7} = ?RFLOAT(B6),
	{V8, B8} = ?RUINT32(B7),
	{V9, B9} = ?RUINT32(B8),
	{V10, B10} = ?RUINT32(B9),
	{V11, B11} = ?RLIST(B10, pt_public_id_list),
	{{pt_public_camp_model_list, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11}, B11}.

pt_public_trial_nums(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RBYTE(B1),
	{{pt_public_trial_nums, V1, V2}, B2}.

pt_public_camp_vote_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RINT64(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RSTRING(B3),
	{V5, B5} = ?RUINT32(B4),
	{V6, B6} = ?RUINT32(B5),
	{{pt_public_camp_vote_list, V1, V2, V3, V4, V5, V6}, B6}.

pt_public_draw_item_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{{pt_public_draw_item_list, V1, V2, V3}, B3}.

pt_public_draw_times(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RUINT32(B4),
	{{pt_public_draw_times, V1, V2, V3, V4, V5}, B5}.

pt_public_lost_item_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{{pt_public_lost_item_info, V1, V2, V3}, B3}.

pt_public_entourage_info_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{{pt_public_entourage_info_list, V1, V2, V3}, B3}.

pt_public_match_succ_list(B0) -> 
	{V1, B1} = ?RSTRING(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{{pt_public_match_succ_list, V1, V2, V3}, B3}.

pt_public_rewards_receive_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{{pt_public_rewards_receive_list, V1}, B1}.

pt_public_prop_entry(B0) -> 
	{V1, B1} = ?RUINT16(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_public_prop_entry, V1, V2}, B2}.

pt_public_r_skin(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RUINT32(B4),
	{V6, B6} = ?RUINT32(B5),
	{V7, B7} = ?RUINT32(B6),
	{V8, B8} = ?RUINT32(B7),
	{V9, B9} = ?RUINT32(B8),
	{{pt_public_r_skin, V1, V2, V3, V4, V5, V6, V7, V8, V9}, B9}.

pt_public_ranklist(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RSTRING(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RUINT32(B4),
	{V6, B6} = ?RUINT32(B5),
	{V7, B7} = ?RSTRING(B6),
	{V8, B8} = ?RUINT32(B7),
	{{pt_public_ranklist, V1, V2, V3, V4, V5, V6, V7, V8}, B8}.

pt_public_team_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RBYTE(B1),
	{V3, B3} = ?RINT64(B2),
	{V4, B4} = ?RBYTE(B3),
	{V5, B5} = ?RUINT32(B4),
	{V6, B6} = ?RLIST(B5, pt_public_member_info),
	{{pt_public_team_info, V1, V2, V3, V4, V5, V6}, B6}.

pt_public_member_info(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{V2, B2} = ?RBYTE(B1),
	{V3, B3} = ?RSTRING(B2),
	{{pt_public_member_info, V1, V2, V3}, B3}.

pt_public_scene_objs(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RINT64(B1),
	{{pt_public_scene_objs, V1, V2}, B2}.

pt_public_guild_trophy_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{{pt_public_guild_trophy_list, V1, V2, V3, V4}, B4}.

pt_public_guild_copy_damage_ranking(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RINT64(B1),
	{V3, B3} = ?RSTRING(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RUINT32(B4),
	{V6, B6} = ?RUINT32(B5),
	{V7, B7} = ?RUINT32(B6),
	{V8, B8} = ?RUINT32(B7),
	{{pt_public_guild_copy_damage_ranking, V1, V2, V3, V4, V5, V6, V7, V8}, B8}.

pt_public_guild_copy_enter_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RSTRING(B2),
	{V4, B4} = ?RUINT32(B3),
	{{pt_public_guild_copy_enter_list, V1, V2, V3, V4}, B4}.

pt_public_guild_copy_trophy_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RLIST(B1, pt_public_guild_trophy_list),
	{{pt_public_guild_copy_trophy_list, V1, V2}, B2}.

pt_public_guild_copy_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RUINT32(B4),
	{V6, B6} = ?RUINT32(B5),
	{V7, B7} = ?RUINT32(B6),
	{V8, B8} = ?RSTRING(B7),
	{V9, B9} = ?RSTRING(B8),
	{V10, B10} = ?RUINT32(B9),
	{V11, B11} = ?RLIST(B10, pt_public_guild_ranklist),
	{{pt_public_guild_copy_list, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11}, B11}.

pt_public_monster_affiliation(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RINT64(B1),
	{{pt_public_monster_affiliation, V1, V2}, B2}.

pt_public_update_mails(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RLIST(B1, pt_public_item_list),
	{{pt_public_update_mails, V1, V2}, B2}.

pt_public_donation_record_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RSTRING(B1),
	{V3, B3} = ?RUINT32(B2),
	{{pt_public_donation_record_list, V1, V2, V3}, B3}.

pt_public_guild_building_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{{pt_public_guild_building_list, V1, V2, V3}, B3}.

pt_public_id_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{{pt_public_id_list, V1}, B1}.

pt_public_title_obj(B0) -> 
	{V1, B1} = ?RUINT16(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_public_title_obj, V1, V2}, B2}.

pt_public_mail_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RSTRING(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RUINT32(B4),
	{V6, B6} = ?RUINT32(B5),
	{{pt_public_mail_list, V1, V2, V3, V4, V5, V6}, B6}.

pt_public_guild_members_entry_list(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{V2, B2} = ?RSTRING(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RUINT32(B4),
	{V6, B6} = ?RUINT32(B5),
	{{pt_public_guild_members_entry_list, V1, V2, V3, V4, V5, V6}, B6}.

pt_public_guild_member_list(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RSTRING(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RUINT32(B4),
	{V6, B6} = ?RUINT32(B5),
	{V7, B7} = ?RUINT32(B6),
	{V8, B8} = ?RUINT32(B7),
	{V9, B9} = ?RUINT32(B8),
	{V10, B10} = ?RUINT32(B9),
	{V11, B11} = ?RUINT32(B10),
	{{pt_public_guild_member_list, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11}, B11}.

pt_public_guild_info_list(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{V2, B2} = ?RSTRING(B1),
	{V3, B3} = ?RSTRING(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RUINT32(B4),
	{V6, B6} = ?RUINT32(B5),
	{V7, B7} = ?RUINT32(B6),
	{{pt_public_guild_info_list, V1, V2, V3, V4, V5, V6, V7}, B7}.

pt_public_get_success_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RINT64(B1),
	{V3, B3} = ?RINT64(B2),
	{V4, B4} = ?RINT64(B3),
	{{pt_public_get_success_list, V1, V2, V3, V4}, B4}.

pt_public_common_rank(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RINT64(B1),
	{V3, B3} = ?RSTRING(B2),
	{V4, B4} = ?RUINT32(B3),
	{{pt_public_common_rank, V1, V2, V3, V4}, B4}.

pt_public_copy_times(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RINT64(B4),
	{{pt_public_copy_times, V1, V2, V3, V4, V5}, B5}.

pt_public_item_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{{pt_public_item_list, V1, V2, V3}, B3}.

pt_public_relife_task_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{{pt_public_relife_task_info, V1, V2, V3}, B3}.

pt_public_activity_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{{pt_public_activity_info, V1, V2, V3}, B3}.

pt_public_recycle_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_public_recycle_list, V1, V2}, B2}.

pt_public_pet_list(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{{pt_public_pet_list, V1, V2, V3}, B3}.

pt_public_gem_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{{pt_public_gem_list, V1, V2, V3}, B3}.

pt_public_usr_buy_cell_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_public_usr_buy_cell_info, V1, V2}, B2}.

pt_public_cell_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RLIST(B1, pt_public_item_list),
	{{pt_public_cell_info, V1, V2}, B2}.

pt_public_store_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RLIST(B1, pt_public_cell_info),
	{{pt_public_store_info, V1, V2}, B2}.

pt_public_pet_coll_info(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_public_pet_coll_info, V1, V2}, B2}.

pt_public_pet_skill_books(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_public_pet_skill_books, V1, V2}, B2}.

pt_public_pet_info(B0) -> 
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
	{V13, B13} = ?RLIST(B12, pt_public_pet_skill_books),
	{{pt_public_pet_info, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13}, B13}.

pt_public_scene_trap(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RFLOAT(B4),
	{V6, B6} = ?RFLOAT(B5),
	{V7, B7} = ?RFLOAT(B6),
	{V8, B8} = ?RFLOAT(B7),
	{{pt_public_scene_trap, V1, V2, V3, V4, V5, V6, V7, V8}, B8}.

pt_public_scene_arrow(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RFLOAT(B4),
	{V6, B6} = ?RFLOAT(B5),
	{V7, B7} = ?RFLOAT(B6),
	{V8, B8} = ?RFLOAT(B7),
	{{pt_public_scene_arrow, V1, V2, V3, V4, V5, V6, V7, V8}, B8}.

pt_public_equip_id_state_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_public_equip_id_state_list, V1, V2}, B2}.

pt_public_equip_id_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{{pt_public_equip_id_list, V1}, B1}.

pt_public_usr_equip_list(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_public_usr_equip_list, V1, V2}, B2}.

pt_public_team_member_list(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RSTRING(B3),
	{V5, B5} = ?RUINT32(B4),
	{V6, B6} = ?RUINT32(B5),
	{V7, B7} = ?RUINT32(B6),
	{V8, B8} = ?RUINT32(B7),
	{{pt_public_team_member_list, V1, V2, V3, V4, V5, V6, V7, V8}, B8}.

pt_public_mastery_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_public_mastery_list, V1, V2}, B2}.

pt_public_scene_entourage(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RFLOAT(B4),
	{V6, B6} = ?RFLOAT(B5),
	{V7, B7} = ?RFLOAT(B6),
	{V8, B8} = ?RFLOAT(B7),
	{V9, B9} = ?RINT64(B8),
	{V10, B10} = ?RSTRING(B9),
	{V11, B11} = ?RUINT32(B10),
	{V12, B12} = ?RUINT32(B11),
	{V13, B13} = ?RUINT32(B12),
	{V14, B14} = ?RUINT32(B13),
	{V15, B15} = ?RUINT32(B14),
	{{pt_public_scene_entourage, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14, V15}, B15}.

pt_public_normal_skill_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RUINT32(B4),
	{V6, B6} = ?RUINT32(B5),
	{V7, B7} = ?RUINT32(B6),
	{V8, B8} = ?RUINT32(B7),
	{V9, B9} = ?RUINT32(B8),
	{{pt_public_normal_skill_list, V1, V2, V3, V4, V5, V6, V7, V8, V9}, B9}.

pt_public_entourage_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RLIST(B2, pt_public_skill_list),
	{V4, B4} = ?RLIST(B3, pt_public_property_list),
	{{pt_public_entourage_list, V1, V2, V3, V4}, B4}.

pt_public_property_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RINT32(B1),
	{{pt_public_property_list, V1, V2}, B2}.

pt_public_equip_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{{pt_public_equip_list, V1, V2, V3, V4}, B4}.

pt_public_skill_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{{pt_public_skill_list, V1}, B1}.

pt_public_lost_list(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RUINT32(B4),
	{{pt_public_lost_list, V1, V2, V3, V4, V5}, B5}.

pt_public_pickup_des(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{{pt_public_pickup_des, V1, V2, V3}, B3}.

pt_public_drop_des(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RINT64(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RFLOAT(B4),
	{V6, B6} = ?RFLOAT(B5),
	{V7, B7} = ?RFLOAT(B6),
	{{pt_public_drop_des, V1, V2, V3, V4, V5, V6, V7}, B7}.

pt_public_item_des(B0) -> 
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
	{V12, B12} = ?RLIST(B11, uint32),
	{{pt_public_item_des, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12}, B12}.

pt_public_property(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{{pt_public_property, V1, V2, V3}, B3}.

pt_public_skill_effect(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RUINT32(B4),
	{V6, B6} = ?RUINT32(B5),
	{V7, B7} = ?RUINT32(B6),
	{V8, B8} = ?RFLOAT(B7),
	{V9, B9} = ?RFLOAT(B8),
	{V10, B10} = ?RFLOAT(B9),
	{{pt_public_skill_effect, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10}, B10}.

pt_public_scene_item(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RFLOAT(B2),
	{V4, B4} = ?RFLOAT(B3),
	{V5, B5} = ?RFLOAT(B4),
	{V6, B6} = ?RFLOAT(B5),
	{V7, B7} = ?RUINT32(B6),
	{{pt_public_scene_item, V1, V2, V3, V4, V5, V6, V7}, B7}.

pt_public_scene_monster(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RFLOAT(B3),
	{V5, B5} = ?RFLOAT(B4),
	{V6, B6} = ?RFLOAT(B5),
	{V7, B7} = ?RFLOAT(B6),
	{V8, B8} = ?RUINT32(B7),
	{V9, B9} = ?RUINT32(B8),
	{V10, B10} = ?RUINT32(B9),
	{V11, B11} = ?RUINT32(B10),
	{V12, B12} = ?RUINT32(B11),
	{V13, B13} = ?RINT64(B12),
	{V14, B14} = ?RINT64(B13),
	{V15, B15} = ?RSTRING(B14),
	{V16, B16} = ?RFLOAT(B15),
	{{pt_public_scene_monster, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14, V15, V16}, B16}.

pt_public_scene_ply(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{V2, B2} = ?RSTRING(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RFLOAT(B4),
	{V6, B6} = ?RFLOAT(B5),
	{V7, B7} = ?RFLOAT(B6),
	{V8, B8} = ?RFLOAT(B7),
	{V9, B9} = ?RUINT32(B8),
	{V10, B10} = ?RUINT32(B9),
	{V11, B11} = ?RUINT32(B10),
	{V12, B12} = ?RUINT32(B11),
	{V13, B13} = ?RUINT32(B12),
	{V14, B14} = ?RUINT32(B13),
	{V15, B15} = ?RINT64(B14),
	{V16, B16} = ?RUINT32(B15),
	{V17, B17} = ?RUINT32(B16),
	{V18, B18} = ?RUINT32(B17),
	{V19, B19} = ?RBYTE(B18),
	{V20, B20} = ?RUINT32(B19),
	{V21, B21} = ?RUINT32(B20),
	{V22, B22} = ?RUINT32(B21),
	{V23, B23} = ?RUINT32(B22),
	{V24, B24} = ?RUINT32(B23),
	{V25, B25} = ?RUINT32(B24),
	{V26, B26} = ?RSTRING(B25),
	{V27, B27} = ?RUINT32(B26),
	{V28, B28} = ?RUINT32(B27),
	{V29, B29} = ?RUINT32(B28),
	{V30, B30} = ?RUINT32(B29),
	{V31, B31} = ?RUINT32(B30),
	{{pt_public_scene_ply, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14, V15, V16, V17, V18, V19, V20, V21, V22, V23, V24, V25, V26, V27, V28, V29, V30, V31}, B31}.

pt_public_create_usr_info(B0) -> 
	{V1, B1} = ?RINT64(B0),
	{V2, B2} = ?RSTRING(B1),
	{V3, B3} = ?RUINT32(B2),
	{V4, B4} = ?RUINT32(B3),
	{V5, B5} = ?RUINT32(B4),
	{V6, B6} = ?RLIST(B5, pt_public_equip_id_list),
	{V7, B7} = ?RUINT32(B6),
	{V8, B8} = ?RUINT32(B7),
	{V9, B9} = ?RUINT32(B8),
	{V10, B10} = ?RUINT32(B9),
	{V11, B11} = ?RUINT32(B10),
	{V12, B12} = ?RUINT32(B11),
	{{pt_public_create_usr_info, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12}, B12}.

pt_public_point3(B0) -> 
	{V1, B1} = ?RFLOAT(B0),
	{V2, B2} = ?RFLOAT(B1),
	{V3, B3} = ?RFLOAT(B2),
	{{pt_public_point3, V1, V2, V3}, B3}.

pt_public_normal_info(B0) -> 
	{V1, B1} = ?RINT32(B0),
	{V2, B2} = ?RSTRING(B1),
	{{pt_public_normal_info, V1, V2}, B2}.

pt_public_attr_info(B0) -> 
	{V1, B1} = ?RUINT16(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_public_attr_info, V1, V2}, B2}.

pt_public_two_int(B0) -> 
	{V1, B1} = ?RUINT32(B0),
	{V2, B2} = ?RUINT32(B1),
	{{pt_public_two_int, V1, V2}, B2}.

