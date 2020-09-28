-module(ptc_revive).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D205.

get_name() -> revive.

get_des() ->
	 [
	 {revive_uid,uint64,0},
	 {revive_sort,uint32,0},
   	 {x,float,0},
     {y,float,0},
     {z,float,0}	 
	 ].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).






