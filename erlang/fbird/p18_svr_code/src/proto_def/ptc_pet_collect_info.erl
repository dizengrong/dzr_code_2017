-module(ptc_pet_collect_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D265.

get_name() -> pet_collect.

get_des() ->
	 [
	  	{pet_collect_list,{list,pet_coll_info},[]}
	 ].

get_note() ->"二货". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).



