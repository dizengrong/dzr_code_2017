-module(ptc_scene_full_tips).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D240.

get_name() -> scene_full_tips.

get_des() -> [].

get_note() ->"场景人满后提示". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).


