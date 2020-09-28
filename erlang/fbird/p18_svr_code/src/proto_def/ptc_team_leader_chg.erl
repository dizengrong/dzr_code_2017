-module(ptc_team_leader_chg).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D028.

get_name() -> team_leader_chg.

get_des() ->
	[
	 {new_leader_uid,uint64,0}
	].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).