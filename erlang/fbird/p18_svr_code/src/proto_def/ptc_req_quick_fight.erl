-module(ptc_req_quick_fight).

-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#C100.

get_name() -> req_quick_fight.

get_des() ->
	 [
	  {req_type,uint32,0}
	 ].

get_note() ->"请求快速战斗". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).


