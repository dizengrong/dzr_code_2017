-module(ptc_match_submit_ready).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D219.

get_name() -> submit_ready.

get_des() ->
	 [	 
	 	{name,string,""} 	 
	 ].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).


