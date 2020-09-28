-module (ptc_god_costume_draw).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f072.

get_name() -> god_costume_draw.

get_des() ->
	[
	 {multi_num,uint32,0},
	 {item_list,{list,item_list},[]}
	].

get_note() ->"".

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).