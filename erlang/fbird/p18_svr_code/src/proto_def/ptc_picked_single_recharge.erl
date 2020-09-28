-module(ptc_picked_single_recharge).
-export([get_id/0,get_name/0,get_des/0,write/1]).

get_id()-> 16#D307.

get_name() -> picked_single_recharge.

get_des() -> 
	[
	 {type,uint32,0},
	 {items,{list,item_list},[]}
	 ].

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).



