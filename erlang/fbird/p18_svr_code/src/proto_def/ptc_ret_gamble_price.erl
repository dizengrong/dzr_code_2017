-module(ptc_ret_gamble_price).

-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#E125.

get_name() -> ret_gamble_price.

get_des() ->
	[
		 {sort,uint8,0},
		 {ids,{list,id_list},[]},
		 {diamo,uint16,0}
	].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).


