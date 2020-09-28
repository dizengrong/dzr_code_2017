-module(ptc_pet_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D201.

get_name() -> pet.

get_des() ->
	 [
	  	{pet_id,uint32,0},
	  	{follow_pet_id,uint32,0},
	  	{lv,uint32,0},
	  	{exp,uint32,0}
	 ].

get_note() ->"". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).


