-module (ptc_god_costume_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f070.

get_name() -> god_costume_info.

get_des() ->
	[
	 {position_num,uint32,0},
	 {stage_lev,uint32,0}
	].

get_note() ->"".

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).