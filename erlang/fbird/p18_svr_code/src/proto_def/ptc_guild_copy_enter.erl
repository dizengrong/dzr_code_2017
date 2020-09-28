-module(ptc_guild_copy_enter).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D11E.

get_name() -> guild_copy_enter.

get_des() ->
	[{guild_copy_enter_list,{list,guild_copy_enter_list},[]} ].

get_note() ->" 副本进入状态列表:\r\n\t{场景id,是（1）否（0）可以进入,prof=正在场景里面的玩家职业,usr_name=正在场景里面的玩家名字}}
				". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).