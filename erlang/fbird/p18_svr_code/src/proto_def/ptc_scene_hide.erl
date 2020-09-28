-module(ptc_scene_hide).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#C020.

get_name() -> scene_hide.

get_des() ->
	[
	 {hide_list,{list,scene_objs},[]}
	 ].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).
