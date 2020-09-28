-module(ptc_entourage_create).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D01F.

get_name() -> entourage_create.

get_des() ->
	[
	 {etype,uint32,0},
	 {oid,uint32,0},
	 {played_state,uint32,0}
	].

get_note() ->"创建佣兵:\r\n\t{etype=佣兵type，oid=佣兵实例化ID}". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).