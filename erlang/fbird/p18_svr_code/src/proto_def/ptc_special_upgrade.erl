-module (ptc_special_upgrade).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f065.

get_name() ->special_upgrade.

get_des() ->
	[
	 {type,uint32,0}
	].

get_note() ->"
特殊升级
". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).