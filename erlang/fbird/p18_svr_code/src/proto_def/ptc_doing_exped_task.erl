-module(ptc_doing_exped_task).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D24E.

get_name() -> doing_exped_task.

get_des() ->
	[
	 {datas,{list,expedition_list},[]}	 
	].

get_note() ->"远征进行中的任务".

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).



