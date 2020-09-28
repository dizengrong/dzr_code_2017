-module(ptc_scene_remove_buff).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#C009.

get_name() -> scene_remove_buff.

get_des() ->
	[
	 {oid,uint64,0},
	 {obj_sort,uint32,0},
	 {buff_type,uint32,0}
	 ].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).
