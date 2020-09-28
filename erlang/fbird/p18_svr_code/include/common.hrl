-include("config.hrl").
-include("svr_common.hrl").

-define(MAX_INT, 2147483648).  %% 一个4字节长度的整型最大值
-define(ONE_MILLION, 1000000).  %% 一百万
-define(UID_OFF,10000000000).

%% 颜色id定义
-define (COLOR_WHITE , 1).
-define (COLOR_GREEN , 2).
-define (COLOR_BLUE  , 3).
-define (COLOR_PURPLE, 4).
-define (COLOR_ORANGE, 5).
-define (COLOR_RED   , 6).

%%每天刷新事件
-define(AUTO_REFRESH_TIME,0).

%%回城场景物品
-define(LOAD_SCENE_ITEM_ID,999).

-define(PS_EVT_ATK_TAG,1011).
-define(PS_EVT_BE_ATK,1012).
-define(PS_EVT_STIFLE_TAG,1021).% åå¶ç®æ 
-define(PS_EVT_BE_STIFLE,1022).% è¢«åå¶
-define(PS_EVT_HIT_TAG,1031).% å½ä¸­ç®æ 
-define(PS_EVT_BE_HIT,1032).% è¢«å½ä¸­
-define(PS_EVT_DOD,1041).% éªé¿
-define(PS_EVT_TAG_DOD,1042).% ç®æ éªé¿
-define(PS_EVT_CRI_HIT_TAG,1051).% æ´å»
-define(PS_EVT_BE_CRI_HIT,1052).% è¢«æ»å»æ´å»
-define(PS_EVT_BLOCK,1061).% æµå¾¡
-define(PS_EVT_BE_BLOCK,1062).% è¢«æ»å»æµå¾¡
-define(PS_EVT_KICK_TAG,1071).% å»é£
-define(PS_EVT_BE_KICK,1072).% è¢«æ»å»å»é£
-define(PS_EVT_KICK_DOWN_TAG,1081).% å»å
-define(PS_EVT_BE_KICK_DOWN,1082).% è¢«æ»å»å»å
-define(PS_EVT_TAG_DIE,2001).% ç®æ æ­»äº¡ï¼è¿ç®åï¼
-define(PS_EVT_BE_DIE,2100).% èªå·±æ¿æ­»ï¼æ°å¢ï¼    
-define(PS_EVT_USE_SKILL,4001).% ä½¿ç¨æè½
-define(PS_EVT_MOVE,5001).% èªèº«ç§»å¨1S
-define(PS_EVT_ENTER_COPY,7001).% è¿å¥å¯æ¬å



%%好友
-define(RELATION_NO,0).%%没有关系
-define(RELATION_FRIENDS,1).%%好友
-define(RELATION_FOE,2).%%仇人
-define(RELATION_BLACKLIST,3).%%黑名单
-define(RELATION_THUMB_UP,4).%%点赞

%%追随者
-define(ENTOURAGE_ON_COMBAT,	1). %% 出战
-define(ENTOURAGE_ON_CANCEL,	2). %% 取消出战

%%排行榜
-define(RANKLIST_TYPE_GUILD, 4).%%公会排行榜
-define(RANKLIST_TYPE_GUILD_DAMAGE, 5).%%公会伤害排行榜
-define(RANKLIST_TYPE_LEVLE,3).%%等级排行榜
-define(RANKLIST_TYPE_ALLIANCE,1).%%联盟（2号阵营）战力排行榜
-define(RANKLIST_TYPE_TRIBE,2).%%部落（3号阵营）战力排行榜
-define(RANKLIST_TYPE_LIKE,6).%%点赞排行榜
-define(RANKLIST_TYPE_ARENA,7).%%竞技场排行榜


-define(STATE_ONLINE, 1).%%在线
-define(STATE_OFFLINE, 0).%%离线
%%公会副本重置时间
-define(RESET_GUILD_TIME, 86400).%%离线
%%  通用标识
-define(SUCCESS,1).
-define(FAIL,0).

-define(HERO_CHALLEGE_SCENE,900000).



-define(RIDE_TYPE,101).
-define(RIDE_EXP,102).
-define(MAAN,103).
-define(MATI,104).
-define(TOUKUI,105).
-define(HUJIA,106).
-define(JIANGSHENG,107).
-define(JIAOTA,108).
-define(RIDE_LEV,109).
-define(ON_RIDE,110).
-define(CURR_SKIN,111).
-define(EXP_CRIT,112).

-define(POS_MAAN,1).
-define(POS_MATI,2).
-define(POS_TOUKUI,3).
-define(POS_HUJIA,4).
-define(POS_JIANGSHENG,5).
-define(POS_JIAOTA,6).


-define(TRIALS_EXP,1).
-define(TRIALS_COIN,2).
-define(TRIALS_BRAVE,3).
-define(TRIALS_HERO,4).
-define(RISK_HERO,5).


-define(WAR1,1).
-define(WAR2,2).
-define(WAR3,3).
-define(WAR4,4).
-define(WAR5,5).
-define(WAR6,6).
-define(WAR7,7).
-define(WAR8,8).


-define(RISK_HERO_HEAD,1000).

-define(SORT_TASK_WEEK,9999).%%悬赏周长任务



-define(REWARDS_DAY,1).%%签到
-define(REWARDS_LEV,2).%%等级
-define(REWARDS_ONLINE,3).%%在线
-define(HTTPD_LISTEN_SET, [
			   %% Mandatory properties
			   %%{port, 9000 },
			   {port, db:get_config(http_listen_port)},	
			   {server_name, "wow"},
			   {bind_address, {0,0,0,0}},
			   {document_root, "."},
			   {server_root, "." },
  			   
			   %% Communication properties 
%% 		      {com_type, ssl },
			   
			   %% ssl properties
%% 			   {socket_type, ssl},
%% 		  	   {ssl_verify_client, 1},
%% 		       {ssl_ca_certificate_file, "./dvroot.cer"},
%%     		   {ssl_certificate_file, "./server.cer"},
%%     		   {ssl_certificate_key_file, "./server.key"},
%% 			   Authentication properties
%%  				{deny_from, [{192,168,1,154}, {192,168,1}]},
%%  				{allow_from, ["192.168.1.154", "192.168.1.180"]},
			   %% Administrative properties 
%% 						   {mime_types, "conf/mime.types" },
%% 						   {mime_type, "application/octet-streasm" },
%% 						   {server_admin, "the-ebbs-garden@googlegroups.com" },
%% 						   {log_format, combined }, 

			   %% URL aliasing properties - requires mod_alias 
%% 						   {directory_index, ["index.html", "index.htm"] }, 

			   %% Log properties - requires mod_log 
%% 						   {error_log, "d:\error.log" }, 
%% 						   {security_log, "d:\security.log" }, 
%% 						   {transfer_log, "d:\access.log" },
			   
			   %%modules
			   {modules,[mod_esi,mod_auth]},						   
			   {erl_script_alias, {"/rpc", [fun_http_action, fun_http_rpc_lyn, io]}}
			   ]).


%% 获得奖励的展示类型
-define(REWARD_SHOW_BOX, 	0).  %% 展示宝箱
-define(REWARD_SHOW_NORMAL, 1).  %% 直接进背包

%% 在关卡里每隔多少秒获得一次固定奖励
-define (REWAR_TIMER, 5).
%% 离线奖励多少秒获得一次
-define (OFFLINE_REWARD_INTERVAL, 30 * 60).
%% 离线奖励最多获得2天的奖励
-define (OFFLINE_REWARD_MAX_TIME_LEN, 2*24*3600).


%% 评级定义
-define (GRADE_D, 1).
-define (GRADE_C, 2).
-define (GRADE_B, 3).
-define (GRADE_A, 4).
-define (GRADE_S, 5).

%%	邮箱物品类型
-define (MAIL_RESOURE,	{_ResoureType, _ResoureNum}).
-define (MAIL_ITEM,		{_ItemType, _ItemNum, _Is_Binding}).
-define (MAIL_EQUIP,	{_Type, _Num, _Is_Binding, _EquOne, _EquTwo, _EquThree, _EquFour}).

%% Boss状态
-define(BOSS_STATE_ALIVE, 1).   %% 存活
-define(BOSS_STATE_DIE  , 2).	%% 死亡

%% 奖励状态定义
-define(REWARD_STATE_CAN_FETCH  , 0). 	%% 有奖励可领取
-define(REWARD_STATE_NOT_REACHED, 1). 	%% 奖励未达成
-define(REWARD_STATE_FETCHED    , 2). 	%% 奖励已领取

%% 活动状态
-define (ACT_STATE_OPEN, 1).	
-define (ACT_STATE_CLOSE, 2).


%% 事件状态
-define (EVENT_STATE_DOING, 1). %% 未完成，正在做
-define (EVENT_STATE_FINISHED, 2). %% 已完成

%% 英雄远征事件类型
-define (EXPEDTION_EVENT_FIGHTING, 1).  %% 打怪
-define (EXPEDTION_EVENT_STORE, 2).  %% 商店
-define (EXPEDTION_EVENT_REST, 3).  %% 休息
-define (EXPEDTION_EVENT_KEY, 4).  %% 钥匙

