-module (ptc_ggb_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#E200.

get_name() -> ggb_info.

get_des() ->
	[ 
	 {status,uint8,0},
	 {total_server,uint8,0},
	 {is_candidate,uint8,0},
	 {promotion_result,uint8,0},
	 {first_period,{list,ggb_first_period_detail},[]},
	 {second_period,{list,ggb_second_period_detail},[]}
	].

get_note() ->"跨服战信息". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).