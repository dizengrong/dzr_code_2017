-module(ptc_open_svr_five_day_time).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D249.

get_name() -> open_svr_five_day_time.

get_des() ->
	[
	 {time,int32,0}
	].

get_note() ->"开服5天活动". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).


