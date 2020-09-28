-module(ptc_sweep_copy_rewards_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D173.

get_name() -> copy_rewards_info.

get_des() ->
	[{item_list,{list,item_list},[]} ].
get_note() ->"副本奖励列表\r\n\t{item_num=奖励物品数量,item_type=奖励物品类型}".
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).