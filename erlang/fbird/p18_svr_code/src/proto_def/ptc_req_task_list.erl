-module(ptc_req_task_list).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D01c.

get_name() -> req_task_list.

get_des() ->
	 [ 
	 ].

get_note() ->"请求任务列表". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).


