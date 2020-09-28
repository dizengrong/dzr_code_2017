-module(ptc_entourage_star_rewards).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D16A.

get_name() -> entourage_star_rewards.

get_des() ->
	[{entourage_star_rewards_list,{list,entourage_star_rewards},[]} ].

get_note() ->"英雄觉醒福利:\r\n\t
				{rewards_id = 英雄觉醒福利奖励ID,rewards_state = 英雄觉醒福利奖励状态}". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).