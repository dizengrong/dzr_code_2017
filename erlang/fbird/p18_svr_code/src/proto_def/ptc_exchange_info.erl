-module(ptc_exchange_info).
-export([get_id/0,get_name/0,get_des/0,write/1]).

get_id()-> 16#D30A.

get_name() -> exchange_info.

get_des() -> 
	[
	 {startTime,uint32,0},
	 {endTime,uint32,0},
	 {type,uint32,0},
	 {exchanges,{list,exchange_des},[]}
	 ].

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).