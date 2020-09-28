-module(ptc_treasure_times).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D408.

get_name() -> treasure_times.

get_des() ->
	[ 
	 {times,uint32,0}
	].

get_note() ->" ". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).