-module(ptc_scene_skill_aleret_cancel).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#C022.

get_name() -> scene_skill_aleret_cancel.

get_des() ->
	[
	 {skill,uint32,0},
	 {lev,uint32,0},
	 {oid,uint32,0},
	 {obj_sort,uint32,0}
	 ].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).
