-module(ptc_accept_task).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D015.

get_name() -> accept_task.

get_des() ->
	 [	 
	 	{taskid,uint32,0},
	 	{taskstep,uint32,0}	 
	 ].

get_note() ->"请求接受任务:\r\n\ttaskid=接受任务ID,taskstep=接受任务步骤".

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).



