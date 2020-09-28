-module(ptc_dart_pos).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D156.

get_name() -> dart_pos.

get_des() ->
	[
	 {pos_x,uint32,0},
	 {pos_y,uint32,0},
	 {pos_z,uint32,0} 
	 ].

get_note() ->"获得镖车的位置：{pos_x,pos_y,pos_z}={X,Y,Z}". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).