
-module(ptc_story_show).

-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#F003.

get_name() -> story_show.

get_des() ->
	[ 
	 {chapter,uint32,0},
	 {step,uint32,0}
	].

get_note() ->" ". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).