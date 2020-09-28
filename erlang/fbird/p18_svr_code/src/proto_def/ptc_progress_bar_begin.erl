-module(ptc_progress_bar_begin).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D203.

get_name() -> progress_bar_begin.

get_des() ->
	 [
	 {uid,uint64,0},
	 {target_id,uint32,0}
	 ].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).



