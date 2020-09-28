-module (test_mnesia).
-include("common.hrl").
-compile(export_all).
%% 数据库中每个表插入10000条记录，在Windows下的测试结果为：
%% 		占用内存：大概500m
%% 		占用磁盘：大概90m
%% 		启动游戏服，大概将近一分钟(我的电脑为i5处理器)


insert_test_datas() -> 
	?INFO("Begin insert test datas"),
	List = mod_tab_config:all_disc_tabs(),
	[insert_test_datas2(Tab) || #tab_config{tab_name = Tab} <- List],
	?INFO("Finished insert test datas"),
	ok.


insert_test_datas2(item) -> 
	[db_api:dirty_write(setelement(2, get_test_datas(item), Id)) || Id<- lists:seq(1, 10000)];
insert_test_datas2(Tab) -> 
	AllNewDiscTabs = mod_tab_config:new_all_disc_tabs(),
	IsNew = lists:keymember(Tab, #tab_config.tab_name, AllNewDiscTabs),
	case get_test_datas(Tab) of
		undefined -> skip;
		DefaultRec ->
			Fun = fun(Id) ->
				case IsNew of
					true -> 
						db_api:dirty_write(setelement(2, DefaultRec, Id));
					_ -> 
						db:insert(setelement(2, DefaultRec, Id))
				end
			end,
			[Fun(Id) || Id<- lists:seq(1, 10000)],
			util:sleep(100)
	end,
	ok.

% get_test_datas(t_role_attr) ->        #t_role_attr{};
% get_test_datas(t_stage) ->            #t_stage{};
% get_test_datas(t_usr_promotion) ->    #t_usr_promotion{};
% get_test_datas(t_role_worldboss) ->   #t_role_worldboss{};
% get_test_datas(t_card) ->             #t_card{};
% get_test_datas(t_use_item_times) ->   #t_use_item_times{};
% get_test_datas(t_title) ->            #t_title{};
% get_test_datas(t_lost_item) ->        #t_lost_item{};
% get_test_datas(t_godchallenge) ->     #t_godchallenge{};
% get_test_datas(t_field_battle) ->     #t_field_battle{};
% get_test_datas(t_magic_stone) ->      #t_magic_stone{};
% get_test_datas(t_soul_equip) ->       #t_soul_equip{};
% get_test_datas(t_auction_shop) ->     #t_auction_shop{};
% get_test_datas(t_auction_item) ->     #t_auction_item{};
get_test_datas(t_mail) ->             #t_mail{};
get_test_datas(t_mail_public) ->      #t_mail_public{};
get_test_datas(t_mail_read_public) -> #t_mail_read_public{};
% get_test_datas(t_rank_worship) ->     #t_rank_worship{};
get_test_datas(t_role_timer) ->       #t_role_timer{};
get_test_datas(t_key_val) ->          #t_key_val{};
get_test_datas(t_skill) -> #t_skill{};
get_test_datas(t_usr_misc) -> #t_usr_misc{};
% get_test_datas(t_online_rewards) -> #t_online_rewards{};
% get_test_datas(t_task) -> #t_task{};
% get_test_datas(t_sign) -> #t_sign{};
% get_test_datas(t_liveness) -> #t_liveness{};
% get_test_datas(t_usr_rides) -> #t_usr_rides{};
% get_test_datas(t_passed_copy) -> #t_passed_copy{};
% get_test_datas(t_chapter) -> #t_chapter{};
% get_test_datas(t_wing) -> #t_wing{};
% get_test_datas(t_magic_ring) -> #t_magic_ring{};
% get_test_datas(t_magic_info) -> #t_magic_info{};
% get_test_datas(t_trials) -> #t_trials{};
% get_test_datas(t_buy_coin) -> #t_buy_coin{};
% get_test_datas(t_climb_tower) -> #t_climb_tower{};

get_test_datas(item) -> #item{};
% get_test_datas(account) -> #account{};
% get_test_datas(usr) -> #usr{};
% get_test_datas(mastery) -> #mastery{};
% get_test_datas(pet) -> #pet{};
% get_test_datas(pet_book) -> #pet_book{};
% get_test_datas(gem) -> #gem{};
% get_test_datas(relation) -> #relation{};
% get_test_datas(guild) -> #guild{};
% get_test_datas(guild_member) -> #guild_member{};
% get_test_datas(guild_building) -> #guild_building{};
% get_test_datas(guild_scene) -> #guild_scene{};
% get_test_datas(guild_damage) -> #guild_damage{};
% get_test_datas(guild_fall_for) -> #guild_fall_for{};
% get_test_datas(guild_items_list) -> #guild_items_list{};
% get_test_datas(copy_times) -> #copy_times{};
% get_test_datas(thumb_up) -> #thumb_up{};
% get_test_datas(by_thumb_up) -> #by_thumb_up{};
% get_test_datas(usr_operate_time) -> #usr_operate_time{};
% get_test_datas(gm_operation) -> #gm_operation{};
% get_test_datas(t_achieve) -> #t_achieve{};
% get_test_datas(paragon_level) -> #paragon_level{};
% get_test_datas(unlock_atlas) -> #unlock_atlas{};
% get_test_datas(vip_rewards) -> #vip_rewards{};
% get_test_datas(recharge_extra_rewards) -> #recharge_extra_rewards{};
% get_test_datas(usr_charge_active) -> #usr_charge_active{};
% get_test_datas(recharge_record) -> #recharge_record{};
% get_test_datas(recharge_off_record) -> #recharge_off_record{};
% get_test_datas(recharge_error_record) -> #recharge_error_record{};
% get_test_datas(save_buff) -> #save_buff{};
% get_test_datas(system_retrieve_ex) -> #system_retrieve_ex{};
% get_test_datas(royal_box) -> #royal_box{};
% get_test_datas(gamble_record) -> #gamble_record{};
% get_test_datas(guild_vote_time) -> #guild_vote_time{};
% get_test_datas(inscription) -> #inscription{};
% get_test_datas(guild_red_packet_recv) -> #guild_red_packet_recv{};
% get_test_datas(guild_team_copy) -> #guild_team_copy{};
% get_test_datas(dismiss_guild) -> #dismiss_guild{};
% get_test_datas(guild_team_copy_record) -> #guild_team_copy_record{};
% get_test_datas(royal_box_astrict) -> #royal_box_astrict{};
% get_test_datas(consume_record) -> #consume_record{};
% get_test_datas(recharge_activity) -> #recharge_activity{};
% get_test_datas(ranklist_recharge_rewards_data) -> #ranklist_recharge_rewards_data{};
% get_test_datas(relation_friend) -> #relation_friend{};
% get_test_datas(relation_enemy) -> #relation_enemy{};
% get_test_datas(relation_blacklist) -> #relation_blacklist{};
% get_test_datas(mystery_store) -> #mystery_store{};
% get_test_datas(toplist_fighting) -> #toplist_fighting{};
% get_test_datas(toplist_lev) -> #toplist_lev{};
% get_test_datas(toplist_exploit) -> #toplist_exploit{};
% get_test_datas(toplist_stage) -> #toplist_stage{};
% get_test_datas(toplist_ride) -> #toplist_ride{};
% get_test_datas(toplist_pet) -> #toplist_pet{};
% get_test_datas(toplist_entoureage) -> #toplist_entoureage{};
% get_test_datas(toplist_achieve) -> #toplist_achieve{};
% get_test_datas(toplist_dayrecharge) -> #toplist_dayrecharge{};
% get_test_datas(toplist_gem) -> #toplist_gem{};
% get_test_datas(toplist_recharge) -> #toplist_recharge{};
% get_test_datas(toplist_consume) -> #toplist_consume{};
% get_test_datas(toplist_wing) -> #toplist_wing{};
% get_test_datas(toplist_arena) -> #toplist_arena{};
% get_test_datas(thumb_up_info) -> #thumb_up_info{};
% get_test_datas(toplist_tower) -> #toplist_tower{};
% get_test_datas(guild_storehouse) -> #guild_storehouse{};
% get_test_datas(vip_invest) -> #vip_invest{};
% get_test_datas(open_svr_recharge) -> #open_svr_recharge{};
% get_test_datas(everyday_recharge) -> #everyday_recharge{};
% get_test_datas(tiger_machine) -> #tiger_machine{};
% get_test_datas(storehouse) -> #storehouse{};
% get_test_datas(arena_record) -> #arena_record{};
% get_test_datas(arena_time_num) -> #arena_time_num{};
% get_test_datas(arena_off_reward) -> #arena_off_reward{};
% get_test_datas(arena_buy_num) -> #arena_buy_num{};
% get_test_datas(recharge_multiple) -> #recharge_multiple{};
get_test_datas(_) -> undefined.
