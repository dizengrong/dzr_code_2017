-module(ptc_usr_info_pet).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D177.

get_name() -> usr_info_pet.

get_des() ->
	[ 
	 {pet_property_list,{list,pet_property_list},[]},
	 {other_pet_list,{list,other_pet_list},[]},
	 {use_pet,uint32,0}
	].
get_note() ->"查看其他玩家的宠物".
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).