-module(ptc_action_int).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D003.

get_name() -> action_int.

get_des() ->
	[
	 {action,int32,0},
	 {data,uint64,0}
	 ].

get_note() ->"
				1002	激活追随者(追随者ID)
				1005	追随者升星(追随者ID)
				1006	毁坏物品(物品实例化ID)
				1016	卸下装备(物品实例化ID)
				1017	请求出战(追随者ID)
				1020	装备升星(物品实例化ID)
				1021	请求添加宝石(宝石ID)
				1023	一键强化装备(物品实例化ID)
				1024	装备突破(物品实例化ID)
				1026	请求领取活跃度奖励(活跃度奖励id)
				1027	请求添加好友(目标玩家ID)
				1029	请求删除好友(目标玩家ID)
				1030	请求点赞(目标玩家ID)
				1031	请求寻仇(目标玩家ID)
				1035	删除仇人(目标玩家ID)
				1038	请求捐献(捐献类型数据配表)
				1039	请求退出公会(0,退出公会|其余的是踢出公会)
				1042	请求领取签到奖励(签到奖励ID)
				1045	请求加入公会(公会ID)
				1048	请求查看粗略信息(公会ID)
				1051	确定重铸(物品实例化ID)
				1062	请求进入公会副本(公会副本ID)
				1063	请求重置公会副本(公会副本ID)
				1064	请求公会副本伤害排行(公会副本ID)
				1067	请求排行榜列表(排行榜ID)
				1068	请求装备继承(物品实例化ID)
				1069	请求等级奖励领取(等级奖励id)
				1070	请求七日登陆奖励领取(七日登陆奖励id)
				1071	请求奖励列表(1,七日登陆奖励|2,等级奖励|3,在线奖励)
				1073	请求章节奖励(章节ID)
				1076	请求人物信息(目标玩家ID)
				1077	请求人物属性(目标玩家ID)
				1078	请求人物佣兵(目标玩家ID)
				1079	请求人物遗物(目标玩家ID)
				1082	请求item详细数据(物品实例化ID)
				1097	公会名字申请加入公会(目标玩家ID)
				1099	请求在线奖励(在线奖励id)
				1098	请求合成物品(物品实例化ID)
				1200	请求一键合成物品(物品实例化ID)
				1202	请求飞哪条分线(分线ID)
				1204	请求穿戴时装(时装ID)
				1205	时装升级(时装ID)
				1208	请求添加巅峰等级点数(属性ID)
				1211	请求大地图传送(地图配置表ID)
				1213	请求领取vip奖励  (vip奖励ID)
				1215	请求领取首充续充奖励  (充续充奖励ID)
				1219	请求佣兵羁绊升级(羁绊ID)
				1227	请求领取离线经验类型 (离线经验领取类型[1,普通奖励|2,金币付费|3,钻石付费])
				1230	请求领取找回系统(系统ID)(一键a级，一键s级）
				1237	请求召唤个人BOOS  (召唤BOOS的ID)
				1238	请求剧情副本  (副本的ID)
				1245	领取皇室宝箱奖励  (皇室宝箱实例化ID) 
				1248	请求佣兵星级领取奖励 (佣兵星级领取奖励ID)
				1250	请求装备领取奖励 (装备领取奖励ID)
				1252	请求领取周奖励  (周奖励ID)
			
			". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).
