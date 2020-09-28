-module(ptc_scene_property).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#C007.

get_name() -> scene_property.

get_des() ->
	[
	 {oid,uint64,0},
	 {property_list,{list,property},[]}
	 ].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).
