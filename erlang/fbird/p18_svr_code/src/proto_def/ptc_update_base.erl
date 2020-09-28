-module(ptc_update_base).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D01d.

get_name() -> update_base.

get_des() ->
	 [
	  {uid,uint64,0}, 	 
	  {property_list,{list,property},[]}
	 ].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).



