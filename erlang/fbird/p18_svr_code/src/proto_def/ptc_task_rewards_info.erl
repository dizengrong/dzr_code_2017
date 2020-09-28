-module(ptc_task_rewards_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D165.

get_name() -> task_rewards_info.

get_des() ->
	[ 
	 {task_id,uint32,0},
	 {task_step,uint32,0},	 
	 {task_rewards_list,{list,task_rewards_list},[]} 
	].

get_note() ->"获取该任务的奖励详情：\r\n\t
				task_id = 任务ID
				task_step = 任务步骤
				task_rewards_list = 任务奖励列表{item_id=物品ID,item_num=物品数量}
			". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).