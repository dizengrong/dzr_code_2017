-module(ptc_usr_enter).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#B001.

get_name() -> usr_enter.

get_des() ->
	[
	 {uid,uint64,0},
	 {key,uint32,0}
	 ].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).
