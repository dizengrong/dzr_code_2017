-module(ptc_scene_skill_aleret).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#C021.

get_name() -> scene_skill_aleret.

get_des() ->
	[
	 {skill,uint32,0},
	 {lev,uint32,0},
	 {oid,uint32,0},
	 {obj_sort,uint32,0},
	 {x,float,0},
	 {y,float,0},
	 {z,float,0},
	 {dir,float,0},
	 {target_id,uint32,0},
	 {target_x,float,0},
	 {target_y,float,0},
	 {target_z,float,0},
	 {aleret_x,float,0},
	 {aleret_y,float,0},
	 {aleret_z,float,0},
	 {aleret_dir,float,0}
	 ].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).
