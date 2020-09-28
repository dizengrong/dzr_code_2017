-module(ptc_arena_start_time).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D230.

get_name() -> arena_start_time.

get_des() ->
	 [
	  	{start_time,int32,0}
	 ].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).



