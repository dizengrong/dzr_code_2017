-module(ptc_ret_war_usr_area).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).
get_id()-> 16#E12B.

get_name() -> ret_war_usr_area.

get_des() ->
	[ 
	  {area,uint32,0}
	].

get_note() ->"战场玩家位置". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).


