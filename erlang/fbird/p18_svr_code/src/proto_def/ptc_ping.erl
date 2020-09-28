-module(ptc_ping).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#A10A.

get_name() -> ping.

get_des() ->
	 [
	 ].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).


