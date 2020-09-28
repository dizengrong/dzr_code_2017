-module(ptc_update_guild_inspire_times).

-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#C104.

get_name() -> update_guild_inspire_times.

get_des() ->
	[
	 {buy_times,uint32,0}
	].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).


