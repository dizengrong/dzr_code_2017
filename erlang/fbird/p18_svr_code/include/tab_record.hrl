
%% disc_type:表的保存类型，为disc_copies|disc_only_copies
%% 其中disc_only_copies这种启动不会把表加载到内存里，启动快些，对于很少使用的表应该使用这种类型
%% 注意：ordered_set类的表不支持disc_only_copies的
-record (tab_config, {
	tab_name,	  		 		%% 表名，即record名称
	type = set,	  		 		%% 表类型：set|bag|ordered_set,默认为set
	disc_type = disc_copies,	%% disc_copies|disc_only_copies
	attrs,		  		 		%% record字段列表
	indexs = [],  		 		%% 索引字段列表
	merge_reserve = true, 		%% 合服时是否保留该表数据：true|false
	is_role_tab = false 		%% 是否为玩家个人表且是以玩家uid为主键的表，如果是，则在合服删号时，会自动连带删除该表玩家的数据
}).


%% 服务器信息表
-record (t_server_info, {
	id = 1,  		%% 这个表只有一条数据，所以id固定为1
	version, 		%% 服务器版本号
	update_time		%% version写入时间
}).


%% 唯一id表
-record (t_uid, {
	key,		%% 唯一id类型
	curr_id		%% 当前id
}).

%% 临时唯一id表
-record (t_temp_uid, {
	key,		%% 唯一id类型
	curr_id		%% 当前id
}).


%% 存储临时数据的表
-record (t_temp_data, {
	key,
	val
}).

%% 用于简单数据存放用的键-值表(todo:暂时这个表合服时是不保存的，如果特殊需要再另行处理)
-record (t_key_val, {
	key,
	val
}).

%% gm运营活动
-record(t_gm_activity, {
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

%% gm运营活动玩家数据表
-record (t_gm_act_usr, {
	uid       = 0,
	act_data = []		%% 活动数据[#gm_act_usr{}]
}).

%% 需要保存的buff表
-record (t_save_buff, {
	uid   = 0,
	buffs = [] 		%% [#save_buff{}]
}).

%% 玩家锻造数据
-record(t_compose,{
	uid 				= 0,
	free_time 			= 0,
	refresh_time   		= 0,
	refresh_num    		= 0,
	item1          		= 0,
	item2          		= 0,
	item3          		= 0,
	item1_proprety 		= [],
	item2_proprety 		= [],
	item3_proprety 		= [],
	item1_type			= 0,
	item2_type			= 0,
	item3_type			= 0,
	item1_price			= 0,
	item2_price			= 0,
	item3_price			= 0
}).

%% 玩家杂项表
% datas:
% 	guide_codes 引导数据

-record(t_usr_misc,{
	uid                = 0,
	story_step         = 0,
	story_reward       = [],
	task_step_n        = {0, 0},
	task_step_h        = {0, 0},
	fetched_cdkey      = [],
	sign               = {0, 1, 1}, 	%% {签到状态, 签到循环数, 已签到数}
	time_reward        = {0, 1, []}, 	%% {开始计时时间, 第几次计时, [已领取的id]}
	last_called_hero   = [], 	%% 上次召唤的英雄
	grow_fund          = {false, 0, 0},  %% 成长基金：{有没有购买, 购买了第几阶段，奖励领取到哪个id了}
	relife_time		   = 0,	%%转生次数
	relife_task		   = [],	%%转生任务
	fast_time		   = 0,	%%扫荡关卡次数
	task_step 		   = 0,	%%功能预告
	medicine		   = [], %%药剂状态
	meeting_times	   = 0,	%%参加议会的次数
	buy_farm_times	   = 0,	%%家园农场快速收货次数
	fast_artifact	   = {0, 0},	%%神器快速充能
	first_recharge 	   = [],	%%首充记录
	random_task		   = {false,0,{0,0},{0,0},0,0},	%% 随机任务：{有没有任务，任务ID，任务1，任务2，结束时间，任务识别ID}
	revive 			   = 0,	%%复活次数
	barrier_reward1    = [],	%% 闯关奖励领取记录
	barrier_reward2    = [],	%% 闯关奖励领取记录(有人数限制的)
	compensation_award = [], %%记录补偿奖励
	guard_entourage	   = [],  %%竞技场防守阵容
	world_level_reward = 0,  %%是否领取过世界等级奖励
	guild_blessing     = 1,   %%公会祝福阶段
	praise_reward 	   = {0, 0, 0}, %% 好评奖励 {是否已经领过，通关计数器, 每日定时计数器}
	vip_daily_reward   = 0,   %%VIP每日礼包领取
	gift_package	   = {0, 0, 0, 0},  %%随机礼包{ID，状态，结束时间，计数}
	pass_copy	   	   = 0,  %%是否领取闯关奖励
	hero_illustration  = [],  %% 英雄图鉴
	datas 			   = #{}  %% 字典数据
}).

%% 战斗属性表：这个是为了处理获取其他玩家的属性而建的一个“属性缓存表”
-record (t_entourage_attr, {
	eid = 0,
	battle_attr = #battle_property{}
}).

%% 资源表
-record (t_resource, {
	uid       = 0,
	resources = [] 		%% 资源列表：[{资源类型, 拥有数量}]
}).


%% 玩家定时器更新表
-record (t_role_timer, {
	uid    = 0,
	timers = []  %% [{{Mod, Fun}, BeginTime, Interval, Arg}] 到期回调:Mod:Fun(DoTimes, Arg)
}).

%% 玩家技能表
-record (t_skill, {
	uid       = 0, 
	skills    = []  %% [{skill_id, skill_lev}]
}).

%% 玩家宠物表
-record (t_pet, {
	uid 			= 0,
	pet_id 			= 0,
	follow_pet_id 	= 0,
	lv 				= 0,
	exp 			= 0
}).

%% 宝石表
-record (t_gem, {
	uid      = 0, 	
	gem_list = []  	%% [{gem_id, gem_lev, gem_exp}]
}).

%% 商店个人表
-record (t_role_store, {
	uid       = 0, 
	stores    = [],		%% 每个商店刷出来的cell:{StoreID, [{Cell, ItemId, ItemNum}]}
	buy_times = [] 		%% {Cell, BuyTimes}
}).

% %% 商店全局表
% -record (t_server_store, {
% 	cell_id   = 0,   %% 商品cellid
% 	buy_times = 0 	 %% 已购买的次数
% }).

-record(t_mail,{
	id 			= 0,  %% 标识
	uid         = 0,  %% 角色id
	state       = 0,  %% 邮件状:0未读,1已读附件未领,2已读已领
	s_time 		= 0,  %% 发送时间
	d_time      = 0,  %% 删除时间
	reciver_id  = 0,  %% 接收人id
	config_id 	= 0,  %% 配置
	reciver_name= [], %% 收件人姓名
	title       = [], %% 邮件标题
	content     = [], %% 邮件正文
	item_info   = []  %% 物品信息[{Type,Num,binding}]
}).

-record(t_mail_public,{
	id 			= 0,
	s_time  	= 0, 		% 发送时间
	d_time  	= 0, 		% 删除时间
	title 		= [],		% 标题
	content 	= [],		% 正文
	item_info 	= [],		% 物品信息
	config_id 	= 0,		% gm命令中使用了 
	channel 	= 0,		% 渠道?
	start_reg 	= 0,		% 注册时间
	end_reg  	= 0 		% 结束时间
}).

-record(t_mail_read_public,{
	id 					= 0,
	pid 				= 0,	% 玩家id
	mail_read_time		= 0		%玩家上一次读取邮件的时间
}).

%% 坐骑表
-record (t_usr_rides, {
	uid        = 0,
	type       = 0,
	exp        = 0,
	ride_state = 0,
	currskin   = 0,
	skins      = [],	%% [{ID, Lv}]
	eq1        = 0,
	eq2        = 0,
	eq3        = 0,
	eq4        = 0,
	eq5        = 0,
	eq6        = 0
}).

%% 称号表
-record(t_title,{
	uid    = 0,
	used   = 0,  %% 当前穿戴的
	titles = []  %% [{Type, Lv, EndTime}]
}).

%% 时装表
-record (t_clothes, {
	uid     = 0,
	clothes = []	%% [#model_clothes{}]
}).

%% 物品使用次数记录表
-record (t_use_item_times,{
	uid   = 0,
	times = []
}).

%% 主关卡进度表
-record (t_main_scene, {
	uid   	    = 0,
	scene_lev   = 0
}).

%% 神器表
-record (t_shenqi, {
	uid            = 0,
	stage_used_id  = 0, 	%% 主关卡里使用的神器物品id
	illustration   = []    %% 神器图鉴
}).

% %% 英雄表
% -record(t_entourage_info, {
% 	uid            = 0,
% 	battle_list    = [], %% {etype,pos}
% 	entourage_list = []  %% -record(entourage, {id,type,lev,exp,star,equip_list=[{item_id,pos}]}).
% }).

%% 首充表
-record(t_recharge_extra_rewards, {
	uid               = 0,
	times             = 0,
	recharge_rewards  = 0,
	charge_money_list = []
}).

%% 竞技场表
-record(t_arena_info, {
	uid            = 0,
	times 		   = 0,
	arena_record   = []
}).

%% 挂机表
-record(t_time_reward, {
	uid        = 0,
	start_time = 0
}).

%% 抽奖表
-record(t_draw, {
	uid         = 0,
	energy      = 0,
	draw_record = [] %% {draw_type, next_free_time}
}).

%% 转盘表
-record(t_role_turntable, {
	uid           = 0,
	energy        = 0,
	free_time     = 0,
	normal_record = [] %% {position, item_type, item_num, times}
}).

%% 转盘表
-record(t_role_draw_record, {
	uid    = 0,
	record = [] %% {type, [{[{ItemType, ItemNum, _ItemStar}], Time}]}
}).

%% 公会日志
-record(t_guild_event_log, {
	guild_id = 0,
	log_queue  %% 日志队列:#{uid = 0, be_uid = 0, type = 0, amount = 0, time = 0, date = 0}
}).

%% 玩家英雄阵容
-record(t_entourage_list, {
	uid = 0,
	entourage_list = []  %% 阵容:{type, entourage_list = [{eid, type, pos}], shenqi_id}
}).

%% 活动副本表
% maps数据:#{
% 	activated_copy_id, 激活到哪个副本id了
% 	win_copy_id, 该类型通关到哪个副本id了
% 	left_times, 剩余次数
% 	buy_times, 已购买的次数
% 	max_kill_num,
% 	best_rewards
% }
-record(t_activity_copy, {
	uid   = 0,
	datas = [] 	%% [{副本类型, maps数据}]
}).

%% 公会科技表
-record (t_guild_technology, {
	uid              = 0,
	used_reset_times = 0,  %% 已使用的重置次数
	datas            = [] 	%% [{科技id, 等级}]
}).

%% 玩家英雄远征表
%% 事件状态:未完成, 已完成，只有当主事件和子事件都完成了才能进入下一个pos点
% maps数据:#{
% 	saved_hp_list, 保存的上阵英雄的血量(比例)
% 	history_sub_events, 历史获得的子事件列表
% 	walked_pos_list, 走过的路点
% 	pos, 当前在哪个位置
% 	main_event, 位置上的主事件
% 	main_event_data, 主事件数据
% 	main_event_state, 主事件状态
% 	sub_event, 主事件之后的子事件
% 	sub_event_data, 子事件数据
% 	sub_event_state, 子事件状态
% }
-record (t_role_expedition, {
	uid = 0,
	datas = #{}  %% maps数据
}).

-record (t_role_relation, {
	uid = 0,
	friend_list = [],  %% 保存好友uid
	friend_apply = []  %% 保存申请uid
}).

-record (t_last_ranklist, {
	uid = 0,
	ranklist = []  %% {竞技场类型， 排名}
}).

-record (t_offline_reward, {
	uid      = 0,
	step     = 0, %% 奖励阶段
	end_time = 0  %% 领取时间
}).

%% 主线任务表
-record (t_main_task, {
	uid     = 0,
	task_id = 0,
	chapter = 0,
	count   = 0,
	status  = 0
}).

%% 每日任务表
-record (t_daily_task, {
	uid    = 0,
	tasks  = [], %% {id, count, status}
	status = 0
}).

% -record(task_detail,{task_id=0,step=0,state=0,conditions=[],accept_time=0,task_sort=0}). %% conditions = [{type, num}]