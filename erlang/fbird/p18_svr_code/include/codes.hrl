% resources

% channel

% code
-define(TRUE, true).
-define(FALSE, false).
-define(CONTINUE, continue).
-define(UNDEFINED, undefined).
-define(OK, ok).
-define(SKIP, skip).
-define(RETURN, return).
-define(ERROR, error).

-define(ARROW_SKILL, "ARROW").%%弹道
-define(TRAP_SKILL, "TRAP").%%陷阱
-define(ITSELF_SKILL, "SKILL").%%本身
-define(BUFF_SKILL, "BUFF").%%buff
-define(ALL_SKILL, "ALL").%%所有

% system
-define(MAX_PLAYER_LEV,90).

-define(DIFF_SECONDS_1970_1900, 2208988800).
-define(DIFF_SECONDS_0000_1900, 62167219200).
-define(ONE_DAY_SECONDS,        86400).
-define(ONE_HOUR_SECONDS,		3600).
-define(ONE_MIN_SECONDS,		60).
-define(LEAVE_FIGHT_TIME,5).

%db
-define(DB, sd_mysql_conn).
-define(DB_S, sd_mysql_conn_s).

%%flash843
%%-define(FL_POLICY_REQ, <<"<polic">>).
-define(FL_POLICY_REQ, <<"<policy-file-request/>\0">>).
-define(FL_POLICY_FILE, <<"<cross-domain-policy><allow-access-from domain='*' to-ports='*' /></cross-domain-policy>">>).
-define(FL_TGW_REQ, "tgw_l7_forward\r\nHost: vc3.app100693997.twsapp.com:8000\r\n\r\n").

%%tcp_server
%% backlog参数在linux下可以通过：cat /proc/sys/net/core/somaxconn来查看
%% 还有cat /proc/sys/net/ipv4/tcp_max_syn_backlog也可以看 是通过这两个来控制的
%% 所有监听端口的backlog Send-Q大小可以通过ss -lt来查看
%% 修改：vim /etc/sysctl.conf 增加：net.core.somaxconn = 8192  
-define(TCP_OPTIONS, [binary, inet, {packet, 0}, {active, false}, {backlog, 1024}, {reuseaddr, true}, {nodelay, true}, {delay_send, true}, {send_timeout, 5000}, {keepalive, true}, {exit_on_close, true}]).
-define(TCP_CONNECT_OPTIONS, [binary, {packet, 0}, {ip, {0,0,0,0}}, {active, false}, {reuseaddr, true}, {nodelay, true}, {delay_send, true}, {send_timeout, 5000}, {keepalive, true}, {exit_on_close, true}]).
%% 要想在同一个端口上支持IPV4和IPV6，需要在服务器执行下面的命令：
% echo 1 > /proc/sys/net/ipv6/bindv6only
-define(TCP_IPV6_OPTIONS, [binary, inet6, {packet, 0}, {active, false}, {backlog, 1024}, {reuseaddr, true}, {nodelay, true}, {delay_send, true}, {send_timeout, 5000}, {keepalive, true}, {exit_on_close, true}]).
-define(HEADER_LENGTH, 4).
-define(MINI_BODY, 6). %proto_id(2bytes) + seq(4bytes)
-define(MAX_BODY, 1024 * 1024).


-define(MAX_USR,1).

-define(MAX_ENTOURAGE,5).

%% 服务器实体sort
-define(SPIRIT_SORT_NULL,no).
-define(SPIRIT_SORT_NPC,npc).
-define(SPIRIT_SORT_ITEM,sceneitem).
-define(SPIRIT_SORT_MONSTER,monster).
-define(SPIRIT_SORT_USR,usr).
-define(SPIRIT_SORT_ROBOT,robot).
-define(SPIRIT_SORT_ENTOURAGE,entourage).
-define(SPIRIT_SORT_MODEL,model).

%% 客户端实体类�
-define(SPIRIT_CLIENT_TYPE_NULL, 0).
-define(SPIRIT_CLIENT_TYPE_USR, 1).			%%玩家
%% -define(SPIRIT_CLIENT_TYPE_PREVIEW_USR, 2).
-define(SPIRIT_CLIENT_TYPE_HORSE, 3).		%%坐骑
-define(SPIRIT_CLIENT_TYPE_MONSTER, 4).		%%怪物
-define(SPIRIT_CLIENT_TYPE_NPC, 5).			%%NPC	
%% -define(SPIRIT_CLIENT_TYPE_TRIGGER_ITEM, 6).%%触发�
-define(SPIRIT_CLIENT_TYPE_ENTOURAGE, 7).   %%佣兵
-define(SPIRIT_CLIENT_TYPE_DROP_ITEM, 8).   %%掉落物品
-define(SPIRIT_CLIENT_TYPE_PET, 9).			%%宠物
-define(SPIRIT_CLIENT_TYPE_FLY_POINT, 10).	%%传送点
%% -define(SPIRIT_CLIENT_TYPE_CGOBJ, 11).	%%动画对象
-define(SPIRIT_CLIENT_TYPE_TRAP, 12).		%%陷阱
-define(SPIRIT_CLIENT_TYPE_MODEL, 13).		%%阵营模型


%% 指定ID范围
-define(INSTANCE_OFF,100000000).
%% 怪物偏移
-define(OBJ_OFF,1000000000).
%% 英雄偏移
-define(ETRG_OFF,2000000000).
%% 宠物偏移
-define(PET_OFF,2100000000).

%%背包初始大小
-define(BAG_BASE_NUM,20).

%%场景马甲类型
-define(SCENE_SYSTEM_MONSTER,9).

%% 区域范围计算参数
-define(OUT_RAD,1).		%%外半�
-define(IN_RAD,2).		%%内半�
-define(SEG_ANGLE,3).	%%角度
-define(RECT_L,4).		%%矩形�
-define(RECT_W,5).		%%矩形�
-define(RECT_UP_H,6).	%%上高
-define(RECT_DOWN_H,7).	%%下高

-define(ATTACK_ADJUST_LEN,2).	%% 对技能范围进行距离修正，以防出现前端玩家打不到怪的bug

%% 阵营关系
-define(RELATION_FRIEND,0).	%%友善
-define(RELATION_ENEMY,1).	%%敌对
-define(RELATION_NEUTRAL,2).%%中立
-define(RELATION_TEAM,3).	%%组队

%% 场景物品触发方式
-define(CLICK_SCENE_ITEM_TOUCH,"TOUCH").%%可被点击
-define(CLICK_SCENE_ITEM_COLLIDE,"COLLIDE").%%可被碰撞
-define(CLICK_SCENE_ITEM_ATK,"ATK").%%可被攻击
%% -define(CLICK_SCENE_ITEM_NONE,"BLOCK").

%% 场景物品功能类型
-define(SCENE_ITEM_ACTION_TRIGGER,"TRIGGER").%%触发�
-define(SCENE_ITEM_ACTION_BLOCK,"BLOCK").%%阻挡
-define(SCENE_ITEM_ACTION_BUFF,"BUFF").%%添加BUFF
-define(SCENE_ITEM_ACTION_REWARDS,"REWARD").%%添加奖励
-define(SCENE_ITEM_ACTION_OTHER,"OTHER").%%其他功能

%% 场景物品触发相应的行�
-define(SCENE_ITEM_NONE,"NONE").
-define(SCENE_ITEM_TRANS,"TRANSFORM").
-define(SCENE_ITEM_JUMP,"JUMP").
-define(SCENE_ITEM_OPERATE,"OPERATE").
-define(SCENE_ITEM_DEL,"KILL").

%%boss类型
-define(BOSS_TOGETHER,"TOGETHER").%%合作
-define(BOSS_FIGHT,"FIGHT").%%抢夺
%%boss奖励人数
-define(BOSS_PRIZE_NUM,5).

%%官职类型
-define(CAMP_OFFICE_DEFAULT,0).%%平民
-define(CAMP_OFFICE_LEADER,1).%%首领
-define(CAMP_OFFICE_DEPUTY,2).%%副官


-define(REVIVE_SORT_ONE,1).%% 回城复活
-define(REVIVE_SORT_TWO,2).%% 当前地图复活点复
-define(REVIVE_SORT_THR,3).%% 原地复活

-define(CAMP_NORMAL,1).%%中立阵营
-define(CAMP_UNION,2).%%联盟阵营
-define(CAMP_TRIBE,3).%%部落阵营



-define(MAX_GUILD_NAME_LEN, 7).
-define(MIN_GUILD_NAME_LEN, 2).
-define(NEED_DIMOND_CREATE_GUILD, 50000).

-define(CAN_DONATE_TIME,3).


-define(REFRESH_HOUR, 5).%%每天5点刷新
%% 
-define(MAX_JOIN_REQ_TIMES,10).
-define(MAX_MEMBER_AMOUNT, 20).


-define(SUCCESS_KICK_GUILD,1).%%踢出
-define(SUCCESS_QUIT_GUILD,2).%%退出
-define(SUCCESS_GUILD_CREATE,3).%%创建
-define(SUCCESS_GUILD_DISMISS,4).%%解散公会
-define(SUCCESS_GUILD_JION,5).%%加入公会
-define(SUCCESS_GUILD_CHANGE_NAME,6).%%修改公会名称
-define(SUCCESS_GUILD_BLESSING,7).%%公会祝福
-define(SUCCESS_GUILD_LEVEL_UP,8).%%公会升级
-define(SUCCESS_GUILD_OFFICE_CHANGE,9).%%官职变化
-define(SUCCESS_GUILD_OFFICE_DEMOTE,10).%%罢免官员
-define(SUCCESS_GUILD_CHANGE_OWNER,11).%%转让会长

-define(ITEM_DUST,7).%%粉尘物品

%%聊天
-define(CHANLE_WORLD,1).
-define(CHANLE_TEAM,2).
-define(CHANLE_CAMP,3).
-define(CHANLE_GUILD,4).
-define(CHANLE_PRIVITE,5).
-define(CHANLE_SPEAKER,6).
-define(CHANLE_SYSTEM,7).
-define(CHANLE_GUILD_SYSTEM,8).
-define(CHANLE_CURR,11).
-define(CHANLE_GM_SYSTEM,12).
-define(CHANLE_FAMILY,13).

%%聊天点击类型
-define(NONE,0).
-define(FAMILY,1).
-define(GUILD,2).

%%英雄协议发送类型
-define(ALL_ENTOURAGE_LIST,0).			%% 上线时一次发送所有数据的类型


%%追随者状态
-define(ENTOURAGE_INACTIVE,0).			%% 未激活
-define(ENTOURAGE_ACTIVATE,1).			%% 激活
-define(ENTOURAGE_COMBAT,2).			%% 出战
-define(ENTOURAGE_SETTLED,3).			%% 入驻
-define(ENTOURAGE_DEAD,4).				%% 爽死了

-define(NONE_INHERIT,0).			%% 不继承
-define(PART_INHERIT,1).			%% 金币继承
-define(FULL_INHERIT,2).			%% 钻石继承

%%英雄状态（用于判断死亡）
-define(HERO_ACTIVATE,0).		%% 激活
-define(HERO_CAMBAT,1).			%% 出战
-define(YWWUYI_DIE,2).			%% 死亡

-define(ENTOURAGE_RETURN_NUM,12).%%拥有追随者是在激活返�个碎�
-define(ENTOURAGE_STAR_MAX_NUM,5).%%追随者最大星�
-define(ENTOURAGE_EQUIP_POS,20000).%%追随者的装备位置
-define(Binding,1).%%是否绑定

%%						
%%						
%%	玩家关注自身成长，达到一定的战斗力			sort	type	num
%%	悬赏	领取一次十环奖励		9001	0	1
%%	考古	完成十次考古		9002	0	10
%%	恶魔广场	参与一次恶魔广场		7002	104006	1
%%	强化	全身总强化等级超过100级		6007	0	100
%%	技能	技能总等级超过40级		5004	0	40
%%	活跃	活跃度达到100点		9003	0	100
%%	等级	等级达到48级		4001	201	48
%%						
%%	玩家开始参与交互，并对具体属性形成一定的要求					
%%	攻击	攻击力超过6000点		4001	101	6000
%%	防御	防御力超过5000点		4001	102	5000
%%	好友	被10个好友点赞		9004	0	10
%%	套装	激活任意一件套装的四件套效果		9005	0	4
%%	加星	军衔达到2级		9006	0	2
%%	专精	专精总等级达到20级		9017	0	20
%%	战力	总战力达到30000		9013	0	30000
%%						
%%	进一步使用游戏内容，并对玩家进行付费压迫					
%%	血量	非BUFF加成血量超过30000点		4001	104	30000
%%	成就	成就点数超过1500点		9007	0	1500
%%	要塞任务	完成10个要塞任务		9008	0	10
%%	英雄	获得英雄数量超过5个		9009	0	5
%%	加星	全身总加星数超过100星		6008	0	100
%%	等级	等级达到60级		4001	201	60
%%	战力	总战力达到50000		9013	0	50000
%%						
%%	进一步使用游戏内容，并对玩家进行付费压迫					
%%	暴击	暴击等级超过500点		4001	106	500
%%	称号	获得称号数量超过15个		9010	0	15
%%	公会	完成10个公会任务		9011	0	15
%%	宠物	获得3个宠物		9012	0	3
%%	军衔	军衔达到3级		9006	0	3
%%	活跃	活跃度达到300点		9003	0	300
%%	战力	总战力达到70000		9013	0	70000
%%						
%%	继续压榨					
%%	闪避	闪避超过500点		4001	110	500
%%	重铸	全身装备拥有20条蓝色品质以上的附加属性		9014	3	20
%%	遗物	获得的遗物数量超过5个		9015	0	5
%%	坐骑	坐骑等级超过50级		9016	0	50
%%	多人	参与3次多人活动		9018	0	3
%%	等级	等级达到70级		4001	201	70
%%	战力	总战力达到90000		9013	0	90000
%%						
%%	继续压榨					
%%	宝石	最高宝石等级超过8级		9019	0	8
%%	成就	成就点数超过2500点		9007	0	2500
%%	装备	拥有一件70级以上的橙装		9020	70	1
%%	时装	获得一套时装		9021	0	1
%%	宠物	宠物附加战力超过10000		9022	0	10000
%%	多人	参与6次多人活动		9018	0	6
%%	战力	总战力达到110000		9013	0	110000
%%						
%%	继续压榨					
%%	攻击	攻击超过20000		4001	101	20000
%%	防御	防御超过15000		4001	102	15000
%%	加星	装备最高加星等级达到40星		6009	0	40
%%	遗物	遗物总等级达到50级		9023	0	50
%%	坐骑	获得2个以上的坐骑皮肤		9024	0	2
%%	等级	等级达到80级		4001	201	80
%%	战力	总战力达到150000		9013	0	150000

%%家园建筑类型
-define(BUILDING_TYPE_HALL,			1).	%% 市政厅
-define(BUILDING_TYPE_GOLD_MINE,	2).	%% 金矿
-define(BUILDING_TYPE_FARM_MINE,	3). %% 农场
-define(BUILDING_TYPE_INSTITUE,		4).	%% 学院


%% 成就类型
-define(ACHIEVE_LOGIN_DAY,1).%%登陆日数
-define(ACHIEVE_LEV,2).%% 等级
-define(ACHIEVE_MONSTER_KILL,3).%%杀怪
-define(ACHIEVE_COPY_STEP,4).%%完成关卡
-define(ACHIEVE_RECYCLE_ITEM,5).%% 熔炼次数
-define(ACHIEVE_OWNER_HERO_NUM,6).%% 拥有英雄数量
-define(ACHIEVE_OWNER_STAR_HERO,7).%% 拥有几星英雄
-define(ACHIEVE_SKILL_LEV,8).%% 技能等级
-define(ACHIEVE_FIGHTING,9).%% 战力值
-define(ACHIEVE_ARENA_RANK,10).%% 竞技场排名
-define(ACHIEVE_DIAMO,11).%% 钻石
-define(ACHIEVE_ALL_EQU_LEV,12).%% 全身强化总等级
-define(ACHIEVE_HALL_LEV,13).%% 执政厅等级
-define(ACHIEVE_GOLD_LEV,14).%% 金矿等级
-define(ACHIEVE_FARM_LEV,15).%% 农场等级
-define(ACHIEVE_INSTITUE_LEV,16).%% 学院等级
-define(ACHIEVE_WORKD_BOSS,17).%% 世界BOSS挑战




-define(DIE_MINE_1,102011).
-define(DIE_MINE_2,102012).
-define(DIE_MINE_3,102013).
-define(TENSAI_1,102031).
-define(TENSAI_2,102032).
-define(TENSAI_3,102033).
-define(GHOST_1,102041).
-define(GHOST_2,102042).
-define(GHOST_3,102043).
-define(ICE_1,102051).
-define(ICE_2,102052).
-define(ICE_3,102053).

-define(SCENEID1,11001).
-define(SCENEID2,11005).
-define(SCENEID3,11010).
-define(SCENEID4,11015).
-define(SCENEID5,11020).
-define(SCENEID6,11025).
-define(SCENEID7,11030).
-define(SCENEID8,11035).
-define(SCENEID9,11040).
-define(SCENEID10,11045).
-define(SCENEID11,11050).

-define(MAIL_TITLE,util:get_data_text(51)).
-define(MAIL_CONTENT,util:get_data_text(52)).
-define(MAIL_SEND_NAME,util:get_data_text(53)).
-define(MAIL_TIME_LEN,14).

%% 充值类型
%%recharge sort
-define(RECHARGE_SORT_NORMAL,0).%%普通充值
-define(RECHARGE_SORT_WEEK,1).%%小月卡
-define(RECHARGE_SORT_MONTH,2).%%大月卡
-define(RECHARGE_SORT_LIVE,3).%%终生卡
-define(RECHARGE_SORT_FUND,4).%%基金

%% 充值活动类型
%% 普通充值0，周卡1，月卡2，终生卡3，充值成长奖励4
-define(TRUE_OF_INT,1).
-define(FALSE_OF_INT,0).
-define(CHARGE_ACTIVE_WEEK_CARD,1).
-define(CHARGE_ACTIVE_MONTH_CARD,2).
-define(CHARGE_ACTIVE_LIVE_CARD,3).
-define(CHARGE_ACTIVE_LEV_REWARD,4).
-define(CHARGE_CONTINUE_REWARD,5).
-define(CHARGE_EVERYDAY_REWARD,6).
-define(EQUALLY,0).

-define(WIN,  1).
-define(LOSE, 2).

-define(CAN_REVENGE,    0).
-define(CANNOT_REVENGE, 1).

-define(LOGIN_REWARD_MAX,180).

-define(DOG_Gianna,9).
-define(DOG_Sylvanas,13).
-define(DOG_Arthas,10).
-define(DOG_Tyrelan,11).
-define(DOG_Thrall,12).

-define(MONSTER_HG,50105).
-define(MONSTER_FKLF,130105).
-define(MONSTER_YHHG,10407).
-define(MONSTER_LSSY,10502).

-define(ARENA_WIN, 0).
-define(ARENA_LOSE, 1).

-define(COPY_NORMAL,1).
-define(COPY_HARD,2).
-define(COPY_HERO,3).


-define(COPY_GROUP_DIE_MINE,1).%% 通关死亡矿井
-define(COPY_GROUP_TENSAI,2).%% 通关天灾
-define(COPY_GROUP_GHOST,3).%% 通关恶灵深渊
-define(COPY_GROUP_ICE,4).%% 通关冰封之巅

-define(ABYSS_DOOR_SCENE,103001).%% 深渊第一层
-define(FYL_ABYSS_VIP,3).%% 飞深渊vip


-define(RECONNTIMES,3).%%重连次数
-define(RECONNTIME,90).%%重连时间

%% 所以的全服排行榜类型
-define (ALL_GLOBAL_RANK, [
	?RANKLIST_GLOBAL_RECHARGE,
	?RANKLIST_GLOBAL_CONSUME
]).

-define(RANKLIST_GLOBAL_GUILD_SAILING,1).%%公会跨服航海排行榜

-define(DUNGEONS_INSPIRE,1).
-define(WORLDBOSS_INSPIRE,2).

-define(SAILING_INSPIRE,101).   %%跨服航海鼓舞
-define(MELEEBOSS_INSPIRE,102). %%乱斗boss鼓舞
-define(MINING_INSPIRE,103). %%采矿鼓舞
-define(ARENA_INSPIRE,104). %%竞技场鼓舞

-define(WAR_MATCH,1).
-define(WAR_MATCH_EXIT,0).

-define(UPDATE,1).
-define(ADD,0).


-define(TURN,0).
-define(WHEEL,1).

-define(ONE,1).
-define(THREE,3).
-define(TEN,10).
-define(ITEM,0).
-define(RIDE_BUFF,6001).

-define(TALENT_ADD_PROP 				, 1).
-define(TALENT_ADD_BUY_COIN 			, 3).
-define(TALENT_ADD_ENTOURAGE_STONE_EXP  , 4).
-define(TALENT_ADD_PASSIVE_SKILL 		, 5).
-define(TALENT_DEC_SHENQI_UP_COST 		, 10).
-define(TALENT_DEC_ENTOURAGE_SKILL_COST , 12).
-define(TALENT_ADD_BAGLEV 				, 20).

-define(HERO_CHALLEGE,900000).

-define(AUTO_REFRESH_TIME_LONG,300000).

-define(ACT_CLOSE, 0).
-define(ACT_OPEN,  1).

%%运营活动
-define(OPERATION_TREASURE_ACTIVITY,1).%%宝藏活动
-define(OPERATION_ALL_PEOPLE,2).%%全民赢大奖活动
-define(OPERATION_EXTREME_LUXURY_GIFT,3).%%至尊豪礼

-define(OPERATION_RNAKLIST_CONSUME,2).%%消耗排行榜活动
-define(OPERATION_RNAKLIST_RECHARGE,3).%%充值排行榜活动
-define(OPERATION_DROP_ITEM,4).%%掉落活动

-define(OPERATION_ACTIVTIY_ALL,0).%%查询所有活动


-define(ADD_STAMINA,1).
-define(DEL_STAMINA,2).

%% 手机系统类别
-define(PHONE_TYPE_ANDRIOD, 1).
-define(PHONE_TYPE_IOS, 	2).

-define(HERO_ANNA, 9).%% 安娜
-define(HERO_HEIANJUNWANG, 10).%% 黑暗君王
-define(PHONE_LULIYA, 11).%% 露莉亚
-define(PHONE_GELAER, 12).%% 格拉尔
-define(PHONE_XIWANA, 13).%% 希瓦娜
-define(PHONE_AIERLIYA, 19).%% 艾尔莉亚
-define(PHONE_YUEYINGSHANA, 20).%% 月影莎娜
-define(PHONE_GELAKEQIAN, 22).%% 格拉克茜
-define(PHONE_BAOFENGYOUGE, 28).%% 暴风尤格
-define(PHONE_WEIKESI, 29).%% 维克斯
-define(PHONE_NUOSANIER, 30).%% 诺萨尼尔
-define(PHONE_ZHAKE, 31).%% 扎克
-define(PHONE_YOUDIEN, 32).%% 尤狄恩

%% GM后台上报事件
-define(GMS_EVT_DIAMOND_CHANGE, diamond_change).		%%钻石变化
-define(GMS_EVT_KILL, kill).							%%击杀数据
-define(GMS_EVT_RECHARGE, recharge).					%%充值数据
-define(GMS_EVT_ACC_REG, account_regist).				%%账号注册
-define(GMS_EVT_LOGIN, login).							%%上线
-define(GMS_EVT_LOGOUT, logout).						%%下线
-define(GMS_EVT_LEVEL_UP, level_up).					%%升级
-define(GMS_EVT_TASK, task).							%%任务节点停留统计
-define(GMS_EVT_CREATE_ROLE, create_role).				%%创建角色
-define(GMS_EVT_CHAT, chat).							%%聊天		
-define(GMS_EVT_CASH_CHANGE, cash).						%%礼金变化
-define(GMS_EVT_ONLINE, online).						%%在线统计
-define(GMS_EVT_COIN_CHANGE, coin).						%%铜币变化
-define(GMS_EVT_ITEM_CHANGE, item).						%%物品变化
-define(GMS_EVT_REQ_REBATE_INFO, req_rebate_info).		%%请求充值返利信息
-define(GMS_EVT_REBATE_DONE, rebate_done).				%%充值返利完成
-define(GMS_EVT_SHOP_BUY, shop_buy).					%%商城购买
-define(GMS_EVT_GUILD, guild).							%%公会操作
-define(GMS_EVT_TASK2, task_step).						%%功能任务
-define(GMS_EVT_BARRIER, barrier).						%%关卡
-define(GMS_EVT_ACTIVITY, activity).					%%gm活动
-define(GMS_EVT_ACTIVITY_RANK, activityRank).			%%gm活动排行
-define(GMS_EVT_USR_REGISTER, usr_register).			%%角色注册
-define(GMS_EVT_LOGIN_LOGOUT, usr_login_logout).		%%角色上线下线

%% 购买类型
-define(BUY_HEROSPACE,0).
-define(BUY_ARTIFACTSPACE,1).
-define(BUY_WORLDBOSS,2).
-define(BUY_QUICK_FARM,3).
-define(BUY_ARTIFACT_FAST,4).
-define(BUY_LIMITBOSS,5).
-define(BUY_GUILDCOPY,6).
-define(BUY_GLOBALARENA,7).
-define(BUY_MAZE,8).
-define(BUY_SAILING,9).
-define(BUY_MELEEBOSS,10).
-define(BUY_GRAB_TIMES,11).

-define(BUY_ACT_COPY_COIN,12).
-define(BUY_ACT_COPY_WARRIOR,13).
-define(BUY_ACT_COPY_HERO,14).
-define(BUY_GUILD_TEC_RESET_TIMES,15).




%% 竞技场类型
-define(PERSONAL_ARENA , 1). %% 个人竞技场
-define(FRIEND_ARENA   , 2). %% 好友竞技场

%% 抽奖类型
-define(SUMMON_DOOR     ,1). %% 召唤之门
-define(LOW_DRAW        ,2). %% 低级抽奖
-define(HIGH_DRAW       ,3). %% 高级抽奖
-define(FRIENDSHIP_DRAW ,4). %% 友情抽奖
-define(LOW_TURNTABLE   ,5). %% 低级转盘
-define(HIGH_TURNTABLE  ,6). %% 高级转盘