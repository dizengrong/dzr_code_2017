-module(ptc_gift_recharge_info).
-export([get_id/0,get_name/0,get_des/0,write/1]).

get_id()-> 16#D304.

get_name() -> gift_recharge_info.

get_des() -> 
	[
	 {startTime,uint32,0},
	 {endTime,uint32,0},
	 {allRecharge,uint32,0},
	 {allSpend,uint32,0},
	 {dayRecharge,uint32,0},
	 {daySpend,uint32,0},
	 {gifts,{list,gift_des},[]}
	 ].

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).