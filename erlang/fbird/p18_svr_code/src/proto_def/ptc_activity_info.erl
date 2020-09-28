-module(ptc_activity_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D106.

get_name() -> activity_info.

get_des() ->
	[ 
	 {activity_val,uint32,0},
	 {activity_info,{list,activity_info},[]},
	 {activity_rewards,{list,uint32},[]}
	    
	].

get_note() ->"跃度数据详情:\r\n\tactivity_rewards=活跃度领取奖励,activity_val = 现在活跃度数值,activity_info=活跃度详情（activity_id=活跃度ID,activity_time=活跃度次数）". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).