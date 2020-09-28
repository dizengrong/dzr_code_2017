-module(ptc_sky_ladder_scene_result).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D268.

get_name() -> sky_ladder_scene_result.

get_des() ->
	[
	 	{result,int32,0}	
	].

get_note() ->"". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).



