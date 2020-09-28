-module(ptc_all_people_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D403.

get_name() -> all_people_info.

get_des() ->
	[ 
	 {all_people_info,{list,all_people_info},[]}
	].

get_note() ->"全民赢大奖". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).