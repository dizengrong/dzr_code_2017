-module (ptc_home_building_list).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D270.

get_name() -> home_building_list.

get_des() ->
	[
	 {uid,uint64,0},
	 {building_list,{list,home_building_base_info},[]}
	 ].

get_note() ->"". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).
