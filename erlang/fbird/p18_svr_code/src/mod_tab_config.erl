%% @doc mnesia数据库表的配置
-module (mod_tab_config).
-include ("common.hrl").
-compile([export_all]).


%% 新的方式的表必须放这里
%% 注意添加表时要确定表合服时该如何处理
new_all_disc_tabs() ->
	[
		#tab_config{tab_name = t_server_info, attrs = record_info(fields, t_server_info), merge_reserve = false},
		#tab_config{tab_name = t_uid, attrs = record_info(fields, t_uid), merge_reserve = false},
		#tab_config{tab_name = t_key_val, attrs = record_info(fields, t_key_val), merge_reserve = false},

		%% ======================= disc_only_copies类型表 ======================
		#tab_config{tab_name = t_pet, disc_type = disc_only_copies, attrs = record_info(fields, t_pet), is_role_tab = true},
		#tab_config{tab_name = t_save_buff, disc_type = disc_only_copies, attrs = record_info(fields, t_save_buff), is_role_tab = true},
		#tab_config{tab_name = t_usr_misc, disc_type = disc_only_copies, attrs = record_info(fields, t_usr_misc), is_role_tab = true},
		#tab_config{tab_name = t_resource, disc_type = disc_only_copies, attrs = record_info(fields, t_resource), is_role_tab = true},
		#tab_config{tab_name = t_use_item_times, disc_type = disc_only_copies, attrs = record_info(fields, t_use_item_times), is_role_tab = true},
		#tab_config{tab_name = t_main_scene, disc_type = disc_only_copies, attrs = record_info(fields, t_main_scene), is_role_tab = true},
		#tab_config{tab_name = t_gem, disc_type = disc_only_copies, attrs = record_info(fields, t_gem), is_role_tab = true},
		#tab_config{tab_name = t_skill, disc_type = disc_only_copies, attrs = record_info(fields, t_skill), is_role_tab = true},
		#tab_config{tab_name = t_role_store, disc_type = disc_only_copies, attrs = record_info(fields, t_role_store), is_role_tab = true},
		#tab_config{tab_name = t_clothes, disc_type = disc_only_copies, attrs = record_info(fields, t_clothes), is_role_tab = true},
		#tab_config{tab_name = t_role_timer, disc_type = disc_only_copies, attrs = record_info(fields, t_role_timer), is_role_tab = true},
		#tab_config{tab_name = t_recharge_extra_rewards, disc_type = disc_only_copies, attrs = record_info(fields, t_recharge_extra_rewards), is_role_tab = true},
		#tab_config{tab_name = t_time_reward, disc_type = disc_only_copies, attrs = record_info(fields, t_time_reward), is_role_tab = true},
		#tab_config{tab_name = t_draw, disc_type = disc_only_copies, attrs = record_info(fields, t_draw), is_role_tab = true},
		#tab_config{tab_name = t_role_turntable, disc_type = disc_only_copies, attrs = record_info(fields, t_role_turntable), is_role_tab = true},
		#tab_config{tab_name = t_role_draw_record, disc_type = disc_only_copies, attrs = record_info(fields, t_role_draw_record), is_role_tab = true},
		#tab_config{tab_name = t_activity_copy, disc_type = disc_only_copies, attrs = record_info(fields, t_activity_copy), is_role_tab = true},
		#tab_config{tab_name = t_entourage_list, disc_type = disc_only_copies, attrs = record_info(fields, t_entourage_list), is_role_tab = true},
		#tab_config{tab_name = t_role_expedition, disc_type = disc_only_copies, attrs = record_info(fields, t_role_expedition), is_role_tab = true, merge_reserve = false},
		#tab_config{tab_name = t_offline_reward, disc_type = disc_only_copies, attrs = record_info(fields, t_offline_reward), is_role_tab = true},
		#tab_config{tab_name = t_main_task, disc_type = disc_only_copies, attrs = record_info(fields, t_main_task), is_role_tab = true},
		#tab_config{tab_name = t_daily_task, disc_type = disc_only_copies, attrs = record_info(fields, t_daily_task), is_role_tab = true},
		#tab_config{tab_name = t_guild_technology, disc_type = disc_only_copies, attrs = record_info(fields, t_guild_technology), is_role_tab = true},


		%% ========================== disc_copies类型表 ========================
		#tab_config{tab_name = t_arena_info, attrs = record_info(fields, t_arena_info), is_role_tab = true},
		#tab_config{tab_name = t_gm_act_usr, attrs = record_info(fields, t_gm_act_usr), merge_reserve = false, is_role_tab = true},
		#tab_config{tab_name = t_gm_activity, attrs = record_info(fields, t_gm_activity), indexs= [type], merge_reserve = false},
		#tab_config{tab_name = t_mail, attrs = record_info(fields, t_mail), indexs = [reciver_id]},
		#tab_config{tab_name = t_mail_public, attrs = record_info(fields, t_mail_public)},
		#tab_config{tab_name = t_mail_read_public, attrs = record_info(fields, t_mail_read_public),indexs = [pid]},
		#tab_config{tab_name = t_entourage_attr, attrs = record_info(fields, t_entourage_attr), merge_reserve = false},
		#tab_config{tab_name = t_shenqi, attrs = record_info(fields, t_shenqi), is_role_tab = true},
		#tab_config{tab_name = t_guild_event_log, attrs = record_info(fields, t_guild_event_log), is_role_tab = true},
		#tab_config{tab_name = t_role_relation, attrs = record_info(fields, t_role_relation), is_role_tab = true},
		#tab_config{tab_name = t_last_ranklist, attrs = record_info(fields, t_last_ranklist), is_role_tab = true},

		%% 以下为排行榜，其表类型为:ordered_set
		#tab_config{tab_name = ranklist_arena, type = ordered_set, attrs = record_info(fields, ranklist_arena), indexs= [uid, rank], merge_reserve = false}
	].


%% 跨服节点的数据库(跨服节点只会初始化这里的表，其他表不会创建)
cross_node_disc_tabs() ->
	[
		#tab_config{tab_name = t_server_info, attrs = record_info(fields, t_server_info), merge_reserve = false},
		#tab_config{tab_name = t_uid, attrs = record_info(fields, t_uid), merge_reserve = false}
	].

%% 跨服节点内存表
cross_node_ram_tabs() ->
	[
		#tab_config{tab_name = t_temp_uid, attrs = record_info(fields, t_temp_uid)},
		#tab_config{tab_name = t_temp_data, attrs = record_info(fields, t_temp_data)}
	].


all_disc_tabs() ->
	new_all_disc_tabs() ++
	[
		%% ======================= disc_only_copies类型表 =======================
		#tab_config{tab_name = item, disc_type = disc_only_copies, attrs = record_info(fields, item), indexs= [uid]},
	
		%% ======================= disc_copies类型表 =======================
		#tab_config{tab_name = account, attrs = record_info(fields, account), indexs= [name]},
		#tab_config{tab_name = usr, attrs = record_info(fields, usr), indexs= [acc_id,name]},
		#tab_config{tab_name = guild, attrs = record_info(fields, guild), indexs= [name]},
		#tab_config{tab_name = guild_member, attrs = record_info(fields, guild_member), indexs= [uid, guild_id]},
		#tab_config{tab_name = opening_server_time, attrs = record_info(fields, opening_server_time)},
		#tab_config{tab_name = gm_operation, attrs = record_info(fields, gm_operation), indexs= [uid,aid]},
		#tab_config{tab_name = usr_charge_active, attrs = record_info(fields, usr_charge_active), indexs= [uid]},
		#tab_config{tab_name = recharge_record, attrs = record_info(fields, recharge_record), indexs= [uid]},
		#tab_config{tab_name = recharge_off_record, attrs = record_info(fields, recharge_off_record), indexs= [uid]},
		#tab_config{tab_name = recharge_error_record, attrs = record_info(fields, recharge_error_record), indexs= [uid]},
		#tab_config{tab_name = guild_red_packet, attrs = record_info(fields, guild_red_packet), indexs= [uid,guild_id]},
		#tab_config{tab_name = guild_team_copy, attrs = record_info(fields, guild_team_copy), indexs= [guild_id]},
		#tab_config{tab_name = dismiss_guild, attrs = record_info(fields, dismiss_guild), indexs= [uid]},
		#tab_config{tab_name = operation_activity, attrs = record_info(fields, operation_activity), indexs= [activity_id], merge_reserve = false}
	].


all_ram_tabs() ->
	[
		#tab_config{tab_name = t_temp_uid, attrs = record_info(fields, t_temp_uid)},
		#tab_config{tab_name = t_temp_data, attrs = record_info(fields, t_temp_data)},
		#tab_config{tab_name = apply_for_guild, attrs = record_info(fields, apply_for_guild), indexs = [uid,guild_id]},
		#tab_config{tab_name = guild_team, attrs = record_info(fields, guild_team), indexs = [guild_id]},
		#tab_config{tab_name = ply, attrs = record_info(fields, ply), indexs = [aid,name,sid]},
		#tab_config{tab_name = guild_copy_team, attrs = record_info(fields, guild_copy_team), indexs = [guild_id]}
	].