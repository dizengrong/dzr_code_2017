-module(ptc_stamina_time).

-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D412.

get_name() -> stamina_time.

get_des() ->
	[ 
	 {stamina_data,uint32,0}
	].

get_note() ->"体力次数". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).