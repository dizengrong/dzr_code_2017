-module(ptc_arena_result).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D22E.

get_name() -> arena_result.

get_des() ->
	[
	 	{result,int32,0},
		{damage_list,{list,scene_damage_list},[]},
		{treat_list,{list,scene_damage_list},[]}
	].

get_note() ->"".

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).