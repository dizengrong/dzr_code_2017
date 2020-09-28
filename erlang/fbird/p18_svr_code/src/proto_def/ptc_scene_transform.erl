-module(ptc_scene_transform).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#C013.

get_name() -> scene_transform.

get_des() ->
	[	 
	 {oid,uint64,0},
	 {obj_sort,uint32,0},
	 {type,uint32,0},
	 {time,float,0},	 
	 {x,float,0},
	 {y,float,0},
	 {z,float,0}	 	
	 ].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).
