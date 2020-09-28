-module(ptc_scramble_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D182.

get_name() -> scramble_info.

get_des() ->
	[{camp_two_score,uint32,0},{camp_three_score,uint32,0}].
get_note() ->"����\r\n\t����2".
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).