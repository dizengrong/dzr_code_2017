-module(ptc_relife_task_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#F00E.

get_name() -> relife_task_info.

get_des() ->
	[
	 {time,uint32,0},
	 {relife_task_info,{list,relife_task_info},[]}
	].

get_note() ->"转生任务详情". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).