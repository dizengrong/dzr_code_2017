-module(ptc_gm_continu_recharge_close).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D25D.

get_name() -> gm_continu_recharge_close.

get_des() ->
	[
	 {start_time,uint32,0},
	 {end_time,uint32,0}		 
	].

get_note() ->"". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).


