-module(ptc_scene_fly_by_fly_point).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#C004.

get_name() -> scene_fly_by_fly_point.

get_des() ->
	[
	 {fly_point_id,int32,0}
	 ].

get_note() ->"请求传送门进入场景:\r\n\t
				FlyPointID = 传送门id ". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).
