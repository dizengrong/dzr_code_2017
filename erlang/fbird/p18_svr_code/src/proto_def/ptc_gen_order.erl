-module(ptc_gen_order).

-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#e11e.

get_name() -> gen_order.

get_des() ->
	 [
	  
	    {type,uint32,0},
	  	{order,string,""} 
	 ].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).




