-module (ptc_arnea_season_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f073.

get_name() -> arnea_season_info.

get_des() ->
	[
	 {time_state,uint32,0},
	 {season_state,uint32,0}
	].

get_note() ->"".

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).