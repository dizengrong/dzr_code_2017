-module(ptc_copy_time_rewards).

-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D411.

get_name() -> copy_time_rewards.

get_des() ->
	[ {copy_time,uint32,0},
	  {copy_time_rewards_list,{list,uint32},[]}
	].

get_note() ->"". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).