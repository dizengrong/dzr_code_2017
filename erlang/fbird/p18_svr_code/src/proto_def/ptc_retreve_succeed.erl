-module(ptc_retreve_succeed).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D15C.

get_name() -> retreve_succeed.

get_des() ->
	[{retreve_id,int32,0}].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).