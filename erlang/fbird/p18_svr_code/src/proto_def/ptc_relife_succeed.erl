-module(ptc_relife_succeed).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#F00F.

get_name() -> relife_succeed.

get_des() ->
	[ 
	 {time,uint32,0}
	].

get_note() ->"转生成功". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).