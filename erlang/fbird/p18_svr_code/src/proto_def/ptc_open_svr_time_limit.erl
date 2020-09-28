-module(ptc_open_svr_time_limit).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D257.

get_name() -> open_svr_time_limit.

get_des() ->
	[
	 {time,int32,0}
	].

get_note() ->"开服活动持续时间". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).


