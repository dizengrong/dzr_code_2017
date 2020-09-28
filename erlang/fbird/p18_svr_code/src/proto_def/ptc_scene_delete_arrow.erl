-module(ptc_scene_delete_arrow).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#C016.

get_name() -> scene_delete_arrow.

get_des() ->
	[
	 {aid,uint32,0}
	].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).
