-module(ptc_reloading).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D101.

get_name() ->reloading.

get_des() ->
	[
	 {uid,uint64,0},
	 {model_clothes,uint32,0},
	 {equip_id_state_list,{list,equip_id_state_list},[]}
	].

get_note() ->"将玩家所穿戴的装备和时装发给其他玩家\r\n\t
			equip_id_state_list=玩家穿戴装备列表,model_clothes=时装ID,uid=玩家ID". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).