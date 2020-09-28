-module(ptc_team_war_seq).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D243.

get_name() -> team_war_seq.

get_des() ->
	[
	 {war_id,uint32,0}
	].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).



