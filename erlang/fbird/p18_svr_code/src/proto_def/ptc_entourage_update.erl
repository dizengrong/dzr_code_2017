-module (ptc_entourage_update).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f131.

get_name() ->entourage_update.

get_des() ->
	[
	 {chnage_type,uint8,0},
	 {eid,uint32,0}
	].

get_note() ->"1:升级 2:升品 3:升星". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).

