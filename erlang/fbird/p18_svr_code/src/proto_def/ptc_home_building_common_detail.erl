-module (ptc_home_building_common_detail).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D271.

get_name() -> home_building_common_detail.

get_des() ->
	[
	 {id,uint32,0},
	 {rest_upgrade_time,uint32,0}
	 ].

get_note() ->"". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).
