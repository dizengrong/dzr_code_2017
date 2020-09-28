-module (ptc_legendary_level_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f068.

get_name() -> legendary_level_info.

get_des() ->
	[
	 {list,{list,legendary_level_info_list},[]}
	].

get_note() ->"".

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).