-module (ptc_entourage_die).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f023.

get_name() ->entourage_die.

get_des() ->
	[
	 {id,uint32,0}
	].

get_note() ->"".

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).