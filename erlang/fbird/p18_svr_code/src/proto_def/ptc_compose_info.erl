-module(ptc_compose_info).
-export([get_id/0,get_name/0,get_des/0,write/1]).

get_id()-> 16#D310.

get_name() -> compose_info.

get_des() ->
	[
	 {action,uint32,0},
	 {new_equip_id,uint32,0},
	 {free_time,uint32,0},
	 {refresh_time,uint32,0},
	 {refresh_num,uint32,0},
	 {item1,uint32,0},
	 {item2,uint32,0},
	 {item3,uint32,0},
	 {item1_property,{list,uint32},[]},
	 {item2_property,{list,uint32},[]},
	 {item3_property,{list,uint32},[]},
	 {item1_cost,uint32,0},
	 {item1_price,uint32,0},
	 {item2_cost,uint32,0},
	 {item2_price,uint32,0},
	 {item3_cost,uint32,0},
	 {item3_price,uint32,0}
	].

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).