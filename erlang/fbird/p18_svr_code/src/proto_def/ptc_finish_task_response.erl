-module(ptc_finish_task_response).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D019.

get_name() -> finish_task_response.

get_des() ->
	 [	 
	 	{taskid,uint32,0},
	 	{taskstep,uint32,0}		 	 
	 ].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).


