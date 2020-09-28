-module (ptc_entourage_revive).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f024.

get_name() ->entourage_revive.

get_des() ->
	[
	 {etype,uint32,0}
	].

get_note() ->"
英雄死亡相关
". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).