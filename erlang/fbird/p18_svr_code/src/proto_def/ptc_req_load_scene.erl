-module(ptc_req_load_scene).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#B104.

get_name() -> req_load_scene.

get_des() ->
	[
	 {scene,uint32,0},
	 {is_planes,float,0},
	 {dir,float,0},
	 {x,float,0},
	 {y,float,0},
	 {z,float,0}
	 ].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).
