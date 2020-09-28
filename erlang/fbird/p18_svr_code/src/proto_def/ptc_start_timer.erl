-module(ptc_start_timer).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D212.

get_name() -> start_timer.

get_des() ->
	 [
	 {timelen,uint32,0}		 
	 ].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).



