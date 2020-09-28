-module(ptc_clear_skill_cd).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#C00A.

get_name() -> clear_skill_cd.

get_des() ->
	[
		{sort, uint32, 0}
	].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).



