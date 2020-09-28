-module (ptc_worldboss_inspire).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f127.

get_name() ->worldboss_inspire.

get_des() ->
	[
	 {current_id,uint32,0}
	].

get_note() ->"". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).

