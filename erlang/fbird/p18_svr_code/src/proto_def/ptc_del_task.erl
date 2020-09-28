-module(ptc_del_task).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D017.

get_name() -> del_task.

get_des() ->
	 [	 
	 	{taskid,uint32,0},
	 	{taskstep,uint32,0}	 	 
	 ].

get_note() ->"删除任务:\r\n\t
				{taskid=任务ID,taskstep=任务步骤}". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).



