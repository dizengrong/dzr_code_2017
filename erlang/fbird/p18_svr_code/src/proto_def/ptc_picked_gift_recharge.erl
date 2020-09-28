-module(ptc_picked_gift_recharge).
-export([get_id/0,get_name/0,get_des/0,write/1]).

get_id()-> 16#D309.

get_name() -> picked_gift_recharge.

get_des() -> 
	[
	 {sort,uint32,0},
	 {type,uint32,0},
	 {items,{list,item_list},[]}
	 ].

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).



