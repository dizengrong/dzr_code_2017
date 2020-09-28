-module(ptc_single_recharge_info).
-export([get_id/0,get_name/0,get_des/0,write/1]).

get_id()-> 16#D302.

get_name() -> single_recharge_info.

get_des() -> 
	[
	 {startTime,uint32,0},
	 {endTime,uint32,0},
	 {singles,{list,single_des},[]}
	 ].

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).



