-module (ptc_scene_change_camp).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f05a.

get_name() -> scene_change_camp.

get_des() ->
	[
	 {id,uint64,0},
	 {new_camp,uint32,0}
	].

get_note() ->"".

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).