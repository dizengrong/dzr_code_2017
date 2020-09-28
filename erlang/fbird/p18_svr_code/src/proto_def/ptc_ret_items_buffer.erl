-module(ptc_ret_items_buffer).

-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#E126.

get_name() -> ret_items_buffer.

get_des() ->
	[ {way,uint16,0},
	  {items,{list,item_list},[]}
	].

get_note() ->"下行物品池，可领取". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).