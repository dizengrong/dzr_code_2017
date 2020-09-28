-module(ptc_dart_activity_state).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D152.

get_name() -> dart_activity_state.

get_des() ->
	[
		{activity_state,uint32,0},
		{activity_id_list,{list,activity_id_list},[]}
	].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).