%% @doc 协议action code定义，原则上只做这个用途，不添加其他宏定义了
%% P18 新action code都定义在这个里面

%% for dzr
%% =============================== 11000 - 19999 =============================== 
-define (ACTION_REQ_HERO_LV_UP, 11000). 	%% 请求英雄等级升级
-define (ACTION_REQ_HERO_GRADE_UP, 11001). 	%% 请求英雄升品
-define (ACTION_REQ_HERO_STAR_UP, 11002). 	%% 请求英雄升星
-define (ACTION_REQ_HERO_ATTR, 11003). 	%% 请求英雄属性

-define (ACTION_REQ_RECOMMEND_GUILDS, 12010). 	%% 请求推荐公会列表
-define (ACTION_REQ_CHANGE_BANNER, 12011). 	%% 请求修改公会旗帜
-define (ACTION_REQ_CHANGE_GUILD_NOTICE, 12013). 	%% 请求修改公会旗帜
-define (ACTION_REQ_VIEW_GUILD_MEMBER_INFO, 12014). 	%% 请求查看公会成员详情

-define (ACTION_REQ_LOAD_FUWEN, 12100). 	%% 请求穿戴符文装备
-define (ACTION_REQ_UNLOAD_FUWEN, 12101). 	%% 请求卸下符文装备
-define (ACTION_REQ_STRENGTHEN_FUWEN, 12102). 	%% 请求强化符文装备
-define (ACTION_REQ_UNLOAD_ALL_FUWEN, 12103). 	%% 请求卸下所有符文装备

-define (ACTION_REQ_ACTIVE_COPY, 12110). 	%% 请求激活副本
-define (ACTION_REQ_SET_COPY_ON_BATTLE, 12111). 	%% 请求设置副本上阵阵容

-define (ACTION_REQ_EXPEDITION_INFO, 12120). 		%% 请求英雄远征信息
-define (ACTION_REQ_EXPEDITION_DO, 12121). 			%% 请求做事件任务
-define (ACTION_REQ_EXPEDITION_GIVE_UP, 12122). 	%% 请求放弃
-define (ACTION_REQ_EXPEDITION_UNLOCK_POS, 12123). 	%% 请求解锁下一个据点
-define (ACTION_REQ_SET_EXPEDITION_ON_BATTLE, 12124). 	%% 请求设置英雄远征上阵阵容
-define (ACTION_REQ_ENTER_EXPEDITION, 12125). 	%% 请求进入英雄远征场景 

-define (ACTION_REQ_SET_GUIDE, 12130). 	%% 请求设置引导 
-define (ACTION_REQ_ITEM_DETAIL_INFO, 12131). 	%% 请求指定物品的详细信息 

-define (ACTION_REQ_GUILD_TEC_INFO, 12140). 	%% 请求公会科技信息 
-define (ACTION_REQ_GUILD_TEC_UP_LV, 12141). 	%% 请求公会科技升级 
-define (ACTION_REQ_GUILD_TEC_RESET, 12142). 	%% 请求公会科技重置 

%% =============================== 10000 - 10999 =============================== 

%% for psy
%% =============================== 20000 - 29999 =============================== 
-define(ACTION_REQ_ENTER_MAIN              ,20000). %%请求进入主关卡
-define(ACTION_REQ_MAIN_MOVE               ,20001). %%请求主关卡移动到下一点
-define(ACTION_REQ_MAIN_ATTACK             ,20002). %%请求主关卡开始战斗
-define(ACTION_REQ_MAIN_RUN_AWAY           ,20003). %%请求主关卡逃跑

-define(ACTION_REQ_ARNEA_INFO              ,20004). %%请求竞技场信息
-define(ACTION_REQ_ENTER_ARENA             ,20005). %%请求进入竞技场

-define(ACTION_MODULE_DATAS                ,20006). %%前端登陆请求各模块初始化数据

-define(ACTION_REQ_USE_ITEM                ,20007). %%请求使用物品
-define(ACTION_REQ_EQUIPMENT               ,20008). %%请求装上装备
-define(ACTION_REQ_UNLOAD_EQUIPMENT        ,20009). %%请求卸下装备

-define(ACTION_REQ_CHANGE_NAME        	   ,20010). %%请求更换名字

-define(ACTION_REQ_SET_GUARD_LIST      	   ,20011). %%请求设置竞技场防守阵容
-define(ACTION_REQ_ARENA_CHALLENGE_INFO	   ,20012). %%请求竞技场匹配对手
-define(ACTION_REQ_ARENA_SINGLE_INFO	   ,20013). %%请求竞技场详细信息

-define(ACTION_REQ_EQUIPMENT_SYNTHWSIS	   ,20014). %%请求装备合成
-define(ACTION_REQ_ONCE_UNLOAD_EQUIPMENT   ,20015). %%请求一键卸下装备

-define(ACTION_REQ_TIME_REEWARD_INFO       ,20016). %%请求挂机奖励数据
-define(ACTION_REQ_FETCH_TIME_REEWARD      ,20017). %%请求领取挂机奖励

-define(ACTION_REQ_ENTOURAGE_ILLUSTRATION  ,20018). %%请求英雄图鉴
-define(ACTION_REQ_SHENQI_ILLUSTRATION     ,20019). %%请求神器图鉴

-define(ACTION_REQ_ARENA_REVENGE           ,20020). %%请求竞技场复仇

-define(ACTION_REQ_SUMMON_DRAW             ,20021). %%请求英雄种族召唤
-define(ACTION_REQ_ENTOURAGE_SUBSTITUTION  ,20022). %%请求英雄置换
-define(ACTION_REQ_SUBSTITUTION_RESULT     ,20023). %%请求英雄置换确认

-define(ACTION_REQ_DRAW                    ,20024). %%请求抽奖
-define(ACTION_REQ_ENERGY_DRAW             ,20025). %%请求能量抽奖

-define(ACTION_REQ_STORE_INFO              ,20026). %%请求商店数据
-define(ACTION_REQ_BUY_CELL                ,20027). %%请求购买商品
-define(ACTION_REQ_REFRESH_STORE           ,20028). %%请求刷新商店

-define(ACTION_REQ_NORMAL_TURNTABLE_INFO   ,20029). %%请求低级转盘数据
-define(ACTION_REQ_DRAW_NORMAL_TURNTABLE   ,20030). %%请求抽取低级转盘
-define(ACTION_REQ_DRAW_HIGH_TURNTABLE     ,20031). %%请求抽取高级转盘
-define(ACTION_REQ_REFRESH_TURNTABLE       ,20032). %%请求刷新转盘
-define(ACTION_REQ_DRAW_RECORD             ,20033). %%请求抽奖记录

-define(ACTION_REQ_FRIEND_INFO             ,20034). %%请求好友信息
-define(ACTION_REQ_FRIEND_APPLY            ,20035). %%申请好友
-define(ACTION_REQ_PASS_FRIEND_APPLY       ,20036). %%通过申请好友
-define(ACTION_REQ_DELETE_FRIEND_APPLY     ,20037). %%删除申请好友
-define(ACTION_REQ_DELETE_FRIEND           ,20038). %%删除好友
-define(ACTION_REQ_ONE_DELETE_FRIEND_APPLY ,20039). %%一键删除好友申请
-define(ACTION_REQ_RECOMMEND_LIST          ,20040). %%请求推荐好友
-define(ACTION_REQ_SEARCH_FRIEND           ,20041). %%请求搜索好友
-define(ACTION_REQ_FRIEND_TOP              ,20042). %%请求好友置顶
-define(ACTION_REQ_OTHER_USR_INFO          ,20043). %%请求其他玩家信息

-define(ACTION_REQ_ITEM_BREAK              ,20044). %%请求分解物品

-define(ACTION_REQ_FRIEND_ATTACK           ,20045). %%请求好友切磋

-define(ACTION_REQ_OFFLINE_REWARD          ,20046). %%请求离线奖励
-define(ACTION_REQ_OFFLINE_INFO            ,20047). %%请求离线奖励信息

-define(ACTION_REQ_MAIN_TASK_REWARD        ,20048). %%请求主线任务奖励
-define(ACTION_REQ_CHAPTER_REWARD          ,20049). %%请求主线章节奖励

-define(ACTION_REQ_DAILY_TASK_REWARD       ,20050). %%请求每日任务奖励
-define(ACTION_REQ_DAILY_ALL_REWARD        ,20051). %%请求每日任务总奖励

-define(ACTION_REQ_SIGN                    ,20052). %%请求签到
%% =============================== 20000 - 29999 =============================== 