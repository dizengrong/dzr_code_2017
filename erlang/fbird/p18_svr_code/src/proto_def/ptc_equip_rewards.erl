-module(ptc_equip_rewards).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D16B.

get_name() -> equip_rewards.

get_des() ->
	[{equip_rewards_list,{list,equip_rewards_list},[]} ].

get_note() ->"装备提升福利详细信息:\r\n\t{rewards_id = 奖励Id,rewards_state = 奖励状态}". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).