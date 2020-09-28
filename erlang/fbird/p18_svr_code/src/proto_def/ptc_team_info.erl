-module(ptc_team_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D022.

get_name() -> team_info.

get_des() ->
	[
	 {team_id,uint32,0},
	 {leader_id,uint64,0},
	 {target,uint64,0},
	 {team_member_list,{list,team_member_list},[]}
	].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).