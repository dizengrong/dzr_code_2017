-module (ptc_gm_act_turntable_draw_result).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f083.

get_name() -> gm_act_turntable_draw_result.

get_des() ->
	[
	 {id,uint32,0},
	 {item_list,{list,item_list},[]}
	].

get_note() ->"".

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).