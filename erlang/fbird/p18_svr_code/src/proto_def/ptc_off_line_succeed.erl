-module(ptc_off_line_succeed).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D159.

get_name() -> off_line_succeed.

get_des() ->
	[ ].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).