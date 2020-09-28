-module (ptc_talent_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#E210.

get_name() -> talent_info.

get_des() ->
	[ 
	 {awaken,uint32,0},
	 {skills,{list,talent_skill_des},[]}
	].

get_note() ->"". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).