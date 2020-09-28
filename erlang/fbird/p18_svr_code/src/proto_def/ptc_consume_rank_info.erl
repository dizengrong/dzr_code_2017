-module(ptc_consume_rank_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D409.

get_name() -> consume_rank_info.

get_des() ->
	[ 
	 {rank,uint32,0},
	 {consume_rank_list,{list,consume_rank_list},[]}
	].

get_note() ->" ". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).