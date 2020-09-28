-module(ptc_abyss_box).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D198.

get_name() -> abyss_box.

get_des() ->
	[ 
	 {abyss_box_scene_item_id,uint32,0},
	 {time,uint32,0}
	].

get_note() ->" ". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).