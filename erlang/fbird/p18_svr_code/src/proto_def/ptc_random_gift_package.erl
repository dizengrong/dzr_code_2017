-module (ptc_random_gift_package).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f063.

get_name() -> random_gift_package.

get_des() ->
	[
	 {has_package,uint32,0},
	 {id,uint32,0},
	 {num,uint32,0},
	 {end_time,uint32,0}
	].

get_note() ->"".

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).