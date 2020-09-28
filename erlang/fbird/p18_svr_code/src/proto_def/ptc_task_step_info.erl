-module(ptc_task_step_info).

-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f00a.

get_name() -> task_step_info.

get_des() ->
	[
		 {step,uint32,0}, 
		 {num,uint32,0},
		 {status,uint32,0},
		 {sort,uint32,0}
	].

get_note() ->"". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).