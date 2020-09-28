-module(ptc_all_star).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D164.

get_name() -> all_star.

get_des() ->
	[{star_num,uint32,0}].

get_note() ->"穿戴装备的所有星级:star_num=穿戴装备的所有星级". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).