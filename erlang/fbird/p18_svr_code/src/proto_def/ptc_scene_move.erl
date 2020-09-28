-module(ptc_scene_move).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#C001.

get_name() -> scene_move.

get_des() ->
	[
	 {oid,uint64,0},
	 {obj_sort,uint32,0},
	 {dir,float,0},
	 {is_path_move,uint8,0},
	 {point_list,{list,point3},[]}
	 ].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).
