-module(ptc_climb_tower_reset).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D253.

get_name() -> climb_tower_reset.

get_des() -> [].

get_note() ->"climb tower reset".

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).



