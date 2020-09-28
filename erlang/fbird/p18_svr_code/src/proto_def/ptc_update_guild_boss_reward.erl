-module(ptc_update_guild_boss_reward).

-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#C103.

get_name() -> update_guild_boss_reward.

get_des() ->
	[
	 {my_damage,uint32,0},
	 {damage_reward_list,{list,id_list},[]},
	 {kill_reward_list,{list,id_list},[]}
	].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).


