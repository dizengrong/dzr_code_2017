-module(ptc_action_string_and_data).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#F032.

get_name() -> action_string_and_data.

get_des() ->
	[
	 {action,int32,0},
	 {data1,int32,0},
	 {data2,string,""}
	].

get_note() ->"
			Data & String
			". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).
