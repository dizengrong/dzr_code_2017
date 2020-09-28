-module (ptc_main_scene_result).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f086.

get_name() -> main_scene_result.

get_des() ->
	[
	 {result,int32,0},
	 {scene_change,int32,0},
	 {x,uint32,0},
     {y,uint32,0},
     {z,uint32,0},
	 {damage_list,{list,scene_damage_list},[]},
	 {treat_list,{list,scene_damage_list},[]}
	].

get_note() ->"".

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).