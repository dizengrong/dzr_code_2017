-module (ptc_system_activity_limitboss).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f020.

get_name() ->system_activity_limitboss.

get_des() ->
	[
	 {times,uint32,0},
	 {buy_times,uint32,0}
	].

get_note() ->"". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).