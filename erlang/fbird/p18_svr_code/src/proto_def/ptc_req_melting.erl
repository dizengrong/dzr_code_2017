-module(ptc_req_melting).
-export([get_id/0,get_name/0,get_des/0,write/1]).

get_id()-> 16#D30E.

get_name() -> req_melting.

get_des() ->
	[ 
		 {ids,{list,uint32},[]}
	].

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).