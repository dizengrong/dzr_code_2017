-module(ptc_store_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D033.

get_name() -> store_info.

get_des() ->
	[
	 {store_id,uint32,0},
	 {auto_fresh_time,uint32,0},
	 {fresh_times,uint32,0},
	 {cell_list,{list,store_cell_info},[]},
	 {show_cell_list,{list,store_cell_info},[]}
	].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).