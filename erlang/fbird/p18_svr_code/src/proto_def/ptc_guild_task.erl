-module(ptc_guild_task).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D166.

get_name() -> guild_task.

get_des() ->
	[	 {guild_task_reset_num,uint32,0},
		 {guild_task_star,uint32,0},
		 {guild_task_loop,uint32,0},
		 {guild_task_rewards_state,uint32,0}
	].

get_note() ->"公会任务信息:\r\n\t
			{guild_task_reset_num=重置次数,guild_task_rewards_state=公会任务奖励状态,guild_task_loop=已做了公会任务次数,guild_task_star=现在公会任务星级}". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).