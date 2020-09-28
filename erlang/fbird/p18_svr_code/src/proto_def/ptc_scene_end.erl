-module (ptc_scene_end).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f087.

get_name() -> scene_end.

get_des() ->
	[
	 {time,int32,0}
	].

get_note() ->"".

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).