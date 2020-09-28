-module (ptc_god_costume_illustration_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f071.

get_name() -> god_costume_illustration_info.

get_des() ->
	[
	 {illustration_list,{list,id_list},[]},
	 {illustration_suit_list,{list,id_list},[]}
	].

get_note() ->"".

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).