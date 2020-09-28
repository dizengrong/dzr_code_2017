-module (ptc_gm_act_recharge_point).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f047.

get_name() ->gm_act_recharge_point.

get_des() ->
	[
	 {startTime,uint32,0},
	 {endTime,uint32,0},
	 {close_time,uint32,0},
	 {desc,string,""},
	 {datas,{list,act_recharge_point_des},[]}
	].

get_note() ->"". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).