-module(ptc_expedition_task).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D24F.

get_name() -> exped_task.

get_des() ->
	[
	 {count,uint32,0},
	 {reflush_times,uint32,0},
	 {datas,{list,id_list},[]}
	].

get_note() ->"远征未进行的任务".

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).


