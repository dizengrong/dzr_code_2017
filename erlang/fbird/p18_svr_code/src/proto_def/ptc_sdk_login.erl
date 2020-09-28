-module(ptc_sdk_login).

-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#A10F.

get_name() -> sdk_login.

get_des() ->
	
	[
	  {acc,string,""},
	  {pwd,string,""},
	  {line,string,""},
	  {type,uint32,0},
	  {statusCode,uint32,0},
	  {logPack,uint32,0},
	  {client_version,string,""}
	 ].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).
