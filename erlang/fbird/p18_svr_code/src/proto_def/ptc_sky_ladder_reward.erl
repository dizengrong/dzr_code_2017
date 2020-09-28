-module(ptc_sky_ladder_reward).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D267.

get_name() -> sky_ladder_reward.

get_des() ->
	[
		{rewards,{list,reward_info},[]}
	].

get_note() ->"天梯奖励". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).


