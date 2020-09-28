-module (ptc_legendary_level_start).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f05f.

get_name() -> legendary_level_start.

get_des() ->
	[
	 {info,string,""}
	].

get_note() ->"".

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).