-module(ptc_ret_ride_prop).

-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#E112.

get_name() -> ret_ride_prop.

get_des() ->
	[
	 {props,{list,prop_entry},[]}
	 ].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).


