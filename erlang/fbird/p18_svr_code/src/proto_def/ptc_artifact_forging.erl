-module(ptc_artifact_forging).

-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D417.

get_name() -> artifact_forging.

get_des() ->
	[].

get_note() ->"神器锻造成功". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).