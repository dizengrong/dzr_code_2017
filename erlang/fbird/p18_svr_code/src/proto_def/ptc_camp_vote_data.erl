-module(ptc_camp_vote_data).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D21A.

get_name() -> camp_vote_data.

get_des() ->
	 [	 
	 	{can_vote,uint32,0},
	  	{campvotes,{list,camp_vote_list},[]}
	 ].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).



