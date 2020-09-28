-module(ptc_wanted_task).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D132.

get_name() -> wanted_task.

get_des() ->
	[	 {wanted_reset_num,uint32,0},
		 {wanted_task_star,uint32,0},
		 {wanted_task_loop,uint32,0},
		 {wanted_rewards_state,uint32,0}
	].

get_note() ->"悬赏任务详细信息：\r\n\t
			{wanted_reset_num=悬赏任务重置次数,wanted_rewards_state=悬赏任务奖励领取状态,wanted_task_loop=悬赏任务已完成次数,wanted_task_star=悬赏任务星级}". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).