-module (ptc_home_building_mine_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D272.

get_name() -> home_building_mine_info.

get_des() ->
	[
	 {id,uint32,0},
	 {rest_upgrade_time,uint32,0},
	 {rest_res_num,uint32,0},
	 {worker_list,{list,home_building_worker_info},[]},
	 {assistant_list,{list,home_building_worker_info},[]},
	 {status,uint32,0}
	 ].

get_note() ->"". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).
