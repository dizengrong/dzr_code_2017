-module (ptc_guild_impeach).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f062.

get_name() -> guild_impeach.

get_des() ->
	[
	 {impeach_person,string,""}
	].

get_note() ->"".

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).