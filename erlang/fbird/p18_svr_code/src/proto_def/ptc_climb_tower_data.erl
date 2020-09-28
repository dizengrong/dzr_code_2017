-module(ptc_climb_tower_data).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D252.

get_name() -> climb_tower_data.

get_des() ->
	[
		{curr_tower,uint32,0},
		{max_tower,uint32,0},
		{rank,uint32,0},
		{times,uint32,0},
		{rewards,{list,climb_tower_first_reward},[]}
	].

get_note() ->"climb tower data".

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).



