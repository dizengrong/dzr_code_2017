-module(ptc_lost_item).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D009.

get_name() -> lost_item.

get_des() ->
	[
	 {lost_item_total_num,uint32,0},
	 {active_id,uint32,0},	 
	 {lost_item_list,{list,lost_list},[]}
	 ].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).