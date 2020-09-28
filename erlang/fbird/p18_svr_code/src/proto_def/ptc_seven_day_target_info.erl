-module(ptc_seven_day_target_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D183.

get_name() -> seven_day_target_info.

get_des() ->
	[
	 {seven_day_target_info_list,{list,seven_day_target_info_list},[]}
	].

get_note() ->"七日目标奖励单日详细信息". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).