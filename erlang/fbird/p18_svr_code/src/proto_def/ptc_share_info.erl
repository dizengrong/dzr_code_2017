-module(ptc_share_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D402.

get_name() -> share_info.

get_des() ->
	[ 
	 {share_num,uint32,0}
	].

get_note() ->" ". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).