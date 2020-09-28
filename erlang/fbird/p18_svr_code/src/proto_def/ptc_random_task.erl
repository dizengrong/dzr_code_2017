-module (ptc_random_task).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f018.

get_name() ->random_task.

get_des() ->
	[
	 {is_task,uint32,0},
	 {task_id,uint32,0},
	 {task1_num,uint32,0},
	 {task1_status,uint32,0},
	 {task2_num,uint32,0},
	 {task2_status,uint32,0},
	 {end_time,uint32,0},
	 {is_pop,uint32,0}
	].

get_note() ->"". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).