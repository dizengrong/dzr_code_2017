-module(ptc_team_member_chg).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D023.

get_name() -> team_member_chg.

get_des() ->
	[
	 {team_member_list,{list,team_member_list},[]}
	].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).