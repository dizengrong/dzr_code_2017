-module (ptc_home_building_req_produce).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D275.

get_name() -> home_building_req_produce.

get_des() ->
	[
	 {id,uint32,0},
	 {idx_list,{list,uint8},[]}
	 ].

get_note() ->"". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).
