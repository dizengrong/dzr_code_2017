-module(ptc_global_arena_result).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f045.

get_name() -> global_arena_result.

get_des() ->
	[
	 {type,uint32,0},
	 {win_lose,uint32,0},
	 {rank,uint32,0},
	 {rank_change,uint32,0},
	 {honor_change,uint32,0},
	 {item_list,{list,item_list},[]}
	].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).