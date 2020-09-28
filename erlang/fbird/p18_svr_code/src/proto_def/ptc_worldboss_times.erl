-module (ptc_worldboss_times).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f125.

get_name() ->worldboss_times.

get_des() ->
	[
	 {left_times,uint32,0},
	 {next_recover_time,uint32,0}
	].

get_note() ->"". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).