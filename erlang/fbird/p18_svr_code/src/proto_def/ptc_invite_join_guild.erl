-module(ptc_invite_join_guild).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D119.

get_name() -> invite_join_guild.

get_des() ->
	[
		{usr_name,string,""},
		{guild_name,string,""} 
	].

get_note() ->"邀请加入公会\r\n\t
			usr_name=玩家名字,guild_name=公会名字". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).