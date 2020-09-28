-module(ptc_red_packet_surplus_time).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D189.

get_name() -> red_packet_surplus_time.

get_des() ->
	[ 
	 {surplus_time,uint32,0},
	 {red_packet_state,uint32,0},
	 {guild_rank,uint32,0},
	 {guild_ranklist_state,uint32,0},
	 {guild_payoff_state,uint32,0}
	  
	].

get_note() ->" ". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).