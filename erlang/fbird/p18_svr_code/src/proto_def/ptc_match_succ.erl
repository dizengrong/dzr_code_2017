-module(ptc_match_succ).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D218.

get_name() -> match_succ.

get_des() ->
	 [	 
	 	{sort,uint32,0},
	 	{id,uint32,0},
		{memebers,{list,match_succ_list},[]} 	 
	 ].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).


