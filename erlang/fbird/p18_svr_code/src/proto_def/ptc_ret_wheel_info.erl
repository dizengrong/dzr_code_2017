-module(ptc_ret_wheel_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#E128.

get_name() ->ret_wheel_info.

get_des() ->
	[    
	 {pool,uint16,0}
	].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).