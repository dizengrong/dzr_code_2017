-module(ptc_action_float).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D005.

get_name() -> action_float.

get_des() ->
	[
	 {action,int32,0},
	 {data,float,0}
	 ].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).
