-module (ptc_main_scene_status).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f085.

get_name() -> main_scene_status.

get_des() ->
	[
	 {status,uint32,0}
	].

get_note() ->"".

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).