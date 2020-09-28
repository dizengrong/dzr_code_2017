-module(ptc_sdk_auth_failed).
-export([get_id/0,get_name/0,get_des/0,write/1]).

get_id()-> 16#A005.

get_name() -> sdk_auth_failed.

get_des() ->
	[
	 {data,string,""}
	 ].

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).
