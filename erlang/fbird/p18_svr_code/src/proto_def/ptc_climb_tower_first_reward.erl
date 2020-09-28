-module(ptc_climb_tower_first_reward).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D255.

get_name() -> climb_tower_first_reward.

get_des() -> [{tower_id,uint32,0}].

get_note() ->"climb tower reward".

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).



