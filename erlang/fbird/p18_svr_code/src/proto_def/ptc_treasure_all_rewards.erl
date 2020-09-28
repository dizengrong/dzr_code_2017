-module(ptc_treasure_all_rewards).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D407.

get_name() -> treasure_all_rewards.

get_des() ->
	[ 
	  {out_of_item_type,uint32,0},
	  {out_of_item_num,uint32,0},
	  {treasure_rewards_info,{list,treasure_rewards_info},[]}
	].

get_note() ->"宝藏能够获得的奖励". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).