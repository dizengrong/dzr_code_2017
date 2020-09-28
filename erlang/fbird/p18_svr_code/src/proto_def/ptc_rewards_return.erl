-module(ptc_rewards_return).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D122.

get_name() -> rewards_return.

get_des() ->
	[
		 {rewards_type,int32,0}, 
		 {rewards_state,int32,0},
		 {rewards_receive_list,{list,rewards_receive_list},[]} 
	].

get_note() ->"七日登陆奖励和等级奖励详细信息\r\n\t
				{rewards_receive_list=已经领取的奖励列表,rewards_state=能够领取的条件,rewards_type=奖励的类型（1,签到|2,等级|3,在线）}". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).