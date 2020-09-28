-module(ptc_arena_record_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D22C.

get_name() -> arena_record_info.

get_des() ->
	[
		{records,{list,arena_record},[]}
	].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).


