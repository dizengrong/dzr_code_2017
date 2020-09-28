-module(ptc_boss_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D227.

get_name() -> boss_info.

get_des() ->
	[	
	 {boss_list,{list,boss_ex_info},[]}	
	].

get_note() ->"二货
	二货2".  
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).



