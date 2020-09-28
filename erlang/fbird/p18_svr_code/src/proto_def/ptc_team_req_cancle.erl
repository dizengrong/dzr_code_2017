-module(ptc_team_req_cancle).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D032.

get_name() -> team_req_cancle.

get_des() ->
	[
	 {req_uid,uint64,0}
	].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).