-module (ptc_maze_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f049.

get_name() ->maze_info.

get_des() ->
	[
	 {state,uint32,0},
	 {has_settled,uint32,0},
	 {power,uint32,0},
	 {buy_times,uint32,0},
	 {lucky,uint32,0},
	 {bagdge,uint32,0},
	 {inspare,uint32,0},
	 {re_time,uint32,0},
	 {step,uint32,0},
	 {rewards,{list,item_list},[]},
	 {records,{list,maze_record},[]}
	].

get_note() ->"
	state = 是否在迷宫
	has_settled = 今天是否结算
	power = 体力
	buy_times = 购买次数
	lucky = 幸运值
	bagdge = 背包等级
	inspare = 鼓舞等级
	re_time = 回复时间
	step = 阶段奖励
	rewards = 奖励列表
	records = 战斗记录
". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).