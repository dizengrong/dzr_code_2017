-module(ptc_system_time).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D236.

get_name() -> system_time.

get_des() ->
	 [
	  {time_zone,int32,0},
	  {time,int32,0}
	 ].

get_note() ->"". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).