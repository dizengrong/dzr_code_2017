-module(ptc_receive_red_response).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D25A.

get_name() -> rev_red_response.

get_des() -> 
	[
	 {uid,uint64,0},	
	 {diamond,uint32,0},
	 {red_num,uint32,0},
	 {red_max_num,uint32,0}
	].

get_note() ->"rev password red response".

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).



