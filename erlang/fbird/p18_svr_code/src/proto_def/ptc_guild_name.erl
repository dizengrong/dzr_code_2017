-module(ptc_guild_name).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D137.

get_name() -> guild_name.

get_des() ->
	[ 
		{guild_name,string,""} 
	].

get_note() ->"玩家公会修改时发送公会名:guild_name=公会名字("",没有公会|公会名字)". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).