-module(ptc_ret_war_times).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).
get_id()-> 16#E11F.

get_name() -> ret_war_times.

get_des() ->
	[
	 {wars,{list,war_info_list},[]}
	 ].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).


