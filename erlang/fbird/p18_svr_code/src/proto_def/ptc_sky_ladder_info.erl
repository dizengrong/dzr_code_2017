-module(ptc_sky_ladder_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D266.

get_name() -> sky_ladder_info.

get_des() ->
	[
	 	{rank,int32,0},
		{total,int32,0},
		{win,int32,0},
		{lose,int32,0},
		{score,int32,0},
		{max_score,int32,0},		
		{reward_time,int32,0},
		{first_reward,int32,0}
	].

get_note() ->"天梯信息". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).


