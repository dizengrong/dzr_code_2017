-module(ptc_usr_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#B102.

get_name() -> usr_info.

get_des() ->
	[
	 {id,uint64,0},
	 {name,string,""},
	 {level,uint32,0},
	 {exp,uint32,0},
	 {camp,uint32,0},
	 {guide_id,uint32,0},
	 {guild_name,string,""},
	 {resource_list,{list,resource_list},[]},
	 {paragon_level,uint32,0},
	 {vip_lev,uint32,0},
	 {vip_exp,uint32,0},
	 {create_time,uint32,0},
	 {scene_lev,uint32,0}
	].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).
