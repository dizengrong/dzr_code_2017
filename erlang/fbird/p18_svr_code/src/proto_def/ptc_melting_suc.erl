-module(ptc_melting_suc).
-export([get_id/0,get_name/0,get_des/0,write/1]).

get_id()-> 16#D30F.

get_name() -> melting_suc.

get_des() ->
	[ 
		 {melting_num,int32,0}
	].

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).