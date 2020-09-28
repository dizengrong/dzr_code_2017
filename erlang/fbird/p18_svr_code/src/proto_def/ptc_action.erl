-module(ptc_action).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D002.

get_name() -> action.

get_des() ->
	[
	 {action,int32,0}
	 ].

get_note() ->"
		action = 1000	追随者列表
		action=	1000	追随者列表
		action=	1008	背包升级
		action=	1012	请求技能列表
		action=	1018	请求所有佣兵信息
		action=	1028	请求一键添加好友
		action=	1034	推荐好友
		action=	1036	请求加入公会列表
		action=	1043	请求签到列表
		action=	1044	请求所有好友
		action=	1046	请求活跃度详情
		action=	1048	请求查看粗略信息
		action=	1049	请求好友历史记录
		action=	1052	取消出战追随者
		action=	1053	获取公会详情
		action=	1054	获取公会公告详情
		action=	1056	公会建筑列表
		action=	1057	公会捐献记录
		action=	1060	请求战利品列表
		action=	1072	请求章节详情
		action=	1075	请求公会申请列表
		action=	1081	请求抽奖次数
		action=	1082	请求考古数据
		action=	1083	请求传送
		action=	1084	请求雇佣
		action=	1085	请求刷新
		action=	1086	请求考古
		action=	1087	一键升星
		action=	1088	全五星完成
		action=	1089	重置
		action=	1090	星级和环数
		action=	1092	领取十环的额外奖励
		action=	1093	阵营任务一键升星
		action=	1094	阵营任务全五星完成
		action=	1095	阵营任务领取十环的额外奖励
		action=	1096	阵营任务星级和环数
		action=	1201	请求分线详细数据
		action=	1203	请求所有时装数据
		action=	1206	请求脱下时装
		action=	1207	请求重置点数 
		action=	1209	请求所有 
		action=	1210	请求所有解锁大地图  
		action=	1212	请求vip奖励数据 
		action=	1214	请求首充续充奖励数据 
		action=	1216	请求运镖的活动状态
		action=	1220	请求佣兵灵魂链接列表 
		action=	1223	请求物品使用次数 
		action=	1224	请求镖车位置
		action=	1225	请求镖车次数 
		action=	1226	请求离线经验 
		action=	1228	请求找回系统数据 
		action=	1231	请求所有搬沙的详情
		action=	1232	请求考古重置
		action=	1233	请求金币购买
		action=	1234	请求金币购买次数
		action=	1235	请求全身装备星级 
		action=	1239	请求重置公会日常 
		action=	1240	请求公会五星全部完成任务 
		action=	1241	请求一键满星 
		action=	1242	请求领取10环奖励 
		action=	1243	请求工会奖励详细 
		action=	1246	领取宝箱奖励 
		action=	1247	请求佣兵星级奖励信息 
		action=	1249	请求装备详细信息 
		action=	1251	请求脱离卡死 
		action=	1253	周奖励数据 

		
	
		". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).
