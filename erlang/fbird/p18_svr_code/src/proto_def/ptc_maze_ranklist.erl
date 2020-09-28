-module (ptc_maze_ranklist).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f058.

get_name() ->maze_ranklist.

get_des() ->
	[
	 {my_rank,uint32,0},
	 {my_lucky,uint32,0},
	 {list,{list,maze_ranklist},[]}
	].

get_note() ->"".

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).