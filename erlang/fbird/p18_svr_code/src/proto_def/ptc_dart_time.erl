-module(ptc_dart_time).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D157.

get_name() -> dart_time.

get_des() ->
	[ {dart_time,uint32,0}].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).