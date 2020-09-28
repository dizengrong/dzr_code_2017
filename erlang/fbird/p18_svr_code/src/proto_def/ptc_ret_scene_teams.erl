-module(ptc_ret_scene_teams).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#E110.

get_name() -> ret_scene_teams.

get_des() ->
	[
	
	 {team_info,{list,team_info},[]}
	 ].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).
