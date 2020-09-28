-module (ptc_arena_challenge).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f089.

get_name() -> arena_challenge.

get_des() ->
	[
	 {t_uid,uint64,0},
	 {t_rank,uint32,0},
	 {entourage_list,{list,two_int},[]}
	].

get_note() ->"".

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).