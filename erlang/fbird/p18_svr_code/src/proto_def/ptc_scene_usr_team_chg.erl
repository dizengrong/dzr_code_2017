-module(ptc_scene_usr_team_chg).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#C018.

get_name() -> scene_usr_team_chg.

get_des() ->
	[
	 {uid,uint64,0},
	 {team_id,uint32,0},
	 {team_leader,uint32,0}
	].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).
