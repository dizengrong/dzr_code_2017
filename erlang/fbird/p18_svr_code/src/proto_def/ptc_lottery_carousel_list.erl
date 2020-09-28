-module (ptc_lottery_carousel_list).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f057.

get_name() ->lottery_carousel_list.

get_des() ->
	[
	 {list,{list,id_list},[]}
	].

get_note() ->"".

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).