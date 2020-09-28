-module (ptc_ggb_battle_result).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#E207.

get_name() -> ggb_battle_result.

get_des() ->
	[ 
	 {status,uint8,""},
	 {win_server_name,string,""},
	 {win_guild_name,string,""},
	 {win_kill_num,uint8,""},
	 
	 {lose_server_name,string,""},
	 {lose_guild_name,string,""},
	 {lose_kill_num,uint8,""}
	].

get_note() ->"战斗结果". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).