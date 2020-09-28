-module (ptc_ggb_battle_waiting).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#E208.

get_name() -> ggb_battle_waiting.

get_des() ->
	[ 
	 {waiting_seconds,uint32,0}
	].

get_note() ->"跨服战斗开始前的等待时间". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).