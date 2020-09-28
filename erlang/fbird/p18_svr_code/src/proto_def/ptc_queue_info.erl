-module(ptc_queue_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#A104.

get_name() -> queue_info.

get_des() ->
	[
	 {max_num,uint32,0},
	 {cur_num,uint32,0}
	].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).
