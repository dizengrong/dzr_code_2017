-module(ptc_draw_base).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#F010.

get_name() -> draw_base.

get_des() ->
	[ 
	 {item,uint32,0},
	 {num,uint32,0}
	].

get_note() ->"十连保底". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).