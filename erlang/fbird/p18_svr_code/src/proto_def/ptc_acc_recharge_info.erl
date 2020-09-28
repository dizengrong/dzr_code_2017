-module (ptc_acc_recharge_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f10d.

get_name() ->acc_recharge_info.

get_des() ->
	[
	 {startTime,uint32,0},
	 {endTime,uint32,0},
	 {picture,string,""},
	 {datas,{list,acc_recharge_des},[]}
	].

get_note() ->"". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).