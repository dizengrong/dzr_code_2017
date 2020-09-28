-module(ptc_update_monster_prop).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D226.

get_name() -> update_monster_prop.

get_des() ->
	 [
	  {id,uint32,0}, 	 
	  {propertys,{list,property_list},[]}
	 ].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).


