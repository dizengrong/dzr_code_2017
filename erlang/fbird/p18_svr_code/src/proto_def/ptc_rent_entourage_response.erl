-module(ptc_rent_entourage_response).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D24D.

get_name() -> rent_entourage.

get_des() ->
	[
	 {type,int32,0},
	 {time,int32,0}
	].

get_note() ->"租英雄返回".

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).


