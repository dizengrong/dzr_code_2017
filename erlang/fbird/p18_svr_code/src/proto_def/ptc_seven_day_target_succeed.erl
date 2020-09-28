-module(ptc_seven_day_target_succeed).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D185.

get_name() -> seven_day_target_succeed.

get_des() ->
	[{item_list,{list,item_list},[]}].

get_note() ->"七日目标奖励领取成功". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).