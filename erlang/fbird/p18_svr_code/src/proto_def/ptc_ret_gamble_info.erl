-module(ptc_ret_gamble_info).

-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#E124.

get_name() -> ret_gamble_info.

get_des() ->
	[    
	 
	 {cost,uint16,0},
	 {vip,uint8,0},
	 {low,uint16,0},
	 {high,uint16,0},
	 {times,uint8,0},
	 {pool,uint16,0}
	].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).


