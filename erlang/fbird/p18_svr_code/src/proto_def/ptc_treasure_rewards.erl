-module(ptc_treasure_rewards).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D405.

get_name() -> treasure_rewards.

get_des() ->
	[ 
	 {treasure_rewards_info,{list,treasure_rewards_info},[]}
	].

get_note() ->"领取宝藏奖励显示". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).