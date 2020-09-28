-module(ptc_rep_add_friend_confirm).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D10B.

get_name() -> rep_add_friend_confirm.

get_des() ->
	[
	{uid,uint64,0}
	].

get_note() ->"添加好友确认回复".
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).