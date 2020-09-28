%% @doc 活动相关

-define(GM_ACTIVITY_ONE,1).%%宝藏活动
-define(GM_ACTIVITY_TWO,2).%%超值赠礼
-define(GM_ACTIVITY_THREE,3).%%充值排行
-define(GM_ACTIVITY_FOUR,4).%%大转盘
-define(GM_ACTIVITY_FIVE,5).%%单笔充值
-define(GM_ACTIVITY_SEX,6).%%登录领奖
-define(GM_ACTIVITY_SEVEN,7).%%节日兑换
-define(GM_ACTIVITY_EIGHT,8).%%连续充值
-define(GM_ACTIVITY_NINE,9).%%特殊掉落
-define(GM_ACTIVITY_TEN,10).%%消费排行
-define(GM_ACTIVITY_ELEVEN,11).%%重复充值

%% 以下是用更新的方式实现的gm活动(模块:fun_gm_activiyt_ex)
-define(GM_ACTIVITY_ACC_RECHARGE       		,12).	%% 累积充值
-define(GM_ACTIVITY_ACC_COST       	   		,13).	%% 累积消费 
-define(GM_ACTIVITY_DOUBLE_REWARD  	   		,14).	%% 双倍活动 
-define(GM_ACTIVITY_DISCOUNT      	   		,15).	%% 打折活动 
-define(GM_ACTIVITY_WEEK_TASK          		,16).	%% 每周任务
-define(GM_ACTIVITY_SALE               		,17).	%% 限时秒杀
-define(GM_ACTIVITY_EXCHANGE           		,18).	%% 道具兑换
-define(GM_ACTIVITY_DROP               		,19).	%% 掉落
-define(GM_ACTIVITY_DAILY_ACC_RECHARGE 		,20).	%% 每日累积充值
-define(GM_ACTIVITY_DAILY_ACC_COST     		,21).	%% 每日累积消费 
-define(GM_ACTIVITY_TREASURE           		,22).	%% 地精宝藏 
-define(GM_ACTIVITY_PACKAGE            		,23).	%% 充值礼包 
-define(GM_ACTIVITY_RESET_RECHARGE    		,24).	%% 重置首充
-define(GM_ACTIVITY_LIMIT_SUMMON       		,25).	%% 限时推荐召唤
-define(GM_ACTIVITY_RANK_LV            		,26).	%% 等级排行榜活动
-define(GM_ACTIVITY_CONTINUOUS_RECHARGE 	,27).	%% 连续充值活动
-define(GM_ACTIVITY_LIMIT_ACHIEVEMENT  		,28).	%% 限时成就活动
-define(GM_ACTIVITY_GLOBAL_RECHARGE    		,29).	%% 跨服充值
-define(GM_ACTIVITY_GLOBAL_CONSUME     		,30).	%% 跨服消耗
-define(GM_ACTIVITY_GLOBAL_RECHARGEJIFEN    ,31).	%% 跨服充值积分
-define(GM_ACTIVITY_GLOBAL_CONSUMEJIFEN     ,32).	%% 跨服消耗积分
-define(GM_ACTIVITY_DOUBLE_RECHARGE_TEMP    ,33).	%% 限时充值双倍
-define(GM_ACTIVITY_RECHARGE_POINT		    ,34).	%% 充值建设点
-define(GM_ACTIVITY_LITERATURE_COLLECTION   ,35).	%% 文字收集
-define(GM_ACTIVITY_LOTTERY_CAROUSEL 	    ,36).	%% 抽奖转盘
-define(GM_ACTIVITY_RETURN_INVESTMENT 	    ,37).	%% 投资回报
-define(GM_ACTIVITY_MYSTERY_GIFT 	        ,38).	%% 神秘礼包
-define(GM_ACTIVITY_SINGLE_RECHARGE	        ,39).	%% 单笔充值
-define(GM_ACTIVITY_ACC_LOGIN	 	        ,40).	%% 累计登陆
-define(GM_ACTIVITY_POINT_PACKAGE 	        ,41).	%% 积分礼包
-define(GM_ACTIVITY_DIAMOND_PACKAGE	        ,42).	%% 钻石礼包
-define(GM_ACTIVITY_RMB_PACKAGE	        	,43).	%% 人民币礼包
-define(GM_ACTIVITY_TURNTANLE	        	,44).	%% 大转盘

%% 在fun_gm_activity_ex模块实现的新的gm活动
-define(ALL_NEW_GM_ACT, [
	?GM_ACTIVITY_ACC_RECHARGE,
	?GM_ACTIVITY_ACC_COST,
	?GM_ACTIVITY_DOUBLE_REWARD,
	?GM_ACTIVITY_DISCOUNT,
	?GM_ACTIVITY_WEEK_TASK,
	?GM_ACTIVITY_SALE,
	?GM_ACTIVITY_EXCHANGE,
	?GM_ACTIVITY_DROP,
	?GM_ACTIVITY_DAILY_ACC_RECHARGE,
	?GM_ACTIVITY_DAILY_ACC_COST,
	?GM_ACTIVITY_TREASURE,
	?GM_ACTIVITY_PACKAGE,
	?GM_ACTIVITY_RESET_RECHARGE,
	?GM_ACTIVITY_LIMIT_SUMMON,
	?GM_ACTIVITY_RANK_LV,
	?GM_ACTIVITY_CONTINUOUS_RECHARGE,
	?GM_ACTIVITY_LIMIT_ACHIEVEMENT,
	?GM_ACTIVITY_GLOBAL_RECHARGE,
	?GM_ACTIVITY_GLOBAL_CONSUME,
	?GM_ACTIVITY_GLOBAL_RECHARGEJIFEN,
	?GM_ACTIVITY_GLOBAL_CONSUMEJIFEN,
	?GM_ACTIVITY_DOUBLE_RECHARGE_TEMP,
	?GM_ACTIVITY_RECHARGE_POINT,
	?GM_ACTIVITY_LITERATURE_COLLECTION,
	?GM_ACTIVITY_LOTTERY_CAROUSEL,
	?GM_ACTIVITY_RETURN_INVESTMENT,
	?GM_ACTIVITY_MYSTERY_GIFT,
	?GM_ACTIVITY_SINGLE_RECHARGE,
	?GM_ACTIVITY_ACC_LOGIN,
	?GM_ACTIVITY_POINT_PACKAGE,
	?GM_ACTIVITY_DIAMOND_PACKAGE,
	?GM_ACTIVITY_RMB_PACKAGE,
	?GM_ACTIVITY_TURNTANLE
]).

%% 需要每天刷新重置数据的活动type
-define(ALL_DAILY_REFRESH_GM_ACT_TYPE, [
	?GM_ACTIVITY_DAILY_ACC_RECHARGE,
	?GM_ACTIVITY_DAILY_ACC_COST
]).

%% 需要每天刷新重置部分数据的活动type
-define(ALL_DAILY_PART_REFRESH_GM_ACT_TYPE, [
	?GM_ACTIVITY_CONTINUOUS_RECHARGE,
	?GM_ACTIVITY_LIMIT_ACHIEVEMENT,
	?GM_ACTIVITY_POINT_PACKAGE,
	?GM_ACTIVITY_DIAMOND_PACKAGE,
	?GM_ACTIVITY_RMB_PACKAGE,
	?GM_ACTIVITY_TURNTANLE
]).

-define(DAILY_REFRESH_GLOBAL_GM_ACT_TYPE, [
	?GM_ACTIVITY_RETURN_INVESTMENT
]).

%% 双倍活动类型
-define(DOUBLE_ACT_ARENA   , 1). 		%% 竞技场
-define(DOUBLE_ACT_DUNGEONS, 2). 		%% 地下城
-define(DOUBLE_ACT_TEAM_COPY , 3). 		%% 组队副本

%% 折扣活动的打折类型
-define(DISCOUNT_ACT_COMPOSE        , 1). 		%% 装备打造
-define(DISCOUNT_ACT_STORE_MISC     , 2). 		%% 杂货商店
-define(DISCOUNT_ACT_CARD           , 3). 		%% 抽卡
-define(DISCOUNT_ACT_STORE_HERO     , 4). 		%% 英雄商店
-define(DISCOUNT_ACT_STORE_FRIEND   , 5). 		%% 友情商店


%% gm每周任务活动的类型定义
-define(WEEK_TASK_LOGIN       , 1).		 %% 登录天数奖励
-define(WEEK_TASK_COST_COIN   , 2).		 %% 消耗钻石数量
-define(WEEK_TASK_AREAN       , 3).		 %% 消耗竞技场次数
-define(WEEK_TASK_MELTING     , 4).		 %% 熔炼装备数量
-define(WEEK_TASK_DUNGEON     , 5).		 %% 通关地下城次数
-define(WEEK_TASK_CARD        , 6).		 %% 完成抽卡次数
-define(WEEK_TASK_COMPOSE     , 7).		 %% 打造装备数量
-define(WEEK_TASK_QUICK_FIGHT , 8).		 %% 完成快速战斗次数
-define(WEEK_TASK_KILL_MONSTER, 9).		 %% 击杀小怪数量
-define(WEEK_TASK_COST_ITEM   , 10).	 %% 消耗道具（填ID及数量）
-define(WEEK_TASK_GAIN_COPPER , 11).	 %% 获得游戏金币数量
-define(WEEK_TASK_COST_COPPER , 12).	 %% 消耗游戏金币数量
-define(WEEK_TASK_UP_SKILL_LV , 13).	 %% 升级角色技能等级


%% gm特殊掉落活动的掉落类型
-define(DROP_ACT_BARRIER     , 1).		 %% 通关关卡
-define(DROP_ACT_DUNGEON     , 2).		 %% 通关地下城
-define(DROP_ACT_KILL_MONSTER, 3).		 %% 击杀小怪


%% gm限时成就的成就类型
-define(LIMIT_ACHIEVEMENT_QUICK_FIGHT	,1).		 %% 快速战斗
-define(LIMIT_ACHIEVEMENT_HERO_SUMMON	,2).		 %% 英雄抽卡
-define(LIMIT_ACHIEVEMENT_BUY_TIMES		,3).		 %% 购买地下城次数
-define(LIMIT_ACHIEVEMENT_RUNE_SUMMON	,4).		 %% 符文抽卡


%% 后台（自营）活动
-define(SYSTEM_LIMIT_BOSS 		, 1).	%%限时boss
-define(SYSTEM_DOUBLE_REWARD 	, 2).	%%双倍奖励
-define(SYSTEM_UNCHARTER_WATER 	, 3).	%%大航海
-define(SYSTEM_MELLEBOSS 		, 4).	%%乱斗boss
-define(SYSTEM_ARENA	 		, 5).	%%竞技场

%% 在fun_system_activity模块调用
-define(ALL_SYSTEM_ACT, [
	?SYSTEM_LIMIT_BOSS,
	?SYSTEM_DOUBLE_REWARD,
	?SYSTEM_UNCHARTER_WATER,
	?SYSTEM_MELLEBOSS,
	?SYSTEM_ARENA
]).