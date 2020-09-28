-module (ptc_mining_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#E213.

get_name() -> mining_info.

get_des() ->
	[ 
	 {status,uint8,0},
	 {mining_left_seconds,uint32,0},
	 {protect_left_seconds,uint32,0},
	 {cur_gain,uint32,0},
	 {cur_max_gain,uint32,0},
	 {gain,uint32,0},
	 {grab,uint32,0},
	 {graped_times,uint16,0},
	 {grap_buy_times,uint16,0},
	 {inspire,uint16,0},
	 {exchange_times,{list, property_list},[]},
	 {defend_records,{list, mining_defend_des},[]}
	].

get_note() ->"". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).