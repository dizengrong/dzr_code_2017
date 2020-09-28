-module (ptc_revive_info_new).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f05c.

get_name() -> revive_info_new.

get_des() ->
	[
	 {type,uint32,0},
	 {countdown,uint32,0},
	 {times,uint32,0}
	].

get_note() ->"".

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).