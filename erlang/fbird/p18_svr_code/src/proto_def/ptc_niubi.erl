-module(ptc_niubi).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#F00C.

get_name() -> niubi.

get_des() ->
	[
	 {status,uint64,0}
	].

get_note() ->"牛逼". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).