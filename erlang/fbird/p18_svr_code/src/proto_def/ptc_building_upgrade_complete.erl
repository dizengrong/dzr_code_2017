-module (ptc_building_upgrade_complete).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#F015.

get_name() -> building_upgrade_complete.

get_des() ->
	[
	 {id,uint32,0}
	 ].

get_note() ->"". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).