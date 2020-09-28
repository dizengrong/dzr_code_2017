-module(ptc_req_create_usr).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#A006.

get_name() -> req_create_usr.

get_des() ->
	[
	 {name,string,0}
	].

get_note() ->"".

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).