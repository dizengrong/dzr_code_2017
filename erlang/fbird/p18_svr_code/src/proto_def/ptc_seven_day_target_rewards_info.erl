-module(ptc_seven_day_target_rewards_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D184.

get_name() -> seven_day_target_rewards_info.

get_des() ->
	[ {day,uint32,0},
	  {seven_day_target_rewards_list,{list,seven_day_target_rewards_list},[]}
	].

get_note() ->"七日目标奖励领取详细信息". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).
