-module(ptc_task_rewards_succeed).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D133.

get_name() -> task_rewards_succeed.

get_des() ->
	[{get_success_list,{list,get_success_list},[]}].

get_note() ->"任务奖励领取成功\r\n\t
			{success_action=行为ID,success_data=玩家ID}". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).