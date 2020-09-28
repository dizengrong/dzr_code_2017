-module(ptc_arena_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D22A.

get_name() -> arena_info.

get_des() ->
	[
		{times,int32,0},
		{rank,int32,0},
		{point,int32,0},
		{shenqi,int32,0},
		{entourage_list,{list,guard_entourage_list},[]}
	].

get_note() ->"". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).



