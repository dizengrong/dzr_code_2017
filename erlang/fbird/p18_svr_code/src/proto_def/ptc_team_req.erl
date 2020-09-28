-module(ptc_team_req).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D026.

get_name() -> team_req.

get_des() ->
	[
	 {req_uid,uint64,0},
	 {req_name,string,""},
	  {req_lev,uint8,0}
	].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).