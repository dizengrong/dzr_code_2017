-module(ptc_open_svr_five_day_data).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D24A.

get_name() -> open_svr_five_day_data.

get_des() ->
	[
	 {sort,int32,0},
	 {rank,int32,0},
	 {prize_stat,int32,0},
	 {datas,{list,five_act_info},[]}
	].

get_note() ->"开服5天". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).


