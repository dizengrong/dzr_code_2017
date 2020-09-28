-module (ptc_last_called_hero).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D31a.

get_name() -> last_called_hero.

get_des() ->
	[ 
		{combat_entourage_list,{list,combat_entourage_list},[]}
	].

get_note() ->"之前召唤的英雄id". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).