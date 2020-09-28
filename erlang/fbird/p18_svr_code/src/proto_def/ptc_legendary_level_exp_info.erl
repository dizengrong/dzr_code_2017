-module (ptc_legendary_level_exp_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f06a.

get_name() -> legendary_level_exp_info.

get_des() ->
	[
	 {exp,uint32,0},
	 {list,{list,legendary_exp_buy_list},[]}
	].

get_note() ->"".

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).