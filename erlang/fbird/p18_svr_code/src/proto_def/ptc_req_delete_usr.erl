-module(ptc_req_delete_usr).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#A008.

get_name() -> req_delete_usr.

get_des() ->
	[
	 {uid,uint64,0}
	 ].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).
