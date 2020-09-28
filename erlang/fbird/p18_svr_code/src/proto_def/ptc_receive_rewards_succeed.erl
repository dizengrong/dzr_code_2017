-module(ptc_receive_rewards_succeed).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D121.

get_name() -> receive_rewards_succeed.

get_des() ->
	[{get_success_list,{list,get_success_list},[]}].

get_note() ->"(七日和等级)奖励领取成功\r\n\t
			
			{success_action={1,等级|2,七日},success_data=奖励ID}	
			". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).