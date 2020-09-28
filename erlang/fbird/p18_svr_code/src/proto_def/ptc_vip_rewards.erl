-module(ptc_vip_rewards).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D149.

get_name() -> vip_rewards.

get_des() ->
	[{vip_rewards_list,{list,vip_rewards_list},[]}  ].

get_note() ->"VIP奖励领取详细信息：\r\n\t{vip_rewards_id = Rewards}". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).