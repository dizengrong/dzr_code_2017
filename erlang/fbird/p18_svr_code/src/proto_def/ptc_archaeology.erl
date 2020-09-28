-module(ptc_archaeology).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D130.

get_name() -> archaeology.

get_des() ->
	[ 
		 {archaeology_id,uint32,0},
		 {archaeology_time,uint32,0},
		 {refresh_time,uint32,0},
		 {add_rewards_time,uint32,0},
		 {add_rewards_succeed,uint32,0}
	].

get_note() ->"考古的详细信息:\r\n\t{archaeology_id=考古的ID,archaeology_time=考古的次数,refresh_time=考古的重置次数}". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).