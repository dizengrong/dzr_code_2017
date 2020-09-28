-module (ptc_req_fly_planes).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D320.

get_name() -> req_fly_planes.

get_des() ->
	[
	 {id,int32,0}
	 ].

get_note() ->"". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).
