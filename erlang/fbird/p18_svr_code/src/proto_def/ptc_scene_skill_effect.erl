-module(ptc_scene_skill_effect).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#C006.

get_name() -> scene_skill_effect.

get_des() ->
	[
	 {error_code,uint32,0},
	 {oid,uint64,0},
	 {obj_sort,uint32,0},
	 {skill,uint32,0},
	 {lev,uint32,0},
	 {x,float,0},
	 {y,float,0},
	 {z,float,0},
	 {dir,float,0},
	 {target_id,uint64,0},
	 {target_x,float,0},
	 {target_y,float,0},
	 {target_z,float,0},
	 {shift_x,float,0},
	 {shift_y,float,0},
	 {shift_z,float,0},
	 {effect_list,{list,skill_effect},[]}
	].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).
