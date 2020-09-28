-module (ptc_action_data_and_two_int_list).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f08d.

get_name() -> action_data_and_two_int_list.

get_des() ->
	[
	 {action,uint32,0},
	 {data,uint64,0},
	 {list,{list,two_int},[]}
	].

get_note() ->"".

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).