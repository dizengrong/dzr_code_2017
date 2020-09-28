-module(ptc_update_open_svr_five_camp).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D24C.

get_name() -> open_svr_five_day_camp.

get_des() ->[].

get_note() ->"开服5天活动". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).



