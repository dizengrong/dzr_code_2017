-module(ptc_ans_match_war).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#E122.

get_name() -> ans_match_war.

get_des() ->
	[
	 {id,uint32,0},
	 {action,uint8,0},
	 {status,uint8,0}
	 ].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).


