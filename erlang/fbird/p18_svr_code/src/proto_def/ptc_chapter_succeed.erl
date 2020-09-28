-module(ptc_chapter_succeed).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D142.

get_name() -> chapter_succeed.

get_des() ->
	[ ].

get_note() ->"章节奖励领取成功". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).