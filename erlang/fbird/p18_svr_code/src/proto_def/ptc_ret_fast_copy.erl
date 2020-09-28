-module(ptc_ret_fast_copy).

-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#E127.

get_name() -> ret_fast_copy.

get_des() ->
	[    {id,uint32,0},
		 {times,uint8,0},
		 {items,{list,item_list},[]}
	].

get_note() ->"". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).


