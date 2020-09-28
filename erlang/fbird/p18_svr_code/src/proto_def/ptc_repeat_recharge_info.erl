-module(ptc_repeat_recharge_info).
-export([get_id/0,get_name/0,get_des/0,write/1]).

get_id()-> 16#D303.

get_name() -> repeat_recharge_info.

get_des() -> 
	[
	 {startTime,uint32,0},
	 {endTime,uint32,0},
	 {repeatNum,uint32,0},
	 {repeatTimes,uint32,0},
	 {allNum,uint32,0},
	 {pickTimes,uint32,0},
	 {repeats,{list,repeat_des},[]}
	 ].

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).