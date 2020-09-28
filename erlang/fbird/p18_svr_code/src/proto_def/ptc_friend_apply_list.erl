-module(ptc_friend_apply_list).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#F009.

get_name() -> friend_apply_list.

get_des() ->
	[
	{type,uint32,0},
	{apply_info,{list,apply_info},[]}
	].

get_note() ->"添加好友申请".
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).