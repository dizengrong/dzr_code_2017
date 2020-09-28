-module (ptc_home_building_factory_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D274.

get_name() -> home_building_factory_info.

get_des() ->
	[
	 {id,uint32,0},
	 {status,uint32,0},
	 {rest_upgrade_time,uint32,0},
	 {rest_produce_time,uint32,0},
	 {rest_produce_cd,uint32,0},
	 {items,{list,item_list},[]}
	 ].

get_note() ->"". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).
