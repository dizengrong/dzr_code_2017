-module (ptc_ggb_my_team_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#E201.

get_name() -> ggb_my_team_info.

get_des() ->
	[ 
	 {is_fight,uint8,0},
	 {strategy,uint8,0},
	 {inspire_lv,uint8,0},
	 {opponent_strategy,uint8,0},
	 {opponent_inspire_lv,uint8,0},
	 {opponent_server_name,string,""},
	 {opponent_guild_name,string,""}
	].

get_note() ->"自己队伍的信息". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).