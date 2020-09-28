-module(ptc_team_ans_req).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D027.

get_name() -> team_ans_req.

get_des() ->
	[
	 {ans_uid,uint64,0},
	 {ans,uint32,0}
	].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).