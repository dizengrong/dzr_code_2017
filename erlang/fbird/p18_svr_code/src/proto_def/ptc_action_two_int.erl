-module(ptc_action_two_int).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D012.

get_name() -> action_two_int.

get_des() ->
	[ 
		 {action,int32,0},
	 	 {data_One,uint64,0},
	 	 {data_Two,uint64,0}
	].

get_note() ->"
			1003	追随者装备(传入追随者ID,和物品ID)
			1004	技能升级(传入追随者ID,和技能ID)
			1007	出售物品(物品实例化ID,数量)
			1014	请求穿戴符文(技能ID,符文ID)
			1015	装备物品(物品实例化ID,数量)
			1037	回复请求加入公会申请(目标玩家ID,是否同意[1,同意|2,不同意])
			1040	请求职位变更(目标玩家ID,目标职位)
			1055	升级公会建筑(目标公会建ID,公会资源数量)
			1065	公会副本战利品申请排队(场景ID,物品ID)
			1080	请求抽奖(奖励ID,抽奖类型)
			1091	删除任务(任务ID,任务步骤)
			1217	请求任务失败(任务ID,任务步骤)
			1221	请求佣兵灵魂添加链接  (孔位, 佣兵id)
			1222	请求佣兵灵魂取消链接  (孔位, 佣兵id)
			1229	请求领取找回系统 (系统ID,哪个类型（a级，还是S级）)
			1236	请求任务奖励 (任务ID,任务步骤)
			1244	解锁皇家宝箱(皇家宝箱ID，[1普通解锁，其他钻石解锁])



". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).