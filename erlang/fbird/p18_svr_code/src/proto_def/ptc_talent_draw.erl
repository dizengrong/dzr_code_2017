-module (ptc_talent_draw).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#E211.

get_name() -> talent_draw.

get_des() ->
	[ 
	 {draw_id,{list,uint32},[]},
	 {items,{list,item_list},[]}
	].

get_note() ->"". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).