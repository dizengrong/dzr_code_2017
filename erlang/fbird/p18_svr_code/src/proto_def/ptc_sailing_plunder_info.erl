-module (ptc_sailing_plunder_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f052.

get_name() ->sailing_plunder_info.

get_des() ->
	[
	 {plunder_time,uint32,0},
	 {plunder_list,{list,plunder_list},[]}
	].

get_note() ->"".

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).