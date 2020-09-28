-module(ptc_guild_call_upon_broadcast).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D194.

get_name() -> guild_call_upon_broadcast.

get_des() ->
	[ 
	 {call_upon_id,uint32,0}
	].

get_note() ->" ". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).