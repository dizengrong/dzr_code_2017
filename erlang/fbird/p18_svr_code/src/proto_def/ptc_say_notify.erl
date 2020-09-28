-module(ptc_say_notify).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D202.

get_name() -> say_notify.

get_des() ->
		[
	 	{target_id,uint32,0},
		{say_id,uint32,0}
	 	].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).



