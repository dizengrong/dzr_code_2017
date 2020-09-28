-module (ptc_acc_cost).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f111.

get_name() ->acc_cost.

get_des() ->
	[
	 {startTime,uint32,0},
	 {endTime,uint32,0},
	 {desc,string,""},
	 {picture,string,""},
	 {cost_coin,uint32,0},
	 {datas,{list,acc_cost_des},[]}
	].

get_note() ->"". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).