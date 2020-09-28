-module(ptc_guild_member_verify).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D141.

get_name() -> guild_member_verify.

get_des() ->
	[ ].

get_note() ->"公会新成员验证红点提示". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).