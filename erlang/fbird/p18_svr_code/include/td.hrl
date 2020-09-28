%%db
-record(account,{id,name,password,create_time=0,create_way=0,create_ip=0,last_login_time=0,last_login_ip=0,state=0,state_start_time=0,state_length=0,channel=0,device_token=""}).
-record(usr,{id,acc_id = 0,name="",prof=0,lev = 1,camp=1,hp= 1,mp= 1,save_pos ="",create_time=0,last_login_time=0,last_logout_time=0,all_online_time=0,state=0,state_start_time=0,state_length=0,fatigue=0,
			 exp=0,vip_exp=0,vip_lev=0,activate_id=0,fighting=0,drop_drums_time=0,login_day="",quit_guild_time=0,military_lev=1,guide_code=0,achieves=0,achieve_lev=0,achieve_count=0,
			 achieve_exp=0,paragon_level=0,recommend_przie=0,last_fatigue_time = 0,glory_sword_lev=0,last_stamina_time=0,
			 time_reward=0,
			 is_boss_attacked=0, 	%% 当前所在关卡的boss是否已挑战过了
			 entourage_bag_lev=0,
			 artifact_bag_lev=0,
			 is_first_register=true
}).

-record(item,{
	id         = 0,
	uid        = 0,
	type       = 0,
	num        = 0,
	bind       = 0,
	get_way    = 0,
	get_time   = 0,
	lev        = 0,
	color      = 0,
	break      = 0,  %% 如果是英雄的话就对应英雄的品级
	star       = 0,
	owner      = 0,  %% 装备被穿戴次数，不能大于num
	equip_list = []  %% 装备列表，仅对英雄类型有效
}).
-record(lost_item,{id,pid,lost_item_id=0,lev=0,recover_lev=0}).
-record(task,{id,pid=0,task_id=0,step=0,state=0,condition1=0,condition2=0,condition3=0,accept_time=0,task_sort=0}).

%% 英雄表先不改动 ==========================================
-record(combat_entourage,{id,uid=0,type=0,status=0,revive_time=0}).

-record(entourage_rune,{id,uid=0,type=0,lev=0,step=0}).
%% 英雄表先不改动 ==========================================

-record(mastery,{id,pid,mastery_id,lev}).

%% 公会表先不改动 ==========================================
-record(guild, {id=0, name="", notice = "",camp=0,level=0, exp=0,resource = 0,total_honor=0,state=0,dissolve_state=0,banner=1}).
-record(guild_member, {id, uid=0, guild_id=0, perm=0,level=0, name="",req_end_time = 0, join_time = 0,usr_integral =0,last_login_time=0,contribution=0,prof=0,contribution_time=0,contribution_day=0,total_honor_day=0,total_honor_num=0,salary_get_state=0}).
-record(guild_building, {id=0, uid=0,guild_id=0, type=0, level=0, exp=0}).
-record(guild_scene, {id=0, guild_id=0, scene_id=0,scene_open=0,progress=0,reset_time=0,rewards_time=0,ml_type="",ml_hp=""}).
-record(guild_damage, {id=0,damage=0,copy_id=0,guild_id=0,uid=0,name="",prof=0,lev=0,vip_lev=0,kill_fetched = [],damage_fetched = []}).
-record(guild_fall_for,{id=0, guild_id=0,scene_id=0, uid=0,item_id=0,time=0}).
-record(guild_items_list,{id=0, guild_id=0,scene_id=0, item_id=0,item_num=0}).
%% 公会表先不改动 ==========================================

-record(revive,{id=0,pid=0,revive_times=0,time=0}).

-record(thumb_up,{id=0,uid=0,friend=0,time=0}).
-record(by_thumb_up,{id,pid=0,by_thumb_up_time=0}).
-record(refresh,{id=0,uid=0,entourage=0}).

-record(usr_rides_skin, {id=0, uid=0,skin_id=0,skin_state=0,uidskinid=0,cur_starLev=1,cur_att=0,cur_def=0,cur_hp=0,start_time=0}).
-record(rewards,{id=0,uid=0,sort=0,rewards=0}).
-record(chapter,{id=0,uid=0,fetched_id=0}).
-record(draw,{id=0,uid=0,draw_sort=0,draw_num=0,time=0,draw_one_time=0,draw_ten_time=0,day_draw=0}).
-record(usr_operate_time,{id=0,uid=0,camp_vote_time=0,worship_time=0,military_time=0}).
-record(opening_server_time,{id,time=0,day_time=0,camp_time=0,arena_daily_time=0,arena_week_time=0,national_war_daily_time=0,guild_ranklist_time=0,draw_astrict=2}).
-record(online_rewards,{id=0,uid=0,online_rewards="",day=0,online_time=0}).
-record(scene_count,{id=0,uid=0,sceneid=0,join_time=0,join_count=0}).
-record(gm_operation, {id=0, uid=0,shutup_start_time=0,shutup_time=0,sethonor_start_time=0,sethonor_time=0,aid=0}).
-record(model_clothes, {id=0, uid=0,clothes_type=0,lev=0,activity_state=0}).
-record(usr_achieve, {id=0, uid=0,sort=0,num=0,type=0}).
-record(paragon_level,{id=0,uid=0,prop_type="",point_num=""}).
-record(entourage_fetter,{id=0,uid=0,etype=0,fetter_eid=0,fetter_id = 0,fetter_lev=0}). 
-record(entourage_soul_link,{id=0,uid=0,soul_link_slot = "",soul_link_type=""}).
-record(recharge_record, {id,uid=0,order_id="",money=0,platform=0,config_id=0,time=0}).
-record(recharge_off_record, {id,uid=0,order_id="",money=0,platform=0,config_id=0,time=0}).
-record(recharge_error_record, {id,uid=0,order_id="",money=0,platform=0,config_id=0,time=0}).
-record(usr_charge_active,{id=0,uid=0,time=0,sort=0,schedule=0,last_reward=0}).
-record(off_count,{id=0,uid=0,count_sort=0,count_data=0,count_num=0,del_task_id=0,quit_guild_time=0,guild_task=0}).
-record(camp_skill,{id=0,uid=0,skill_id=0,skill1=0,skill_lev1=0,skill2=0,skill_lev2=0,skill3=0,skill_lev3=0}).
-record(daily_max_honor,{id=0,uid=0,today_honor=0,add_honor_time=0}).
-record(save_buff,{id,uid=0,type=0,power=0,mix_lev=0,start=0,lenth=0,effect_time=0,buff_adder=0,skill=0,skill_lev=0}).
-record(camp_balance,{id,camp_two=0,camp_thr=0}).

-record(global_arena_record, {
	id 				= 0,
	uid 			= 0,
	times 			= 0,
	buy_times 		= 0,
	honor 			= 0, %%赛季荣誉值
	daily_honor 	= 0, %%每日荣誉值
	fetched 		= [], %%每日任务领取
	rank 			= 0, %%段位
	season_win_time = 0, %%赛季胜场
	worship_time	= 0, %%膜拜次数
	worship_log		= [], %%膜拜记录
	be_worship_time = 0, %%被膜拜次数
	daily_log 		= [] %%每日战报
}).

-record(open_system,{id,uid=0,openid="",opendaytime=""}).
-record(buy_coin,{id,uid=0,total_times=0,times=0,day_time=0,free_buy_coin=0,free_re_time=0}).
-record(npc_task,{id,uid=0,task_id=0,day_time=0}).
-record(guild_task,{id=0,uid=0,star=0,guild_num=0,reset_num=0,guild_time=0,draw_rewards=0,draw_rewards_time=0}).
-record(royal_box,{id=0,uid=0,box_id=0,final_time=0,state=0}).
-record(entourage_star_rewards,{id=0,uid=0,rewards_id=0,rewards_state=0}).
-record(equip_welfare_rewards,{id=0,uid=0,rewards_id=0,rewards_state=0}).
-record(usr_gs_rewards,{id=0,uid=0,rewards_id=0}).
-record(usr_items_buffer,{id=0,uid=0,item=0,num=0,way=0}).
-record(wechat_share,{id=0,uid=0,day_time=0,share_time=0,share_get_time=0}).
-record(exchange,{id=0,exchangeNo=0,startTime=0,endTime=0,createTime=0,status=0,type = 0,exchange_str=""}).
-record(loginact,{id=0,loginactNo=0,startTime=0,endTime=0,createTime=0,status=0,diamond=0,loginact_str=""}).
-record(passed_copy,{id=0,uid=0,copy=0}).
-record(guild_impeach_president,{id=0,guild_id=0,uid=0,decision=0,time=0}).
-record(hide_boss_info,{id=0,uid=0,config_id=0}).
-record(open_srv_act_stat,{id=0,state=0,seven_state=0}).
-record(open_srv_act_reward_stat,{id=0,uid=0,camp_stat=0,lev_stat=0,ent_stat=0,fig_stat=0}).
-record(seven_day_target,{id=0,uid=0,day_id=0,activity_id=0,activity_num=0,state=0}).
-record(seven_day_rewards,{id=0,uid=0,day_id=0}).
-record(entourage_rent,{id,uid=0,type=0,lev=0,star=0,fighting=0,time=0}).
-record(entourage_exped,{id,uid=0,stat=0,config=0,time=0,type1=0,owner1=0,type2=0,owner2=0,type3=0,owner3=0}).
-record(refulsh_expedition_times,{id,uid=0,count=0,time=0,reflush_num=0}).
-record(climb_tower,{id,uid=0,curr_tower=0,max_tower=0,count=0,time=0,reward_str="",create_boss_num=0}).
-record(guild_red_packet,{id,uid=0,guild_id=0,sum_red_packet_num = 0,time=0,surplus_itemType=0,surplus_itemNum=0,surplus_num=0}).
-record(guild_red_packet_record,{id,uid=0,guild_id=0,red_packet=0}).
-record(guild_payoff,{id,guildid=0,time=0}).
-record(guild_team_copy,{id,guild_id=0,scene_id=0,wavenumber=0,time=0}). 
-record(dismiss_guild,{id,uid=0,day_time=0}).
-record(password_red,{id=0, uid=0, name="", diamond=0, num=0, max_num=0, context="", time=0}).
-record(recv_password_red,{id=0,red_id=0,recv_uid=0}).
-record(entourage_mastery,{id=0,uid=0,entourage_id=0,mastery_id=0,mastery_lev=0}).
-record(royal_box_astrict,{id=0,uid=0,day_time=0,time=0}).
-record(operation_activity,{id=0,activity_id=0,start_time=0,end_time=0,one_diamond =0,ten_diamond =0,state=0}).
-record(treasure_activity,{id=0,activity_id=0,activity_time=0,item_id=0,item_type=0,item_num=0,probability=0,state=0}).
-record(treasure_activity_time,{id=0,uid=0,time=0}). 
-record(all_people_time,{id=0,uid=0,all_people_id=0}).
-record(usr_head_info,{id=0,uid=0,state=0,headid=0,lev=0}).
-record(usr_head_suit,{id=0,uid=0,suit_id=0,lev=0}).
%% 活跃度
-record (liveness, {
	id           = 0,
	uid          = 0,
	done_list    = [],
	fetched_list = []
}).

-record(consume_record,{id=0,uid=0,consume=0}).
-record(recharge_activity,{id=0,uid=0,recharge=0}).

-record(copy_time_rewards,{id=0,uid=0,rewards_id="",time=0,num=0}).

-record(quick_fight,{id=0,uid =0,forever_add_time=0,fight_times =0,last_refresh_time =0}).
-record(friend_gift,{id,uid=0,from_uid=0,flag=0,time=0}).
-record(setting_pick_item,{id,uid=0,setting_white=0,setting_green=0,setting_blue=0}).
-record(guild_boss_copy,{id=0,uid=0,challenge_num=0,last_refresh_time=0,inspire_buy_times=0,buy_times=0}).
-record(guild_boss_progress,{
	id 		 	= 0,
	guild_id 	= 0,
	copy_id 	= 0,
	scene_id 	= 0,
	wave 		= 0,
	progress 	= "[]",
	kill_time 	= 0
}).
-record(guild_boss_hp,{id=0,guild_id=0,boss_list=[]}).
-record(guild_boss_hp_refresh,{id,last_refresh_time=0}).

-record(guild_trophy,{id,uid =0,get_damage_rewardid="",get_kill_rewardid =""}).

-record(usr_legendary_level, {
	id             = 0,
	uid       	   = 0,
	lev     	   = 0,	%% 等级
	exp    		   = 0, %% 经验
	buy_times      = [], %% 购买次数{类型，次数}（每日重置）
	prop_point     = []  %% 传奇等级属性点{类型，等级}
}).

-record(usr_maze, {
	id             = 0,
	uid       	   = 0,
	status     	   = 0,	%% 状态
	has_settled    = 0, %% 是否结算（每日重置）
	power    	   = 0, %% 体力值
	buy_times      = 0,	%% 体力值购买次数（每日重置）
	lucky    	   = 0,	%% 幸运值（结算重置）
	bagdge 	 	   = 0,	%% 背包等级（结算重置）
	inspare	 	   = 0,	%% 鼓舞等级（结算重置）
	re_time 	   = 0,	%% 体力恢复开始时间
	step           = 0, %% 幸运值领取奖励阶段（结算重置）
	monster_record = [], %% 怪物记录（结算重置）
	rewards 	   = [], %% 获得奖励（结算时给予）
	records        = []  %% 防守记录（结算重置）
}).

-record(usr_sailing, {
	id             = 0,
	uid       	   = 0,
	status     	   = 0,	%% 状态（结算重置）
	sailing_time   = 0, %% 航行次数（每日重置）
	buy_times      = 0,	%% 航行购买次数（每日重置）
	has_be_plunder = 0, %% 是否被抢劫（结算重置）
	guard_time     = 0, %% 助战次数（每日重置）
	is_guard       = 0, %% 是否助战（结算重置）
	has_be_guard   = 0, %% 助战玩家uid（结算重置，每次航行只有一个，要求本公会成员）
	end_time   	   = 0,	%% 结束时间（结算重置）
	type    	   = 0,	%% 船只类型（结算重置）
	inspire    	   = 0,	%% 鼓舞等级（结算重置）
	plunder_time   = 0,	%% 掠夺次数（每日重置）
	records        = [], %% 航海记录（结算重置）
	plunder_list   = []  %% 掠夺列表（每日重置）
}).

-record(usr_god_costume, {
	id                = 0,
	uid       	      = 0,
	position_num      = 0,	%% 孔位数量
	stage_lev  	      = 0,	%% 阶段属性等级
	illustration 	  = [], %% 已激活图鉴
	illustration_suit = []  %% 已激活图鉴套装
}).

% -record(usr_entourage_challenge, {
% 	id             		= 0,
% 	uid       	   		= 0,
% 	times 		   		= 0, 	%% 挑战次数
% 	buy_times 			= 0, 	%% 购买次数（每日刷新）
% 	recover_begin_time  = 0, 	%% 自然回复开始时间
% 	step     	   		= []	%% 挑战记录 {章节，难度，关卡}
% }).

-record(guild_sailing, {
	id             = 0,
	guild_id       = 0,
	sign           = [], %% 掠夺标记（结算重置）
	point     	   = 0	 %% 积分（结算重置）
}).

-record(gm_activity, {
	id           = 0,
	act_id       = 0, 	%% 后台传送来的活动唯一标示id
	act_name     = "", 	%% 活动名称
	type         = 0, 	%% 活动类型
	start_time   = 0, 
	end_time     = 0,
	close_time	 = 0,
	picture      = "", 	%% 活动图片
	icon      	 = "", 	%% 活动图标
	act_des      = "", 	%% 活动描述
	setting      = [],	%% 一些设置数据
	reward_datas = [] 	%% 奖励数据
}).

-record (gm_activity_usr, {
	id         = 0, 
	uid        = 0,
	type       = 0,  	%% 活动类型
	act_data   = [], 	%% 活动数据
	act_time   = 0, 	%% 活动数据产生时间（用在排序需要）
	fetch_data = []		%% 领取数据
}).

-record(guild_stone,{id,uid =0,guild=0,req_stone =0,get_num=0}).

%% 保存最近的聊天信息
-record (recent_chat, {
	id          = 0,
	channel     = 0, 		%% 聊天频道:世界聊天就是世界频道id，公会聊天就是一个元组{公会频道id, 公会id}
	sender      = 0, 		%% 发送者
	server_id   = 0, 	%% 发送者所在游戏服ID
	server_name = "",  	%% 发送者所在游戏服名称
	msg         = [], 	%% 消息
	time        = 0 		%% 消息产生时间
}).


-record(home_building, {id,uid=0,type=0,lev=0,status=0,upgrade_end_time=0,rest_end_time=0,data=""}).
-record(home_building_worker, {id,building_id=0,sort=0,finish_time=0,ratio_add=0,type=0,lev=0,owner_id=0,owner_name="",fight_score=0}).

%% 存放全局key_val数据的表
%% 保存的时候回转化为字符串存入mysql数据库的
%% 使用对应的接口会自动转为成原来的数据格式的
-record (key_val, {
	id = 0,
	key_data,
	val_data
}).

%% 乱斗boss表
-record (melleboss_state, {
	id                = 0,
	boss_id           = 0,
	next_revive_time  = 0  %% 如果死亡了下次复活时间
}).

-record (usr_melleboss, {
	id        = 0,
	uid       = 0,
	times 	  = 0, %% 剩余领取次数
	buy_times = 0  %% 购买次数
}).

%% 世界boss表
-record (usr_worldboss, {
	id                 = 0,
	uid                = 0,
	left_times         = 0,  %% 剩余挑战次数
	recover_begin_time = 0   %% 回复开始时间
}).

-record (acc_misc, {
	id                 = 0,
	aid                = 0,
	download_reward    = 0	%% 下载奖励领取状态
}).

%% 天赋表
-record (talent, {
	id     = 0,
	uid    = 0,
	awaken = 0, 	%% 觉醒等级
	skills = [] 	%% 天赋技能列表:[{技能id, 等级}]
}).

%% 元素珠表
-record (pearl, {
	id   = 0,
	uid  = 0,
	ele1 = 0,
	ele2 = 0,
	ele3 = 0,
	ele4 = 0,
	ele5 = 0
}).

%% 挖矿表
-record (mining, {
	id                = 0,
	uid               = 0,
	end_time          = 0,  %% 挖矿结束时间，如果没有在挖矿，则这个值必须为0，以此来标识是否在挖矿中
	protect_over_time = 0,  %% 挖矿保护结束时间
	gain              = 0,  %% 今日挖矿获得的数量
	grab              = 0,  %% 今日抢夺获得的数量
	graped_times      = 0,  %% 今天已抢夺次数
	grap_buy_times    = 0,  %% 今天购买的抢夺次数
	inspire           = 0,  %% 购买的鼓舞
	exchange_times    = "[]",  %% 今日已兑换次数[{Id, Times}]
	defend_records    = "[]"  %% 抢夺防守记录
}).

-record (worldboss_state, {
	id               = 0,
	boss_id          = 0,
	next_revive_time = 0,   	%% 如果死亡了下次复活时间
	alive_length_list = [],   	%% [存活时长]
	killed_times     = 0, 		%% 被击杀的次数
	init_hp          = 0,       %% 初始血量（可以用来判断是否配置改了，改了的话就重置）
	max_hp           = 0        %% 上一次出生的血量
}).

-record(system_activity, {
	id           = 0,
	act_type     = 0, 	%% 活动类型
	act_status   = 0 	%% 活动状态
}).

-record(system_activity_usr, {
	id           = 0,
	uid          = 0,
	act_type     = 0, 	%% 活动类型
	act_data     = "[]"	%% 活动数据
}).

%% 迁移中的库
-record(usr_titles,{id=0,uid=0,type=0,used=0,days=0,begintime=0,state=0,uidtid=0}).
-record(usr_rides, {id=0, uid=0,type=0,exp=0,ride_state=0,currskin=0,skins="",eq1=0,eq2=0,eq3=0,eq4=0,eq5=0,eq6=0}).

-record(ranklist_arena,{key={0, 0},uid=0,lev=0,name="",fighting=0,rank=0,vip_lev=0}).