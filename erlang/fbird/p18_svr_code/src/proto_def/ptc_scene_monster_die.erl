-module (ptc_scene_monster_die).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f088.

get_name() -> scene_monster_die.

get_des() ->
	[
	 {id,int32,0}
	].

get_note() ->"".

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).