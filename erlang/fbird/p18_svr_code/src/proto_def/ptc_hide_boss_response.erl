-module(ptc_hide_boss_response).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D247.

get_name() -> hide_boss_response.

get_des() ->
	[
	 {sort,int32,0},
	 {boss_id,int32,0}
	].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).


