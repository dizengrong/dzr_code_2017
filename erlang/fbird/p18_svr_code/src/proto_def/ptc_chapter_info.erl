-module(ptc_chapter_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D139.

get_name() -> chapter_info.

get_des() ->
	[ 
		{reward_chapter_id,int32,0},
		{fetched_id,int32,0} 
	].

get_note() ->"reward_chapter_id:现在可领取到哪一章奖励\nfetched_id:已领取到哪一章". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).