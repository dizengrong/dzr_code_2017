
-module(ptc_stroy_reward_info).


-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#F004.

get_name() -> stroy_reward_info.

get_des() ->
	[ 
	 {reward,{list,uint32},[]}
	].

get_note() ->" ". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).