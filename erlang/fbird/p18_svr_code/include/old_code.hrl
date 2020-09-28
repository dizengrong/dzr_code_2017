
-define(ACTION_GM_CODE,1).
-define(ACTION_REQ_ITEM_INFO,2).
-define(ACTION_DESTROY_ITEM,3).
-define(ACTION_REQ_LOST_ITEM,4).%%请求遗失之物
-define(ACTION_GET_LOST_ITEM,5).%%获取遗失之物
-define(ACTION_UP_LOST_ITEM_LEV,6).%%升级遗失之物
-define(ACTION_ACT_LOST_ITEM,7).%%激活遗失之物成�
-define(ACTION_NO_ACT_LOST_ITEM,8).%%取消激活遗失之物成�
-define(ACTION_REQ_MASTERY_DATA,9).%%获取专精数据
-define(ACTION_REQ_UP_MASTERY_LEV,10).%%专精升级
-define(ACTION_REQ_PET_DATA,11).%%获取宠物列表
-define(ACTION_REQ_ACT_PET,12).%%激活宠�
-define(ACTION_REQ_NO_ACT_PET,13).%%取消激活宠�
-define(ACTION_REQ_REVIVE,14).%%请求复活
-define(ACTION_REQ_COPY_TIMES,15).%%请求副本次数
-define(ACTION_REQ_COPY_ENTER,16).%%请求进入副本
-define(ACTION_REQ_COPY_OUT,17).%%请求退出副�
-define(ACTION_REQ_REVIVE_TIMES,18).%%请求复活次数
-define(ACTION_REQ_GET_MAIL_LIST,19).%%请求邮件列表
-define(ACTION_REQ_READ_MAIL,20).%%读取邮件
-define(ACTION_REQ_STOP_MATCH,21).%%停止匹配
-define(ACTION_REQ_MATCH_READY_CANCEL,22).%%匹配准备取消
-define(ACTION_REQ_SUBMIT_READY,23).%%匹配确认准备
-define(ACTION_REQ_CAMP_VOTE,24).%%阵营投票
-define(ACTION_REQ_JOIN_CAMP,25).%%加入阵营
-define(ACTION_REQ_CAMP_INFO,26).%%阵营信息
-define(ACTION_REQ_CAMP_WORSHIP,27).%%膜拜
-define(ACTION_REQ_MILITARY_PRIZE,28).%%军衔每日奖励
-define(ACTION_REQ_CAMP_ACTIVITY,29).%%阵营活动数据
-define(ACTION_REQ_CAN_WORSHIP,30).%%请求能否膜拜
-define(ACTION_REQ_QUICK_ADD_PET,31).%%请求快速获取宠物
-define(ACTION_REQ_BOSS_INFO,32).%%请求boss信息
-define(ACTION_REQ_ARENA_INFO,33).%%请求竞技场信息
-define(ACTION_REQ_REFLUSH_CHALL,34).%%请求刷新挑战者
-define(ACTION_REQ_ARENA_RECORD,35).%%请求竞技场记录
-define(ACTION_REQ_REFLUSH_ARENA_CD,36).%%请求刷新竞技场CD
-define(ACTION_REQ_CHALL_ARENA,37).%%请求挑战
-define(ACTION_REQ_RECHARGE,38).%%请求充值
-define(ACTION_REQ_RECHARGE_DATA,39).%%请求充值数据
-define(ACTION_REQ_CHG_CAMP_SKILL,40).%%请求改变阵营技能
-define(ACTION_REQ_CAMP_LEADER_INFO,41).%%请求阵营首领信息
-define(ACTION_REQ_SYSTEM_TIME,42).%%请求系统时间
-define(ACTION_REQ_RESET_COPY_TIMES,43).%%请求重置副本次数
-define(ACTION_REQ_NATIONAL_WAR_CALL,44).%%国战召集
-define(ACTION_REQ_NATIONAL_WAR_REC,45).%%国战记录
-define(ACTION_REQ_NATIONAL_WAR_CALL_RESPONSE,46).%%响应召集
-define(ACTION_REQ_NATIONAL_WAR_FLY,47).%%请求飞入
-define(ACTION_REQ_NATIONAL_WAR_SCROLLS_DATA,48).%%请求卷轴数据
-define(ACTION_REQ_NATIONAL_WAR_SCROLLS,49).%%捐献卷轴
-define(ACTION_REQ_NATIONAL_WAR_DATA,50).%%请求国战数据
-define(ACTION_REQ_GROW_PET,51).%%请求宠物成长
-define(ACTION_REQ_NATIONAL_WAR_START_TIME,52).%%请求国战开始时间
-define(ACTION_REQ_NATIONAL_WAR_TIPS,53).%%请求国战提示
-define(ACTION_REQ_WAR_DEMAGE_DATA,54).%%请求战场伤害数据
-define(ACTION_REQ_TEAM_ENTER_WAR,55).%%请求组队进战场
-define(ACTION_REQ_TEAM_WAR_PRE,56).%%请求组队战场准备
-define(ACTION_REQ_HIDE_BOSS_DATA,57).%%请求隐藏boss数据
-define(ACTION_REQ_HIDE_BOSS,58).%%请求隐藏boss
-define(ACTION_REQ_CANAEL_HIDE_BOSS,59).%%请求取消隐藏boss
-define(ACTION_REQ_FLY_TO_BOSS,60).%%请求飞往boss
-define(ACTION_REQ_OPEN_SVR_FIVE_REWARD,61).%%请求领取开服5日活动奖励
-define(ACTION_REQ_OPEN_SVR_FIVE_TIME,62).%%请求领取开服5日活动倒计时
-define(ACTION_REQ_OPEN_SVR_FIVE_DATA,63).%%请求领取开服5日活动数据

-define(ACTION_REQ_RENT_ENTOURAGE,64).%%出租英雄
-define(ACTION_REQ_EXPED_TASK,65).%%获取任务数据
-define(ACTION_REQ_GUILD_RENT_ENTOURAGE,66).%%获取工会可租英雄
-define(ACTION_REQ_EXPED_FINISH,67).%%出征完成
-define(ACTION_REQ_REFLUSH_EXPED,68).%%刷新出征
-define(ACTION_REQ_RENT_ENTOURAGE_LIST,69).%%个人英雄数据

-define(ACTION_REQ_CLIMB_TOWER_DATA,70).%%爬塔数据
-define(ACTION_REQ_CLIMB_TOWER_REWARD,71).%%爬塔首次奖励
-define(ACTION_REQ_CLIMB_TOWER_RESET,72).%%爬塔重置
-define(ACTION_REQ_CLIMB_TOWER_START,73).%%爬塔开始
-define(ACTION_REQ_CLIMB_TOWER_FAST,74).%%爬塔扫荡
-define(ACTION_REQ_CLIMB_TOWER_RESTART,75).%%爬塔重新开始

-define(ACTION_REQ_OPEN_SVR_LIMIT_TIME,76).%%开服活动持续时间
-define(ACTION_REQ_REQ_PWD_RED_INFO,77).%%请求口令红包数据
-define(ACTION_REQ_REQ_RECV_PWD_RED,78).%%抢口令红包

-define(ACTION_REQ_CONTINU_RECHARGE_DATA,79).%%GM连续充值数据
-define(ACTION_REQ_CONTINU_RECHARGE_REWARD,80).%%GM连续充值领奖
-define(ACTION_REQ_TURNING_WHEEL,81).%%幸运大转盘配置数据
-define(ACTION_REQ_TURNING_WHEEL_HIDE,82).%%幸运大转盘是否隐藏
-define(ACTION_REQ_CONTINU_RECHARGE_HIDE,83).%%幸运大转盘是否隐藏

-define(ACTION_REQ_RECHARGE_PACKAGE_DATA,84).%%充值大礼包次数
-define(ACTION_REQ_DRESS_SUIT_DATA,85).%%套装数据

-define(ACTION_REQ_LOST_ITEM_RECOVER,86).%%遗失之物请求复原

-define(ACTION_REQ_SINGLE_RECHARGE,101).%%请求单笔充值
-define(ACTION_REQ_REPEAT_RECHARGE,102).%%请求重复充值
-define(ACTION_REQ_GIFT_RECHARGE,103).%%请求赠礼
-define(ACTION_PICK_SINGLE_RECHARGE,104).%%提取单笔充值
-define(ACTION_PICK_REPEAT_RECHARGE,105).%%提取重复充值
-define(ACTION_PICK_GIFT_RECHARGE,106).%%提取赠礼

-define(ACTION_REQ_EXCHANGE,107).%%请求兑换
-define(ACTION_PICK_EXCHANGE,108).%%提取兑换
-define(ACTION_REQ_LOGINACT,109).
-define(ACTION_PICK_LOGINACT,110).


%%wm-------------------------------------------------

-define(ACTION_ENTOURAGE_LIST,1000).%%追随者列�
-define(ACTION_ENTOURAGE_INFO,1001).%%追随者详细信�
-define(ACTION_ENTOURAGE_ACTIVATE,1002).%%激活追随�
-define(ACTION_ENTOURAGE_EQUIP,1003).%%追随者装�
-define(ACTION_SKILL,1004).%%技能升�
-define(ACTION_ENTOURAGE_STAR,1005).%%升星
-define(ACTION_ITEM_DESTROY,1006).%%毁坏物品
-define(ACTION_ITEM_SELL_ITEM,1007).%%出售物品
-define(ACTION_ITEM_BUY_AND_UPDATE,1008).%%背包升级
-define(ACTION_REQUEST_BUY_AND_UPDATE,1009).%%返回背包升级
-define(ACTION_ITEM_LEAR_ITEM,1010).%%背包整理
-define(ACTION_SKILL_SUCCEED,1011).%%技能升级成�
-define(ACTION_SKILL_LIST,1012).%%请求技能列�
-define(ACTION_SKILL_RUNE,1013).%%请求解锁符文
-define(ACTION_SKILL_WEAR_RUNE,1014).%%请求穿戴符文
-define(ACTION_ITEM_IS_EQUIPMENT,1015).%%装备物品
-define(ACTION_ITEM_DISCHARGE_EQUIPMENT,1016).%%卸下装备
-define(ACTION_ENTOURAGE_COMBAT,1017).%%请求出战
-define(ACTION_ALL_ENTOURAGE_INFO,1018).%%请求所有列�
-define(ACTION_ITEM_IMPROVE,1019).%%强化装备
-define(ACTION_ITEM_STAR,1020).%%装备升星
-define(ACTION_ADD_GEM,1021).%%请求添加宝石
-define(ACTION_ALL_GEM_DATA,1022).%%请求玩家所有宝�
-define(ACTION_ITEM_A_KEY_IMPROVE,1023).%%一键强化装�
-define(ACTION_ITEM_BREAK,1024).%%装备突破
-define(ACTION_SINGN,1025).%%请求签到
-define(ACTION_ACTIVITY_REWARDS,1026).%%请求领取活跃度奖�
-define(ACTION_ADD_FRIENDS,1027).%%请求添加好友
-define(ACTION_A_KEY_ADD_FRIENDS,1028).%%请求一键添加好�
-define(ACTION_DELETE_FRIENDS,1029).%%请求删除好友
-define(ACTION_FRIENDS_THUMB_UP,1030).%%请求点赞
-define(ACTION_REVENGE,1031).%%请求寻仇
-define(ACTION_SEARCH_FRIENDS,1032).%%搜索好友
-define(ACTION_RECOMMENDED_FRIENDS,1034).%%推荐好友
-define(ACTION_DELETE_REVENGE,1035).%%删除仇人
-define(ACTION_GUILD_LIST,1036).%%请求加入公会列表
-define(ACTION_REPLY_GUILD_ENTRY,1037).%%请求回复加入公会申请
-define(ACTION_DONATE,1038).%%请求捐献
-define(ACTION_GUILD_QUIT,1039).%%请求退出公会
-define(ACTION_GUILD_PERM,1040).%%请求职位变更
-define(ACTION_GUILD_CREATE,1041).%%请求创建公会
-define(ACTION_SINGN_REWARDS,1042).%%请求领取签到奖励
-define(ACTION_SINGN_ALL,1043).%%请求签到信息
-define(ACTION_ALL_REVENGE,1044).%%请求所有好友
-define(ACTION_GUILD_JOIN,1045).%%请求加入公会
-define(ACTION_ACTIVITY_INFO,1046).%%请求活跃度详情
-define(ACTION_GUILD_NOTICE,1047).%%返回公会公告
-define(ACTION_GUILD_ROUGH_INFO,1048).%%请求查看公会公告
-define(ACTION_FRIEND_HISTORY_INFO,1049).%%请求好友历史记录
-define(ACTION_GUILD_SEEK,1050).%%搜索公会
-define(ACTION_ITEM_RECOIN,1051).%%确定重铸
-define(ACTION_CANCEL_COMBAT,1052).%%取消出战追随者
-define(ACTION_GUILD_INFO,1053).%%获取公会详情
-define(ACTION_GUILD_COMMONALITY_INFO,1054).%%获取公会公告详情
-define(ACTION_GUILD_BUILDING,1055).%%升级公会建筑
-define(ACTION_GUILD_BUILDING_LIST,1056).%%公会建筑列表
-define(ACTION_GUILD_DONATION_RECORD,1057).%%公会捐献记录

-define(ACTION_GUILD_COPY_LIST,1058).%%请求副本列表1058
-define(ACTION_GUILD_COPY_STATE,1059).%%请求副本状态1059
-define(ACTION_GUILD_COPY_TROPHY,1060).%%请求战利品列表1060 
-define(ACTION_GUILD_COPY_OPEN,1061).%%请求开启1061
-define(ACTION_GUILD_COPY_ENTER,1062).%%请求进入1062
-define(ACTION_GUILD_COPY_RESET,1063).%%请求重置1063
-define(ACTION_GUILD_COPY_DAMAGE,1064).%%请求伤害排行1064
-define(ACTION_GUILD_COPY_APPLY,1065).%%申请排队1065
-define(ACTION_GUILD_CHANGE_NOTICE,1066).%%更新公告
-define(ACTION_RANKLIST,1067).%%请求排行榜列表
-define(ACTION_EQUIP_INHERIT,1068).%%请求装备继承
-define(ACTION_LEV_REWARDS,1069).%%请求等级奖励领取
-define(ACTION_SEVEN_DAYS_REWARDS,1070).%%请求七日登陆奖励领取
-define(ACTION_REWARDS_LIST,1071).%%请求奖励列表
-define(ACTION_CHAPTER_INFO,1072).%%请求章节详情
-define(ACTION_CHAPTER_REWARDS,1073).%%请求章节奖励
-define(ACTION_RETURN_CHAPTER_INFO,1074).%%请求章节详情返回
-define(ACTION_GUILD_APPLY_FOR_LIST,1075).%%请求公会申请列表

-define(ACTION_USE_INFO_EQUIP,1076).%%请求人物信息
-define(ACTION_USE_INFO_PROP,1077).%%请求人物属性
-define(ACTION_USE_INFO_ENTOURAGE,1078).%%请求人物佣兵 
-define(ACTION_USE_INFO_LOST_ITEM,1079).%%请求人物遗物

-define(ACTION_DRAW,1080).%%请求抽奖
-define(ACTION_DRAW_TIME,1081).%%请求抽奖次数
-define(ACTION_ITEM_INFO,1082).%%请求item详细数据

-define(ACTION_ARCHAEOLOGY_DATA,1082).%%请求考古数据
-define(ACTION_ARCHAEOLOGY_TRANSMIT,1083).%%请求传送
-define(ACTION_ARCHAEOLOGY_HIRE,1084).%%请求雇佣
-define(ACTION_ARCHAEOLOGY_REFRESH,1085).%%请求刷新

-define(ACTION_ARCHAEOLOGY,1086).%%请求考古

-define(ACTION_TASK_WANTED_STAR,1087).%%一键升星
-define(ACTION_TASK_WANTED_FINISH,1088).%%全五星完成
-define(ACTION_TASK_WANTED_RESET,1089).%%重置
-define(ACTION_TASK_WANTED_STAR_RING,1090).%%星级和环数
-define(ACTION_DEL_TASK,1091).%%删除任务
-define(ACTION_TASK_WANTED_EXTRA_REWARDS,1092).%%领取十环的额外奖励


-define(ACTION_TASK_CAMP_STAR,1093).%%阵营任务一键升星
-define(ACTION_TASK_CAMP_FINISH,1094).%%阵营任务全五星完成
-define(ACTION_TASK_CAMP_REWARDS,1095).%%阵营任务领取十环的额外奖励
-define(ACTION_TASK_CAMP_STAR_RING,1096).%%阵营任务星级和环数
-define(ACTION_GUILDNAME_ENTRY,1097).%%公会名字申请加入公会
-define(ACTION_ONLINE_REWARDS,1099).%%请求在线奖励

-define(ACTION_ITEM_COMPOUND,1098).%%请求合成物品
-define(ACTION_ITEM_A_KEY_COMPOUND,1200).%%请求一键合成物品

-define(ACTION_SCENE_BRANCHING_INFO,1201).%%请求分线详细数据
-define(ACTION_SCENE_BRANCHING,1202).%%请求飞哪条分线

-define(ACTION_MODEL_CLOTHES_INFO,1203).%%请求所有时装数据
-define(ACTION_MODEL_CLOTHES_DRESS,1204).%%请求穿戴时装
-define(ACTION_UPGRADE_MODEL_CLOTHES,1205).%%时装升级
-define(ACTION_MODEL_CLOTHES_UNFIX,1206).%%请求脱下时装

-define(ACTION_POINT_RESET,1207).%%请求重置点数  d002
-define(ACTION_ADD_POINT,1208).%%请求添加点数  d003
-define(ACTION_ALL_POINT_INFO,1209).%%请求所有  d002

-define(ACTION_ALL_ATLAS_INFO,1210).%%请求所有解锁大地图  d002
-define(ACTION_TRANSFER_SCENEID,1211).%%请求大地图传送  d003


-define(ACTION_ALL_VIP_INFO,1212).%%请求vip数据  d002
-define(ACTION_VIP_REWARD,1213).%%请求领取vip奖励  d003

-define(ACTION_FIRST_EXTEND_RECHARGE,1214).%%请求首充续充奖励数据  d002
-define(ACTION_RECHARGE_REWARD,1215).%%请求领取首充续充奖励  d003

-define(ACTION_DART_ACTIVITY_TIME,1216).%%请求运镖的活动状态
-define(ACTION_TASK_FAILURE,1217).%%请求任务失败

-define(ACTION_ENTOURAGE_FETTER_INFO,1218).%%请求佣兵羁绊信息 d002
-define(ACTION_ENTOURAGE_FETTER_UPDATE,1219).%%请求佣兵羁绊升级 d003 传入 羁绊ID

-define(ACTION_ENTOURAGE_SOUL_LINK,1220).%%请求佣兵灵魂链接列表 d002
-define(ACTION_ENTOURAGE_ADD_SOUL_LINK ,1221).%%请求佣兵灵魂添加链接  d012 孔位 和 佣兵id
-define(ACTION_ENTOURAGE_DEL_SOUL_LINK ,1222).%%请求佣兵灵魂取消链接  d012 孔位
-define(ACTION_USE_ITEM_TIME ,1223).%%请求物品使用次数 d002

-define(ACTION_REQ_DART_POS,1224).%%请求镖车位置
-define(ACTION_REQ_DART_TIME,1225).%%请求镖车次数 d002

-define(ACTION_REQ_FREE_INFO,1226).%%请求离线经验 d002 
-define(ACTION_REQ_GET_FREE,1227).%%请求领取离线经验类型 d003

-define(ACTION_REQ_RETRUEVE_INFO,1228).%%请求找回系统数据 d002
-define(ACTION_REQ_GET_RETRUEVE,1229).%%请求领取找回系统传入哪个系统ID,哪个类型（a级，还是S级）d012
-define(ACTION_REQ_A_KEY_RETRUEVE,1230).%%请求领取找回系统传入哪个系统ID（一键a级，一键s级）d003
-define(ACTION_REQ_MOVE_SAND,1231).%%请求所有搬沙的详情
-define(ACTION_ARCHAEOLOGY_RESET,1232).%%请求考古重置
-define(ACTION_BUY_COIN,1233).%%请求金币购买
-define(ACTION_BUY_COIN_TIME,1234).%%请求金币购买次数
-define(ACTION_ALL_STAR,1235).%%请求全身装备星级 
-define(ACTION_TASK_REWARDS,1236).%%请求任务奖励 d012
-define(ACTION_BOOS_DEKARON,1237).%%请求召唤个人BOOS d003 传入召唤BOOS的ID
-define(ACTION_STORY_COPY,1238).%%请求剧情副本  d003 传入副本的ID
-define(ACTION_GUILD_TASK_RESET,1239).%%请求重置公会日常 d002
-define(ACTION_GUILD_TASK_ALL_FINISH,1240).%%请求公会五星全部完成任务 d002
-define(ACTION_GUILD_TASK_A_KEY_ALL_STAR,1241).%%请求一键满星 d002
-define(ACTION_GUILD_TASK_WHEEL_REWARD,1242).%%请求领取10环奖励 d002
-define(ACTION_GUILD_TASK_INFO,1243).%%请求工会奖励详细 d002
-define(ACTION_UNLOCK_ROYAL_BOX,1244).%%解锁宝箱1普通解锁，其他钻石解锁 d012
-define(ACTION_GET_ROYAL_BOX_REWARDS,1245).%%领取宝箱奖励 d003 
-define(ACTION_ROYAL_BOX_INFO,1246).%%领取宝箱奖励 d002

-define(ACTION_ENTOURAGE_REWARDS_INFO,1247).%%请求佣兵星级奖励信息 d002
-define(ACTION_REQ_ENTOURAGE_REWARDS,1248).%%请求佣兵星级领取奖励 d003

-define(ACTION_EQUIP_REWARDS_INFO,1249).%%请求装备详细信息 d002
-define(ACTION_REQ_EQUIP_REWARDS,1250).%%请求装备领取奖励 d003

-define(ACTION_OUT_STUCK,1251).%%请求脱离卡死 d002

-define(ACTION_REQ_WEEK_TASK_REWARDS,1252).%%请求完成周奖励 d003
-define(ACTION_WEEK_TASK_REWARDS_INFO,1253).%%周奖励数据 d002

-define(ACTION_WECHAT_REWARDS_CAN_GET,1254).%%请求是否可以领取奖励 d002
-define(ACTION_WECHAT_REWARDS_GET,1255).%%请求领取奖励微信奖励 d002 
-define(ACTION_WECHAT_SHARE,1256).%%请求微信分享 d002 

-define(ACTION_ENTOURAGE_WRAITH,1257).%%请求魂石 d003 佣兵ID
-define(ACTION_DRAMA_COPY_SWEEP,1258).%%请求副本扫荡 d003 扫荡副本ID

-define(ACTION_GUILD_POST,1259).%%请求公会职位
-define(ACTION_FORTRESS_TASK_INFO,1260).%%请求国战详细信息

-define(ACTION_REQ_ENEMY_INFO,1261).%%请求仇人详细信息 d002
-define(ACTION_REQ_INVITE_JOIN_GUILD,1262).%%请求邀请加入公会 d003 目标ID

-define(ACTION_REQ_ARCHAEOLOGY_MULTIPLE,1264).%%考古宝藏翻倍 d002
-define(ACTION_CONFIRM_INVITE_JOIN_GUILD,1263).%%确定加入公会 d004 目标公会名字
-define(ACTION_ENTOURAGE_ADD_EXP,1264).%%佣兵添加经验 物品ID，佣兵type

-define(ACTION_OTHER_USR_INFO_MOUNT,1265).%%查看其他玩家的坐骑
-define(ACTION_OTHER_USR_INFO_PET,1266).%%查看其他玩家的宠物
-define(ACTION_GROWTH_BIBLE_INFO,1267).%%请求成长宝典数据

-define(ACTION_GUILD_IMPEACH_PRESIDENT,1268).%%请求公会弹劾会长
-define(ACTION_GUILD_IMPEACH_PRESIDENT_POLL,1269).%%请求公会弹劾会长投票
-define(ACTION_BLACKLIST_ADD_UID,1270).%%玩家Uid添加黑名单 d003
-define(ACTION_BLACKLIST_ADD_NAME,1271).%%玩家name添加黑名单 d004
-define(ACTION_BLACKLIST_INFO,1272).%%请求黑名单数据 d002
-define(ACTION_BLACKLIST_DEL_UID,1273).%%玩家Uid删除黑名单 d003
-define(ACTION_UPDATA_FRIEND_INFO,1274).%%玩家更新好友场景数据 d002

-define(REQ_SCRAMBLE_INFO_DATA,1277).%%请求国王广场争夺战数据 d002

-define(REQ_SEVEN_DAY_ACTIVTY_DATE,1275).%%请求七日目标活动数据 d003 天数
-define(REQ_SEVEN_DAY_REWARDS_DATE,1276).%%请求七日目标奖励数据 d002
-define(REQ_SEVEN_DAY_TARGET_REWARDS,1280).%%领取七日目标添奖励 d003 天数

-define(REQ_LIGHT_BATH,1278).%%请求喝酒 d003
-define(REQ_BREAK_LIGHT_BATH,1279).%%打断喝酒 d002

-define(REQ_STRENGTH_OVEN_INFO,1281).%%请求力量烘炉详细数据 d002
-define(REQ_ACTIVE_STRENGTH_OVEN,1282).%%激活力量烘炉 	d003
-define(REQ_STRENGTH_OVEN_UPDATE_LEV,1283).%%请求力量烘炉升级 d003

-define(REQ_ACTIVITY_INSCRIPTION,1284).%%请求激活技能铭文d003
-define(REQ_UPDATE_INSCRIPTION_LEV,1285).%%请求升级技能铭文 d003
-define(REQ_INSCRIPTION_INFO,1286).%%请求技能铭文信息 d002

-define(REQ_SPEEDINESS_TEAM,1287).%%请求快捷组队 d003

-define(REQ_HAIR_RED_PACKET,1288).%%请求发红包 d003
-define(REQ_GRAB_RED_PACKET,1289).%%请求抢红包 d002
-define(REQ_RED_PACKET_INFO,1290).%%请求工会新增功能详情 d002

-define(REQ_GUILD_PAYOFF,1291).%%请求发工资
-define(REQ_GUILD_RANKLIST_REWARDS,1292).%%排行榜奖励领取

-define(REQ_GUILD_SET,1293).%%设置进入状态 d003

-define(REQ_GUILD_TEAM_COPY_INFO,1294).%%请求工会团本信息 d002
-define(REQ_GUILD_TEAM_COPY_INFO_WINKLE,1295).%%请求踢出工会号召	d003
-define(REQ_GUILD_TEAM_INFO,1296).%%请求工会队伍信息 d002
-define(REQ_GUILD_COPY_JOIN,1297).%%请求工会副本进入 d002
-define(REQ_GUILD_TEAM_COPY_INFO_DISSOLVE,1298).%%请求解散工会号召 d002
-define(REQ_GUILD_TEAM_COPY_INFO_QUIT,1299).%%请求退出工会号召	d002
-define(REQ_GUILD_TEAM_COPY_JOIN,1300).%%请求会长同意会员参加	d003
-define(REQ_GUILD_TEAM_COPY_AGREE,1301).%%请求成员同意会员参加	d002
-define(REQ_GUILD_TEAM_COPY_RESURGENCE,1302).%%工会副本请求复活 d002

-define(REQ_CALL_UP,1303).%%使用召集令 d003
-define(REQ_SEND_RED_PACKET_INFO,1304).%%红包详细信息
-define(REQ_CALL_UP_CONFIRM,1305).%%确定召集
-define(REQ_ABYSS_BOX_INFO,1306).%%深渊宝箱 d002

-define(REQ_ITEM_OPEN_SOUL_LISK,1307).%%使用物品添加灵魂链接 d003 孔位ID

-define(REQ_UPDATE_ENTOURAGE_MASTERY,1308).%%佣兵精通升级 d012 EntourageId,MasteryId 0随机 其他的属性ID
-define(REQ_ENTOURAGE_MASTERY_INFO,1309).%%佣兵精通升级信息 d002
-define(REQ_ENTOURAGE_MASTERY_RESET,1311).%%佣兵精通重置 d012 EntourageId,MasteryId 其他的属性ID

-define(REQ_FLYING_SHOES,1310).%%飞鞋 d012 TaskId,TaskStep
-define(ACTION_OTHER_SKILL,1312).%%请求人物技能信息
-define(ACTION_FLY_NPC,1313).%%请求飞到那个npc身边 d003


-define(ACTION_ACTIVITY_TREASURE_ITEM_INFO,1314).%%请求活动宝藏奖励列表 d002
-define(ACTION_ACTIVITY_TREASURE,1315).%%请求使用活动宝藏  d003 1,10
-define(ACTION_ACTIVITY_TREASURE_TIME,1317).%%请求活动时间 d002


-define(ACTION_ALL_PEOPLE_INFO,1316).%%请求活动全民赢大奖
-define(ACTION_GET_ALL_PEOPLE,1318).%%请求领取活动全民赢大奖
-define(ACTION_EXTREME_LUXURY_GIFT,1320).%%请求活动至尊豪礼

-define(ACTION_FLY_MONSTER,1319).%%请求飞到那个怪物身边 d003

-define(ACTION_CONSUME_ACTIVITY_INFO,1321).%%请求活动消费排行
-define(ACTION_RECHARGE_ACTIVITY_INFO,1323).%%请求活动充值排行
-define(ACTION_ACTIVITY_TREASURE_TIMES,1322).%%请求活动宝藏总次数

-define(ACTION_CONSUME_ACTIVITY_TIME,1324).%%请求活动消费排行时间
-define(ACTION_RECHARGE_ACTIVITY_TIME,1325).%%请求活动充值排行时间

-define(ACTION_THUMB_UP_NAME,1326).%%请求点赞传名字 d004

-define(ACTION_REQ_GLORY_SWORD_LEV,1327).%%请求荣耀之剑的等级 d002
-define(ACTION_REQ_UPDATE_GLORY_SWORD,1328).%%请求荣耀之剑的等级 d002

-define(ACTION_REQ_MILITARY_SKILL_INFO,1329).%%请求军衔详细信息 d002
-define(ACTION_REQ_UPDATE_MILITARY_SKILL,1330).%%请求军衔技能等级升级 d003
-define(ACTION_REQ_SELECT_MILITARY_SKILL,1331).%%请求选择军衔技能 d003
-define(ACTION_REQ_COPY_TIME_REWARDS_INFO,1332).%%请求副本次数奖励
-define(ACTION_REQ_COPY_TIME_REWARDS,1333).%%请求领取副本次数奖励

-define(ACTION_REQ_STAMINA_TIME,1334).%%请求体力次数 d002
-define(ACTION_REQ_BY_STAMINA,1335).%%请求购买体力d002

-define(ACTION_REQ_DIE_OUT_COPY,1339).%%死亡离开副本


-define(ACTION_REQ_GET_FRIEND_POINT, 1350).	%%请求领取友情点
-define(ACTION_REQ_GIVE_FRIEND_POINT, 1351).%%请求赠送友情点
-define(ACTION_REQ_GET_SALARY, 1352).%%请求领工资

-define(ACTION_REQ_ONLINE_STATUS, 1353).%%请求在线状态
-define(ACTION_ACT_GLOBAL_RECHARGE, 1354).%%请求跨服充值活动
-define(ACTION_ACT_GLOBAL_CONSUME, 1355).%%请求跨服消费活动
-define(ACTION_ACT_GLOBAL_RECHARGEJIFEN, 1356).%%请求跨服充值积分活动
-define(ACTION_ACT_GLOBAL_CONSUMEJIFEN, 1357).%%请求跨服消费积分活动

%%wm-------------------------------------------------

-define(ACTION_REQ_COMPOSE_INFO,1400).
-define(ACTION_REQ_COMPOSE,1401).
-define(ACTION_REQ_REFRESH,1402).
-define(ACTION_REQ_PET_DEBRIS,1403).


%%zzp 8000-9000 ------------------------------------------------
-define(ACTION_CHANGE_TITLE,8001).
-define(ACTION_GET_TITLES,8002).
-define(ACTION_TEAM_KICK_USR,8003).
-define(ACTION_GET_FAST_TEAMS,8004).
-define(ACTION_GET_RIDE_INFO,8005).
-define(ACTION_FEED_RIDE,8006).
-define(ACTION_CHANGE_RIDE_SKIN,8007).
-define(ACTION_RIDE_EQU_UP,8008).
-define(ACTION_ON_OFF_RIDING,8009).
-define(ACTION_GET_TRIALS_INFO,8010).
-define(ACTION_INTO_TRIALS,8011).
-define(ACTION_GET_RISKS_INFO,8012).
-define(ACTION_GET_RISK_HERO_SCHEDULE,8013).
-define(ACTION_INTO_RISKS,8014).
-define(ACTION_CONTINUE_HERO_CHALLEGE,8015).
-define(ACTION_REF_HERO_CHALLEGE,8016).
-define(ACTION_USE_CDKEY,8017).
-define(ACTION_GET_ACHIEVES,8018).
-define(ACTION_GET_ACHIEVE_PRICE,8019).
-define(ACTION_GET_TOTAL_ACHIEVE,8020).
-define(ACTION_GET_ACHIEVE_LEVUP,8021).
-define(ACTION_GET_CHARGE_ACTIVE,8022).
-define(ACTION_GET_CHARGE_PRICE,8023).
-define(ACTION_INTO_ABYSS,8024).
-define(ACTION_REQ_ORDER,8025).
-define(ACTION_REQ_MATCH_WAR,8026).
-define(ACTION_REQ_EXIT_MATCH_WAR,8027).
-define(ACTION_GET_GS_REWARDS_PRICE,8028).
-define(ACTION_GET_GS_REWARDS,8029).
-define(ACTION_GET_TRUN_CARD_INFO,8030).
-define(ACTION_REQ_TRUNING_CARD,8031).
-define(ACTION_GET_WHEEL_INFO,8032).
-define(ACTION_REQ_TURN_WHEEL,8033).
-define(ACTION_EXTRACT_WHEEL_PRICE,8034).
-define(ACTION_RET_WAR_TIMES,8035).
-define(ACTION_REQ_FAST_COPY,8036).
-define(ACTION_REQ_INTO_WAR,8037).
-define(ACTION_VIEW_WHEEL_PRICE,8038).
-define(ACTION_GET_GAMBLE_RECORD,8039).
-define(ACTION_GET_CHARGE_REBACK,8040).
%%zzp-------------------------------------------------


%%wxx 9001-10000--------------------------------------
-define(ACTION_RIDE_AWAKE,9001).
-define(ACTION_RIDE_FEEDTHREE,9002).
-define(ACTION_TITLE_CHGSTATE,9003).



-define(ACTION_TEAM_QUICK,2001). %%快速组�
-define(ACTION_TEAM_TARGET_CHG,2002). %%队伍目标改变
-define(ACTION_TEAM_ASK,2003). %%邀请组�
-define(ACTION_TEAM_REQ,2004). %%申请组队
-define(ACTION_TEAM_LEADER_CHG,2005). %%队长变更
-define(ACTION_TEAM_QUIT,2006). %%退出队�

-define(ACTION_STORE_INFO,2007). %%商店信息
-define(ACTION_STORE_REFRESH,2008). %%商店刷新


%%gzy--------------------------------------
-define(ACTION_SET_GUIDE_CODE,2009). %%设置引导

%% @doc 协议action code定义，原则上只做这个用途，不添加其他宏定义了


%% for dzr
%% =============================== 10000 - 10999 =============================== 
-define(ACTION_ITEM_A_KEY_IMPROVE_ALL      ,10000).%%一键强化所有装备
-define(ACTION_REQ_ACC_RECHARGE            ,10001).%%请求累积充值
-define(ACTION_REQ_FETCH_ACC_RECHARGE      ,10002).%%领取累积充值奖励
-define(ACTION_REQ_ACC_COST                ,10003).%%请求累积消费
-define(ACTION_REQ_FETCH_ACC_COST          ,10004).%%领取累积充值消费
-define(ACTION_REQ_GM_ACT_DOUBLE           ,10005).%%请求双倍活动
-define(ACTION_REQ_GM_ACT_DISCOUNT         ,10006).%%请求打折活动
-define(ACTION_REQ_GM_ACT_WEEK_TASK        ,10007).%%请求每周任务活动
-define(ACTION_REQ_GM_ACT_FETCH_WEEK_TASK  ,10008).%%领取每周任务活动奖励
-define(ACTION_REQ_GM_ACT_EXCHANGE         ,10009).%%请求兑换活动数据
-define(ACTION_REQ_GM_ACT_FETCH_EXCHANGE   ,10010).%%请求兑换道具
-define(ACTION_REQ_GM_ACT_SALE             ,10011).%%请求限时秒杀活动数据
-define(ACTION_REQ_GM_ACT_FETCH_SALE       ,10012).%%请求领取限时秒杀
-define(ACTION_REQ_GM_ACT_DROP             ,10013).%%请求特殊掉落活动数据
-define(ACTION_REQ_DAILY_ACC_RECHARGE      ,10014).%%请求每日累积充值
-define(ACTION_REQ_DAILY_FETCH_ACC_RECHARGE,10015).%%领取每日累积充值奖励
-define(ACTION_REQ_DAILY_ACC_COST          ,10016).%%请求每日累积消费
-define(ACTION_REQ_DAILY_FETCH_ACC_COST    ,10017).%%领取每日累积消费奖励
-define(ACTION_REQ_MYSTERY_GIFT_INFO       ,10018).%%请求运营活动神秘礼包数据
-define(ACTION_REQ_FETCH_MYSTERY_GIFT      ,10019).%%领取运营活动神秘礼包奖励

-define(ACTION_REQ_SHENQI_INFO           ,10020).%%请求神器info数据
-define(ACTION_REQ_SHENQI_UP_LV          ,10021).%%请求升级神器
-define(ACTION_REQ_SHENQI_LOAD           ,10022).%%请求穿戴神器
-define(ACTION_REQ_SHENQI_UP_STAR        ,10023).%%请求升级神器星级

-define(ACTION_REQ_RECENT_CHAT           ,10030).%%请求最近聊天信息
-define(ACTION_ACC_SINGN                 ,10031).%%请求领取累积签到奖励
-define(ACTION_TIME_EXTRA_REWARD         ,10035).%%请求领取在线时长额外奖励
-define(ACTION_LAST_CALLED_HERO          ,10036).%%请求上次召唤的英雄
-define(ACTION_REQ_BUY_GROW_FUND         ,10037).%%请求购买成长基金
-define(ACTION_REQ_FETCH_GROW_FUND       ,10038).%%请求领取成长基金奖励
-define(ACTION_REQ_GROW_FUND_INFO        ,10039).%%请求成长基金info数据
-define(ACTION_REQ_GM_OPEN_TREASURE      ,10040).%%请求gm宝藏活动开箱子
-define(ACTION_REQ_GM_TREASURE_INFO      ,10041).%%请求gm宝藏活动info数据
-define(ACTION_REQ_GM_TREASURE_EXCHANGE  ,10042).%%请求gm宝藏活动兑换
-define(ACTION_REQ_GM_TREASURE_RECORDS   ,10043).%%请求gm宝藏活动抽奖记录

-define(ACTION_REQ_WORLDBOSS_TIMES  , 10044).%%请求世界boss次数数据
-define(ACTION_REQ_WORLDBOSS_LIST   , 10045).%%请求世界boss列表
-define(ACTION_REQ_ENTER_WORLDBOSS  , 10046).%%请求进入世界boss副本
-define(ACTION_REQ_WORLDBOSS_INSPIRE, 10047).%%请求世界boss鼓舞
-define(ACTION_REQ_WORLDBOSS_RANK   , 10048).%%请求世界boss副本伤害排行榜
-define(ACTION_REQ_WORLDBOSS_INSPIRE_INFO, 10049).%%请求世界boss鼓舞数据

-define(ACTION_REQ_FETCH_RECHARGE_RETURN, 10060).%%请求领取充值返利
-define(ACTION_REQ_GM_RANK_LV_INFO      , 10061).%%请求gm等级排行榜活动
-define(ACTION_REQ_BARRIER_REWARD_INFO  , 10062).%%请求闯关奖励数据
-define(ACTION_REQ_BARRIER_REWARD_FETCH , 10063).%%请求领取闯关奖励

-define(ACTION_REQ_ENTER_MILITARY_BOSS , 10064).%%请求挑战军衔（转生）boss

-define(ACTION_REQ_GGB_INFO   , 10070).	%% 请求跨服公会战信息
-define(ACTION_REQ_GGB_WATCH  , 10071).	%% 请求观战跨服公会战
-define(ACTION_REQ_GGB_MY_TEAM, 10072).	%% 请求公会战自己队伍的信息
-define(ACTION_REQ_GGB_CHANGE_STRATEGY, 10073).	%% 公会战请求更改战队策略
-define(ACTION_REQ_GGB_INSPIRE, 10074).	%% 公会战请求鼓舞
-define(ACTION_REQ_GGB_STAKE, 10075).	%% 公会战请求押注
-define(ACTION_REQ_GGB_GROUP, 10076).	%% 公会战请求分组队伍的信息
-define(ACTION_REQ_GGB_BATTLE_LOG, 10077).	%% 公会战请求战斗记录
-define(ACTION_REQ_GGB_USE_SHENQI, 10078).	%% 公会战观战请求使用神器
-define(ACTION_REQ_PET_INFO, 10080).	%% 请求宠物信息
-define(ACTION_REQ_PET_UP_LV, 10081).	%% 请求宠物等级升级
-define(ACTION_REQ_PET_UP_STAGE, 10082).	%% 请求宠物升阶
-define(ACTION_REQ_PET_FOLLOW, 10083).	%% 请求跟随宠物

-define(ACTION_REQ_TALENT_INFO, 10090).	%% 请求天赋数据信息
-define(ACTION_REQ_TALENT_UP_SKILL, 10091).	%% 请求升级天赋技能
-define(ACTION_REQ_TALENT_UP_AWAKEN, 10092).	%% 请求升级觉醒
-define(ACTION_REQ_TALENT_DRAW, 10093).	%% 请求天赋抽奖

-define(ACTION_REQ_PEARL_INFO, 10100).	%% 请求元素珠信息
-define(ACTION_REQ_PEARL_ACTIVE, 10101).	%% 请求激活元素珠
-define(ACTION_REQ_PEARL_UP, 10102).	%% 请求升级元素珠

-define(ACTION_REQ_MINING_INFO, 10110).	%% 请求采矿信息
-define(ACTION_REQ_MINING_BEGIN, 10111).	%% 请求开始采矿
-define(ACTION_REQ_MINING_GRAB, 10112).	%% 请求抢夺
-define(ACTION_REQ_MINING_EXCHANGE, 10113).	%% 请求兑换
-define(ACTION_REQ_MINING_LIST, 10114).	%% 请求正在采矿的随机玩家列表
-define(ACTION_REQ_MINING_INSPIRE, 10115).	%% 请求采矿鼓舞
-define(ACTION_REQ_MINING_BUY_GRAB_TIMES, 10116).	%% 请求购买抢夺次数

%% =============================== 10000 - 10999 =============================== 




%% for psy
%% =============================== 11000 - 11999 =============================== 
-define(ACTION_REQ_GUILD_DAMAGE_REWARD   		,11000). %%请求公会boss伤害奖励
-define(ACTION_REQ_GUILD_KILL_REWARD     		,11001). %%请求公会boss击杀奖励
-define(ACTION_REQ_ALL_GUILD_DAMAGE_REWARD		,11002). %%一键领取公会boss伤害奖励
-define(ACTION_REQ_ALL_GUILD_KILL_REWARD 		,11003). %%一键领取请求公会boss击杀奖励
-define(ACTION_REQ_BUY_GUILD_INSPIRE    		,11004). %%购买公会鼓舞次数

-define(ACTION_REQ_BUY_DUNGEONS_TIMES   		,11005). %%购买地下城次数
-define(ACTION_CONFIRM_FRIENDS					,11006). %%确认添加好友
-define(ACTION_ADD_FRIENDS_APPLY				,11007). %%请求添加好友
-define(ACTION_REQ_FRIENDS_APPLY_INFO			,11008). %%请求好友申请列表
-define(ACTION_REFUSE_FRIEND_APPLY				,11009). %%拒绝好友申请
-define(ACTION_A_KEY_CONFIRM_APPLY		 		,11010). %%一键通过好友申请

-define(ACTION_REQ_SEVEN_DAY_STATE_REWARD 		,11011). %%请求七天小目标奖励
-define(ACTION_REQ_LIVENESS_REWARD				,11012). %%单个活跃度奖励

-define(ACTION_REQ_RELIFE						,11013). %%请求转生
-define(ACTION_REQ_HERALD						,11014). %%请求功能预告
-define(ACTION_REQ_HERALD_REWARD				,11015). %%请求功能预告奖励

-define(ACTION_REQ_BUY_ARENA_TIME				,11016). %%请求购买竞技场次数
-define(ACTION_REQ_RELIFE_TASK					,11017). %%请求转生任务

-define(ACTION_REQ_GM_ACT_PACKAGE				,11018). %%请求充值礼包
-define(ACTION_REQ_MEDICINE_BUFF				,11019). %%请求嗑药Buff
-define(ACTION_REQ_DOWNLOAD_REWARD	  	  		,11020). %%请求下载奖励

-define(ACTION_REQ_MEETING			  	  		,11021). %%请求议会开启
-define(ACTION_REQ_JOIN_MEETING		  	  		,11022). %%请求参加议会
-define(ACTION_REQ_HALL_REWARD		  	  		,11023). %%请求议会奖励
-define(ACTION_REQ_HOME_BUILDING_FAST_UPGRADE	,11024). %%请求快速完成升级
-define(ACTION_REQ_SETTLED						,11025). %%请求入驻
-define(ACTION_REQ_REMOVE_COMMANDER				,11026). %%请求移除指挥官
-define(ACTION_REQ_MINE_REWARD					,11027). %%请求领取资源
-define(ACTION_REQ_INSTITUE_SKILL_UPGRADE		,11028). %%请求升级学园技能

-define(ACTION_REQ_HERO_DEBT_EXCHANGE			,11029). %%交换英雄碎片

-define(ACTION_REQ_MEETING_HELP					,11030). %%请求会议帮助
-define(ACTION_REQ_BUY_QUICK_MINE				,11031). %%请求快速购买收获

-define(ACTION_REQ_BUY_ARTIFACT_FAST			,11032). %%请求神器加速购买
-define(ACTION_REQ_ARTIFACT_FAST_INFO			,11033). %%请求神器加速信息

-define(ACTION_REQ_GM_ACT_DOUBLE_RECHARGE		,11034). %%请求双倍充值信息

-define(ACTION_REQ_RANDOM_TASK					,11035). %%请求随机任务信息
-define(ACTION_REQ_TASK_REWARD					,11036). %%请求随机任务奖励
-define(ACTION_REQ_GIVE_UP_TASK					,11037). %%请求随机任务奖励

-define(ACTION_REQ_ENTER_LIMITBOSS				,11038). %%请求进入限时boss
-define(ACTION_REQ_BUY_LIMITBOSS_TIMES			,11039). %%请求购买限时boss次数
-define(ACTION_REQ_SYSTEM_ACTIVITY_INFO			,11040). %%请求后台活动信息
-define(ACTION_REQ_LIMITBOSS_TIMES				,11041). %%请求限时boss次数

-define(ACTION_REQ_GM_LIMIT_SUMMON_INFO			,11042). %%请求限限时推荐召唤活动信息

-define(ACTION_REQ_CHARGE_CARD_INFO				,11043). %%请求充值卡信息

-define(ACTION_REQ_REVIVE_NOT_PLACE				,11044). %%请求重新开始

-define(ACTION_REQ_REFRESH_GROW_FUND			,11045). %%请求刷新成长基金

-define(ACTION_REQ_ENTOURAGE_INHERIT			,11046). %%请求英雄经验继承
-define(ACTION_RE_ENTOURAGE_COMBAT				,11047). %%请求英雄重新出战

-define(ACTION_ENTOURAGE_RUNE_INFO				,11048). %%请求英雄符文信息
-define(ACTION_ENTOURAGE_RUNE_IMPROVE			,11049). %%请求英雄符文升级
-define(ACTION_ENTOURAGE_RUNE_DEVELOP			,11050). %%请求英雄符文升阶
-define(ACTION_ENTOURAGE_RUNE_RECYCLE			,11051). %%请求英雄符文回炉

-define(ACTION_REQ_CONTINUOUS_RECHARGE			,11052). %%请求gm连续充值活动信息
-define(ACTION_REQ_FETCH_CONTINUOUS_RECHARGE	,11053). %%请求领取gm连续充值活动奖励
-define(ACTION_REQ_LIMIT_ACHIEVEMENT			,11054). %%请求gm限时成就信息
-define(ACTION_REQ_FETCH_LIMIT_ACHIEVEMENT		,11055). %%请求领取gm限时成就奖励

-define(ACTION_REQ_SET_ARENA_GUARD_ENTOURAGE	,11056). %%请求设置竞技场防守英雄
-define(ACTION_REQ_ARENA_GUARD_ENTOURAGE		,11057). %%请求竞技场防守英雄

-define(ACTION_REQ_RECRUITING_MEMBERS			,11058). %%请求发布公会招募信息
-define(ACTION_REQ_BUY_GUILD_TIMES				,11059). %%请求购买公会副本次数

-define(ACTION_REQ_RESET_ENTOURAGE_SKILL		,11060). %%请求重置英雄技能等级

-define(ACTION_REQ_CHANGE_GUILD_NAME			,11061). %%请求更换公会名称

-define(ACTION_REQ_ENTOURAGE_PROPERTY			,11062). %%请求英雄属性

-define(ACTION_REQ_WORLDLEVEL_INFO				,11063). %%请求世界等级信息
-define(ACTION_REQ_WORLDLEVEL_REWARD			,11064). %%请求世界等级奖励

-define(ACTION_REQ_GUILD_BLESSING_INFO			,11065). %%请求公会祝福信息
-define(ACTION_REQ_GUILD_BLESSING 				,11066). %%请求公会祝福

-define(ACTION_REQ_GUILD_LOG 	 				,11067). %%请求公会记录

-define(ACTION_REQ_GLOBAL_ARENA_INFO			,11068). %%请求跨服竞技场信息
-define(ACTION_REQ_BUY_GLOBAL_ARENA_TIME		,11069). %%请求购买跨服竞技场次数
-define(ACTION_REQ_GLOBAL_ARENA_TASK_REWARD		,11070). %%请求跨服竞技场每日任务奖励
-define(ACTION_REQ_GLOBAL_ARENA_MATCH_START		,11071). %%请求跨服竞技场开始匹配
-define(ACTION_REQ_GLOBAL_ARENA_MATCH_END		,11072). %%请求跨服竞技场结束匹配
-define(ACTION_REQ_GLOBAL_ARENA_WORSHIP			,11073). %%请求跨服竞技场上赛季膜拜

-define(ACTION_REQ_GM_ACT_LIMIT_DOUBLE_RECHARGE	,11074). %%请求gm限时双倍充值

-define(ACTION_REQ_GM_ACT_RECHARGE_POINT		,11075). %%请求gm充值建设点
-define(ACTION_REQ_FETCH_RECHARGE_POINT_REWARD	,11076). %%请求gm充值建设点奖励

-define(ACTION_REQ_VIP_DAILY_REWARD				,11077). %%请求VIP每日礼包信息
-define(ACTION_REQ_FETVH_VIP_DAILY_REWARD		,11078). %%请求领取VIP每日礼包

-define(ACTION_REQ_MAZE_INFO 					,11079). %%请求迷宫信息
-define(ACTION_REQ_MAZE_POWER 					,11080). %%请求购买迷宫体力
-define(ACTION_REQ_MAZE_INSPARE					,11081). %%请求购买迷宫鼓舞
-define(ACTION_REQ_MAZE_EXPLORE					,11082). %%请求迷宫探索
-define(ACTION_REQ_MAZE_EVENT					,11083). %%请求迷宫事件
-define(ACTION_REQ_MAZE_SETTLE					,11084). %%请求迷宫结算
-define(ACTION_REQ_MAZE_REVENGE					,11085). %%请求迷宫复仇
-define(ACTION_REQ_PRAISE_REWARD				,11086). %%请求好评奖励
-define(ACTION_REQ_MAZE_STEP_REWARD				,11087). %%请求迷宫阶段奖励

-define(ACTION_REQ_SAILING_INFO 				,11088). %%请求公会航海信息
-define(ACTION_REQ_SAILING_PLUNDER				,11089). %%请求公会航海劫掠
-define(ACTION_REQ_SAILING_GUARD				,11090). %%请求公会航海护航
-define(ACTION_REQ_SAILING_INSPIRE				,11091). %%请求公会航海鼓舞
-define(ACTION_REQ_SAILING						,11092). %%请求公会航海
-define(ACTION_REQ_SAILING_BUY_TIME				,11093). %%请求公会航海次数购买
-define(ACTION_REQ_REFRESH_SAILING_PLUNDER		,11094). %%请求刷新掠夺列表
-define(ACTION_REQ_SAILING_GUARD_INFO			,11095). %%请求公会航海护航信息
-define(ACTION_REQ_SAILING_REWARD				,11096). %%请求公会航海奖励
-define(ACTION_REQ_SAILING_GUARD_FROM_GUILD		,11097). %%请求公会航海邀请协助

-define(ACTION_REQ_GM_ACT_LITERATURE_COLLECTION	,11098). %%请求gm集字活动
-define(ACTION_REQ_FETCH_LITERATURE_COLLECTION	,11099). %%请求gm集字活动奖励

-define(ACTION_REQ_GM_ACT_LOTTERY_CAROUSEL		,11100). %%请求gm转盘活动
-define(ACTION_REQ_DRAW_LOTTERY_CAROUSEL		,11101). %%请求gm转盘活动抽取
-define(ACTION_REQ_FETCH_LOTTERY_CAROUSEL		,11102). %%请求gm转盘活动奖励

-define(ACTION_REQ_MAZE_RANKLIST				,11103). %%请求迷宫排行榜

-define(ACTION_REQ_MELLEBOSS_INFO				,11104). %%请求乱斗boss信息
-define(ACTION_REQ_ENTER_MELLEBOSS				,11105). %%请求进入乱斗boss
-define(ACTION_REQ_BUY_MELLEBOSS_TIME			,11106). %%请求购买乱斗boss获奖次数
-define(ACTION_REQ_ATTACT_MELLEBOSS_OWNER		,11107). %%请求攻击乱斗boss所有者

-define(ACTION_REQ_REVIVE_NEW 					,11108). %%请求原地复活新
-define(ACTION_REQ_NOT_REVIVE_NEW 				,11109). %%请求不原地复活新

-define(ACTION_REQ_SHENQI_AWAKE_INFO			,11110). %%请求神器觉醒信息
-define(ACTION_REQ_SHENQI_AWAKE_UP 				,11111). %%请求神器觉醒升级

-define(ACTION_REQ_HEAD_LEV_INFO 				,11112). %%请求头像等级信息
-define(ACTION_REQ_UP_HEAD_LEV	 				,11113). %%请求头像等级升级
-define(ACTION_REQ_HEAD_SUIT_INFO 				,11114). %%请求头像套装信息
-define(ACTION_REQ_ACTIVE_HEAD_SUIT				,11115). %%请求激活头像套装
-define(ACTION_REQ_UP_HEAD_SUIT_LEV				,11116). %%请求头像套装升级

-define(ACTION_REQ_GUILD_IMPEACH				,11117). %%请求公会弹劾
-define(ACTION_REQ_GUILD_IMPEACH_RESULT			,11118). %%请求公会弹劾结果

-define(ACTION_REQ_RANDOM_PACKAGE_INFO			,11119). %%请求随机礼包信息
-define(ACTION_REQ_RANDOM_PACKAGE_REWARD		,11120). %%请求随机礼包奖励

-define(ACTION_REQ_GM_ACT_RETURN_INVESTMENT		,11121). %%请求投资回报信息
-define(ACTION_REQ_FETCH_RETURN_INVESTMENT		,11122). %%请求投资回报奖励

-define(ACTION_REQ_ENTOURAGE_AWAKE				,11123). %%请求英雄觉醒

-define(ACTION_REQ_LEGENDARY_LEVEL_INFO			,11124). %%请求传说等级信息
-define(ACTION_REQ_UPDATE_LEGENDARY_LEVEL		,11125). %%请求提升传说属性

-define(ACTION_REQ_ITEM_EXCHANGE				,11126). %%请求兑换物品

-define(ACTION_REQ_CHANGE_LEGENDARY_EXP			,11127). %%请求兑换传奇经验
-define(ACTION_REQ_UP_LEGENDARY_LEVEL			,11128). %%请求提升传奇等级
-define(ACTION_REQ_LEGENDARY_EXP_INFO			,11129). %%请求传奇经验信息

-define(ACTION_REQ_DRESS_GOD_COSTUME			,11130). %%请求穿戴神装
-define(ACTION_REQ_UPGRADE_GOD_COSTUME			,11131). %%请求升级神装
-define(ACTION_REQ_ACTIVE_COSTUME_POSITION		,11132). %%请求激活神装孔位
-define(ACTION_REQ_GOD_COSTUME_INFO				,11133). %%请求神装信息
-define(ACTION_REQ_UPGRADE_GOD_COSTUME_STAGE	,11134). %%请求提升神装阶段等级
-define(ACTION_REQ_ACTIVE_GOD_COSTUME_ILLUS		,11135). %%请求激活神装图鉴
-define(ACTION_REQ_GOD_COSTUME_DRAW				,11136). %%请求神装抽奖

-define(ACTION_REQ_ARENA_SEASON_INFO			,11136). %%请求竞技场新信息
-define(ACTION_REQ_ARENA_AGENT_INFO				,11137). %%请求竞技场新个人信息
-define(ACTION_REQ_FETCH_ARNEA_REWARD			,11138). %%请求领取赛季奖励
-define(ACTION_REQ_BUY_ARENA 					,11139). %%请求购买竞技场商店
-define(ACTION_REQ_FETCH_ARENA_TASK_REWARD		,11140). %%请求领取竞技场任务奖励
-define(ACTION_REQ_BUY_ARENA_INSPIRE			,11141). %%请求购买竞技场鼓舞
-define(ACTION_REQ_REFRESH_ARENA_TASK			,11142). %%请求刷新竞技场任务

-define(ACTION_REQ_GM_ACT_SINGLE_RECHARGE		,11143). %%请求gm活动单笔充值信息
-define(ACTION_REQ_GM_ACT_ACC_LOGIN				,11144). %%请求gm活动累计登陆信息
-define(ACTION_REQ_FETCH_SINGLE_RECHARGE		,11145). %%请求领取gm活动单笔充值
-define(ACTION_REQ_FETCH_ACC_LOGIN				,11146). %%请求领取gm活动累计登陆

-define(ACTION_REQ_BUY_GOD_BAG_LEV				,11147). %%请求购买神装背包等级

-define(ACTION_REQ_GM_ACTIVITY					,11148). %%请求运营活动总数据
-define(ACTION_REQ_GM_ACT_POINT_PACKAGE			,11149). %%请求gm活动积分礼包信息
-define(ACTION_REQ_FETCH_POINT_PACKAGE			,11150). %%请求领取gm活动积分礼包
-define(ACTION_REQ_GM_ACT_DIAMOND_PACKAGE		,11151). %%请求gm活动钻石礼包信息
-define(ACTION_REQ_FETCH_DIAMOND_PACKAGE		,11152). %%请求领取gm活动钻石礼包
-define(ACTION_REQ_GM_ACT_RMB_PACKAGE			,11153). %%请求gm活动人民币礼包信息
-define(ACTION_REQ_FETCH_RMB_PACKAGE			,11154). %%请求领取gm活动人民币礼包
-define(ACTION_REQ_GM_ACT_TURMTABLE				,11155). %%请求gm活动大转盘信息
-define(ACTION_REQ_FETCH_TURMTABLE				,11156). %%请求领取gm活动大转盘
-define(ACTION_REQ_DRAW_TURMTABLE				,11157). %%请求gm活动大转盘抽奖
-define(ACTION_REQ_REFRESH_TURMTABLE			,11158). %%请求gm活动大转盘刷新
%% =============================== 11000 - 11999 =============================== 


%% for zsk
%% =============================== 12000 - 12999 =============================== 
-define(ACTION_REQ_TIME_REWARD,12000). %%请求离线奖励信息
-define(ACTION_REQ_GET_TIME_REWARD,12001). %%领取离线奖励
-define(ACTION_REQ_STORY_REWARD,12002). %%领取故事奖励
-define(ACTION_REQ_STORY_INFO,12003). %%请求故事进展
-define(ACTION_REQ_ACTIVE_RIDE,12004). %%激活坐骑
-define(ACTION_REQ_ACTIVE_CLOTHES,12005). %%激活时装
-define(ACTION_REQ_TASK_STEP_INFO,12006). %%功能预告信息
-define(ACTION_REQ_GET_TASK_STEP_REWARD,12007). %%功能预告领奖
-define(ACTION_REQ_GUILD_STONE_INFO,12008). %%请求公会魂石界面信息
-define(ACTION_REQ_GET_GUILD_STONE,12009). %%请求获取公会魂石捐赠
-define(ACTION_REQ_DONATION_GUILD_STONE,12010). %%请求捐赠魂石给别人

%% =============================== 12000 - 12999 =============================== 
-define(ACTION_REQ_HOME_BUILDING_LIST, 13000).	%%请求家园建筑列表
-define(ACTION_REQ_HOME_BUILDING_DETAIL, 13001).	%%请求家园建筑详情
-define(ACTION_REQ_HOME_BUILDING_UPGRADE, 13002).	%%请求家园建筑升级
-define(ACTION_REQ_HOME_BUILDING_GATHER, 13003).	%%请求家园建筑资源采集
-define(ACTION_REQ_HOME_BUILDING_WORKER_ASSIGN, 13004).		%%请求家园建筑工作岗位入驻英雄
-define(ACTION_REQ_HOME_BUILDING_ASSISTANT_ASSIGN, 13005).		%%请求家园建筑辅助岗位入驻英雄

%% for wxx
%%================================ 14000 - 14999 ===============================
-define(ACTION_PAY_BYJIFEN						, 14000). %%积分兑换物品
-define(ACTION_REQ_CHANGE_HEAD 					, 14001).%%头像切换
-define(ACTION_REQ_USR_HEAD 					, 14002).%%头像请求