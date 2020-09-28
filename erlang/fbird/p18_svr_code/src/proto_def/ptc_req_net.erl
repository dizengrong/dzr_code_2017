-module(ptc_req_net).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#A003.

get_name() -> req_net.

get_des() ->
	[
	 {uid,uint64,0},
	 {phone_type,uint32,0}
	].

get_note() ->"phone_type:1:ANDRIOD 2:IOS". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).
