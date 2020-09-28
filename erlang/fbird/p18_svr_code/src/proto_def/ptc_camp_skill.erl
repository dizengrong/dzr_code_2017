-module(ptc_camp_skill).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D234.

get_name() -> camp_skill.

get_des() ->
	[
	 {skill_id,int32,0}
	 ].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).


