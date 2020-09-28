-module(ptc_climb_tower_fast).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D254.

get_name() -> climb_tower_fast.

get_des() -> [{tower_id,uint32,0}].

get_note() ->"climb tower fast".

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).


