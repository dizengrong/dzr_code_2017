-module(ptc_acquire_new_title).


-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#E10A.

get_name() -> acquire_new_title.

get_des() ->
	[
	 	{title,uint16,0},
	 	{lasttime,uint32,0}
	 ].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).



