-module(ptc_military_skill).

-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D410.

get_name() -> military_skill.

get_des() ->
	[ 
	 {use_skill_id,uint32,0},
	 {military_skill_list,{list,military_skill_info},[]}
	].

get_note() ->"". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).