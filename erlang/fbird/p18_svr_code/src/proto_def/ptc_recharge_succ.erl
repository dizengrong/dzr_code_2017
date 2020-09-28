-module(ptc_recharge_succ).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D232.

get_name() -> recharge_succ.

get_des() ->
	 [
	  {recharge_id,int32,0}
	 ].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).


