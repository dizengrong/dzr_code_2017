-module(ptc_scene_add_trap).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#C015.

get_name() -> scene_add_trap.

get_des() ->
	[
	 {list,{list,scene_trap},[]}
	].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).
