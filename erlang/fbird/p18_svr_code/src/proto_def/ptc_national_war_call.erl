-module(ptc_national_war_call).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D239.

get_name() -> national_war_call.

get_des() -> 
	[
		{cd_time,int32,0} 
	].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).


