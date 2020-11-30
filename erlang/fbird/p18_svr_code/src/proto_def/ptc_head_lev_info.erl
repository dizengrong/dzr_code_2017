-module (ptc_head_lev_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f060.

get_name() -> head_lev_info.

get_des() ->
	[
	 {head_list,{list,head_list},[]}
	].

get_note() ->"".

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).