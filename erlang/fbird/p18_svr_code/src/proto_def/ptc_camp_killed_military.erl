-module(ptc_camp_killed_military).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D22F.

get_name() -> camp_killed_military.

get_des() ->
	[ 
	 {killed_military,uint32,0}
	].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).



