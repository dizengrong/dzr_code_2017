-module(ptc_guild_post).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D171.

get_name() ->guild_post.

get_des() ->
	[{post_id,uint32,0}].
get_note() ->"获取公会位置".
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).