-module(ptc_loginact_info).
-export([get_id/0,get_name/0,get_des/0,write/1]).

get_id()-> 16#D30C.

get_name() -> loginact_info.

get_des() -> 
	[
	 {startTime,uint32,0},
	 {endTime,uint32,0},
	 {loginDays,uint32,0},
	 {diamond,uint32,0},
	 {loginacts,{list,loginact_des},[]}
	 ].

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).