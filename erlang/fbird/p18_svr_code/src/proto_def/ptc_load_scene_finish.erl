-module(ptc_load_scene_finish).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#B005.

get_name() -> load_scene_finish.

get_des() ->
	[
	 {scene,uint32,0}
	 ].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).
