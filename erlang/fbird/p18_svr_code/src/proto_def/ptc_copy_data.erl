-module (ptc_copy_data).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f12a.

get_name() ->copy_data.

get_des() ->
	[
	 {data_type,uint32,0},
	 {data,uint32,0}
	].

get_note() ->"". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).

