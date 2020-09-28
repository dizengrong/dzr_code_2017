-module (ptc_gm_act_double).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f112.

get_name() ->gm_act_double.

get_des() ->
	[
	 {startTime,uint32,0},
	 {endTime,uint32,0},
	 {desc,string,""},
	 {datas,{list,gm_act_double_des},[]}
	].

get_note() ->"". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).