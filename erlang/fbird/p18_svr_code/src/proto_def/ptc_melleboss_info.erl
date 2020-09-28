-module (ptc_melleboss_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f059.

get_name() ->melleboss_info.

get_des() ->
	[
	 {type,uint32,0},
	 {reward_times,uint32,0},
	 {buy_times,uint32,0},
	 {list,{list,melleboss_list},[]}
	].

get_note() ->"".

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).