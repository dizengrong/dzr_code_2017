-module(ptc_other_usr_skill_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D401.

get_name() -> other_usr_skill_info.

get_des() ->
	[ 
	 {strength_oven,uint32,0},
	 {other_usr_skill,{list,other_usr_skill},[]}
	].

get_note() ->" ". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).