-module(ptc_arena_reflush_cd).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D22D.

get_name() -> arena_reflush_cd.

get_des() ->
	[
	 	{cd_time,int32,0}
	].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).



