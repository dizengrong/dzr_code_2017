-module(ptc_turning_wheel_hide).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D260.

get_name() -> turning_wheel_hide.

get_des() ->
	[
	 {start_time,uint32,0},
	 {end_time,uint32,0}	 
	].

get_note() ->"". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).



