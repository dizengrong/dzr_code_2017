-module(ptc_guild_blessing_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f03d.

get_name() -> guild_blessing_info.

get_des() ->
	[
	 {blessing_step,uint32,0}
	].

get_note() -> "公会祝福信息". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).