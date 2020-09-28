-module(ptc_req_continue_hc).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#E118.

get_name() -> req_continue_hc.



get_des() ->
	 [	 
	 {drops,{list,drop_des},[]}
	 ].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).



