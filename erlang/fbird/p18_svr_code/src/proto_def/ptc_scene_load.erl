-module(ptc_scene_load).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D144.

get_name() -> scene_load.

get_des() ->
	[ ].

get_note() ->"请求回城". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).