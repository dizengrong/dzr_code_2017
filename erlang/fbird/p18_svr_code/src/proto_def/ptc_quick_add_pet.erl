-module(ptc_quick_add_pet).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D225.

get_name() -> req_quick_add_pet.

get_des() ->
	 [
	   {type_id,uint32,0}
	 ].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).



