-module(ptc_action_tri_int).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f025.

get_name() -> action_tri_int.

get_des() ->
	[ 
		 {action,int32,0},
	 	 {data_One,uint64,0},
	 	 {data_Two,uint64,0},
	 	 {data_Three,uint64,0}
	].

get_note() ->"
	三个字段的协议
". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).