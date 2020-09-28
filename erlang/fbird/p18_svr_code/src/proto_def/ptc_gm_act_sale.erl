-module (ptc_gm_act_sale).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f116.

get_name() ->gm_act_sale.

get_des() ->
	[
	 {startTime,uint32,0},
	 {endTime,uint32,0},
	 {desc,string,""},
	 {exchange_score,uint32,0},
	 {datas,{list,gm_act_sale_des},[]}
	].

get_note() ->"". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).