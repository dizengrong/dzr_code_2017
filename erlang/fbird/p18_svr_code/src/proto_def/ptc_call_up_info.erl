-module(ptc_call_up_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D197.

get_name() -> call_up_info.

get_des() ->
	[ 
	 {call_up_id,uint32,0},
	 {uid,uint64,0},
	 {name,string,""},
	 {sceneid,uint32,0}
	].

get_note() ->" ". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).