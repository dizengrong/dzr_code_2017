-module (ptc_system_activity).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f019.

get_name() ->system_activity.

get_des() ->
	[
	 {id,uint32,0},
	 {status,uint32,0}
	].

get_note() ->"". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).