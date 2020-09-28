-module(ptc_seven_day_target_status).

-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#F00B.

get_name() -> seven_day_target_status.

get_des() ->
	[
		 {status,uint32,0},
		 {activitieid,uint32,0}
	].

get_note() ->"". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).