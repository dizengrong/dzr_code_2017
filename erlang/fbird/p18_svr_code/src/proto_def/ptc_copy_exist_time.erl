-module(ptc_copy_exist_time).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D223.

get_name() -> copy_exist_time.

get_des() ->
	[
	 {time_len,int32,0}
	].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).


