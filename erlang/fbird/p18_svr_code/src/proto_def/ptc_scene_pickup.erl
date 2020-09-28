-module(ptc_scene_pickup).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#C012.

get_name() -> scene_pickup.

get_des() ->
	[
	 {pickup_list,{list,pickup_des},[]}
	 ].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).
