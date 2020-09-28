-module(ptc_red_packet_rewards).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D190.

get_name() -> red_packet_rewards.

get_des() ->
	[ 
	 {packet_rewards_num,uint32,0}
	].

get_note() ->" ". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).