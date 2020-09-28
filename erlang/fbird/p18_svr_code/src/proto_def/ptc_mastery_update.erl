-module(ptc_mastery_update).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D021.

get_name() -> mastery_update.

get_des() ->
	 [	 
	 {mastery_id,uint32,0},
	 {mastery_lev,uint32,0}			  
	 ].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).

