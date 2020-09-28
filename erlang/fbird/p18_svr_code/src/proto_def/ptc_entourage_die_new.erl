-module (ptc_entourage_die_new).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f038.

get_name() ->entourage_die_new.

get_des() ->
	[
	 {dead_entourage_list,{list, dead_entourage_list},[]}
	].

get_note() ->"
英雄死亡相关
". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).