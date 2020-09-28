-module(ptc_lost_item_activate).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D01e.

get_name() -> lost_item_active.

get_des() ->
	 [
	 {itemid,uint32,0}	 
	 ].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).


