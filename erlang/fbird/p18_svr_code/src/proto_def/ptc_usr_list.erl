-module(ptc_usr_list).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#A102.

get_name() -> usr_list.

get_des() ->
	[
	 {default_camp,uint32,0},
	 {platform_id,uint32,0},	
	 {usr_list,{list,create_usr_info},[]},
	 {is_version_matched,uint32,0}
	 ].

get_note() ->"is_version_matched:是否和服务端的版本匹配（0:不匹配 1:匹配）". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).
