-module(ptc_guild_operation).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f03e.

get_name() -> guild_operation.

get_des() ->
	[
	 {operation_type,uint32,0}
	].

get_note() -> "公会操作信息". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).