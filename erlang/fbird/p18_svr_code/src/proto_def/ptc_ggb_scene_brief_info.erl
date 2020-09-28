-module (ptc_ggb_scene_brief_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#E203.

get_name() -> ggb_scene_brief_info.

get_des() ->
	[ 
	 {server_name1,string,""},
	 {guild_name1,string,""},
	 {strategy1,uint8,0},
	 {inspire_lv1,uint8,0},
	 {team1_left_num,uint8,0},
	 {team1_total_num,uint8,0},

	 {server_name2,string,""},
	 {guild_name2,string,""},
	 {strategy2,uint8,0},
	 {inspire_lv2,uint8,0},
	 {team2_left_num,uint8,0},
	 {team2_total_num,uint8,0}
	].

get_note() ->"跨服战场景信息". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).