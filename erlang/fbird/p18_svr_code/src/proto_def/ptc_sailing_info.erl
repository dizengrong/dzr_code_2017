-module (ptc_sailing_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f051.

get_name() ->sailing_info.

get_des() ->
	[
	 {type,uint32,0},
	 {status,uint32,0},
	 {sailing_time,uint32,0},
	 {buy_times,uint32,0},
	 {has_be_plunder,uint32,0},
	 {inspire,uint32,0},
	 {succ_guard_time,uint32,0},
	 {guard_name,string,""},
	 {guard_head,uint32,0},
	 {end_time,uint32,0},
	 {sailing_records,{list,sailing_record},[]}
	].

get_note() ->"".

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).