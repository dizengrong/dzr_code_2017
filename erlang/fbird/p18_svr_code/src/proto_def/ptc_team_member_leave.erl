-module(ptc_team_member_leave).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D029.

get_name() -> team_member_leave.

get_des() ->
	[
	 {leave_uid,uint64,0}
	].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).