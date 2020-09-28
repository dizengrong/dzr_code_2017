-module(ptc_login_auth_succ).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#A110.

get_name() -> login_auth_succ.

get_des() ->
	[  
	 {jsondata,string,""}
	].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).


