-module(ptc_revive_times).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D207.

get_name() -> revive_times.

get_des() ->
	[
	 {countdown,uint32,0},
	 {times,uint32,0} 
	].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).








