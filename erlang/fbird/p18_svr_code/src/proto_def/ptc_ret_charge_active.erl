-module(ptc_ret_charge_active).

-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#E11C.

get_name() -> ret_charge_active.

get_des() ->
	[ 
	     {rewards,{list,charge_active},[]}
		
	].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).


