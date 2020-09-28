-module(ptc_scene_chg_buff).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#C008.

get_name() -> scene_chg_buff.

get_des() ->
	[
	 {oid,uint64,0},
	 {obj_sort,uint32,0},
	 {adder_oid,uint32,0},
	 {adder_obj_sort,uint32,0},
	 {buff_type,uint32,0},
	 {buff_power,uint32,0},
	 {buff_mix_lev,uint32,0},
	 {buff_len,uint32,0}
	 ].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).
