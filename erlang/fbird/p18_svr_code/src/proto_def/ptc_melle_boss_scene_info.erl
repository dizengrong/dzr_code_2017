-module (ptc_melle_boss_scene_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f05b.

get_name() -> melle_boss_scene_info.

get_des() ->
	[
	 {owner_id,uint64,0},
	 {owner_hp,uint32,0},
	 {boss_id,uint32,0},
	 {boss_hp,uint32,0}
	].

get_note() ->"".

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).