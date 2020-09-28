-module(ptc_req_chat).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D209.

get_name() -> req_chat.

get_des() ->
	 [
	 {rec_name,string,""},
	 {chanle,uint32,0},	 
	 {content,string,""}		 
	 ].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).



