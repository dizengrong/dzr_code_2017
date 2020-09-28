-module(ptc_guild_impeach_president).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D180.

get_name() -> guild_impeach_president.

get_des() ->
	[{guild_impeach_president_poll,uint32,0}].
get_note() ->"����\r\n\t����2".
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).