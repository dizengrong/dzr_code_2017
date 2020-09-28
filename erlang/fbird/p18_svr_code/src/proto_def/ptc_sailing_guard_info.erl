-module (ptc_sailing_guard_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f053.

get_name() ->sailing_guard_info.

get_des() ->
	[
	 {guard_time,uint32,0},
	 {guard_type,uint32,0},
	 {guard_list,{list,guard_list},[]}
	].

get_note() ->"".

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).