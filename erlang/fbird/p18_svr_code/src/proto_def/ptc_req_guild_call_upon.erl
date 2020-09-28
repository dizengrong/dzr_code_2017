-module(ptc_req_guild_call_upon).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D193.

get_name() -> req_guild_call_upon.

get_des() ->
	[ 
	 {call_upon_id,uint32,0},
	 {min_lev,uint32,0},
	 {min_gs,uint32,0},
	 {min_post,uint32,0}
	].

get_note() ->" ". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).