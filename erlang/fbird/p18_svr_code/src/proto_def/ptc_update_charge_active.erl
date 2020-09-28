-module(ptc_update_charge_active).


-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#E11D.

get_name() -> update_charge_active.

get_des() ->
	[ 
		 {sort,int8,0},
	 	 {reward,int32,0}
	].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).

