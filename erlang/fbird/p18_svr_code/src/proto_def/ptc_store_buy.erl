-module(ptc_store_buy).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D034.

get_name() -> store_buy.

get_des() ->
	[
	 {store_id,uint32,0},
	 {cell_id,uint32,0},
	 {buy_num,uint32,0}
	].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).