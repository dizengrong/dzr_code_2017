-module(ptc_fortress_task_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D172.

get_name() ->fortress_task_info.

get_des() ->
	[
	 {task_id,uint32,0},
	 {task_step,uint32,0},
	 {task_star,uint32,0},
	 {task_loop,uint32,0}
	].
get_note() ->"要塞任务：\r\n\t
			task_id=任务ID,task_step=任务步骤,task_star=任务星级".
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).