-module (ptc_system_time_zone).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f067.

get_name() ->system_time_zone.

get_des() ->
	[
	 {time_zone,int32,0}
	].

get_note() ->"
	时区
". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).