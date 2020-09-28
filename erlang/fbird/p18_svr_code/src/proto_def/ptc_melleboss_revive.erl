-module (ptc_melleboss_revive).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f05d.

get_name() -> melleboss_revive.

get_des() ->
	[
	 {boss_id,uint32,0}
	].

get_note() ->"".

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).