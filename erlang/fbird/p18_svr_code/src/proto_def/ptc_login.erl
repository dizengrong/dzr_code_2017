-module(ptc_login).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#A001.

get_name() -> login.

get_des() ->
	[
	 {account,string,""},
	 {password,string,""},
	 {pt_version,uint32,0}
	 ].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).
