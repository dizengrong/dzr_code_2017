-module(ptc_scene_add).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#C002.

get_name() -> scene_add.

get_des() ->
	[
	 {ply_list,{list,scene_ply},[]},
	 {monster_list,{list,scene_monster},[]},
	 {item_list,{list,scene_item},[]},
	 {entourage_list,{list,scene_entourage},[]},
	 {usr_equip_list,{list,usr_equip_list},[]},
	 {pets,{list,pet_list},[]},
	 {models,{list,camp_model_list},[]}
	].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).
