-module (ptc_return_investment_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f064.

get_name() ->return_investment_info.

get_des() ->
	[
	 {startTime,uint32,0},
	 {endTime,uint32,0},
	 {desc,string,""},
	 {datas,{list,return_investment_des},[]}
	].

get_note() ->"
gm活动投资回报
". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).