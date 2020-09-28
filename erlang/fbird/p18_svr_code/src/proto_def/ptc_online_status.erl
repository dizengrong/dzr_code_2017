-module(ptc_online_status).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D17a.

get_name() -> online_status.

get_des() ->
	[
	{uid,uint64,0},
	{is_online,uint8,0}
	].

get_note() ->"在线状态".
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).