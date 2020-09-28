-module(ptc_action_list_and_data).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f026.

get_name() -> action_list_and_data.

get_des() ->
	[
	 {action,int32,0},
	 {id_list,{list,id_list},[]},
	 {data,int32,0}
	].

get_note() ->"list and data".

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).
