-module(ptc_finish_task).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D016.

get_name() -> finish_task.

get_des() ->
	 [	 
	 	{taskid,uint32,0},
	 	{taskstep,uint32,0}	 	 
	 ].

get_note() ->"请求完成任务:\r\n\t
		taskid=任务ID,taskstep=任务步骤". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).


