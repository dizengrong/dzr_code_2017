
-module(ptc_task_step).

-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#F005.

get_name() -> task_step.

get_des() ->
	[
		 {id,uint32,0},
		 {status,uint32,0}
	].

get_note() ->"". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).