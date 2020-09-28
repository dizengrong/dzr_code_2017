-module(ptc_usr_info_mount).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D176.

get_name() -> usr_info_mount.

get_des() ->
	[
		 {mount_id,uint32,0},
		 {illusion,{list,illusion_list},[]},
		 {equip,{list,mount_equip_list},[]},
		 {illusion_id,uint32,0}
	].
get_note() ->"查看其他玩家的坐骑".
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).