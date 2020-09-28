-module (ptc_ggb_battle_log).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#E205.

get_name() -> ggb_battle_log.

get_des() ->
	[ 
	 {status,uint8,0},
	 {logs,{list,ggb_battle_record},[]}
	].

get_note() ->"跨服战战斗记录". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).