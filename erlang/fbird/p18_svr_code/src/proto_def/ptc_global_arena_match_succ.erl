-module(ptc_global_arena_match_succ).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f043.

get_name() -> global_arena_match_succ.

get_des() ->
	[
	 {time,uint32,0}
	].

get_note() -> "匹配结束通知客户端". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).