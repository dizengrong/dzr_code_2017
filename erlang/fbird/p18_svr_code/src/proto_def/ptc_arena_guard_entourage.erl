-module (ptc_arena_guard_entourage).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f031.

get_name() ->arena_guard_entourage.

get_des() ->
	[
	 {entourage_list,{list,guard_entourage_list},[]}
	].

get_note() ->"
英雄碎片兑换成功
". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).