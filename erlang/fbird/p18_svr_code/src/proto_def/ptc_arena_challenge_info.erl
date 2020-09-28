-module (ptc_arena_challenge_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f08b.

get_name() -> arena_challenge_info.

get_des() ->
	[
	 {challenge_list,{list,challenge_list},[]}
	].

get_note() ->"".

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).