-module (ptc_daily_acc_cost).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f121.

get_name() ->daily_acc_cost.

get_des() ->
	[
	 {startTime,uint32,0},
	 {endTime,uint32,0},
	 {cost_coin,uint32,0},
	 {desc,string,""},
	 {datas,{list,daily_acc_cost_des},[]}
	].

get_note() ->"". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).