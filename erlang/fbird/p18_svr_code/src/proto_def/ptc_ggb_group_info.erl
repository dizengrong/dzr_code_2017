-module (ptc_ggb_group_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#E202.

get_name() -> ggb_group_info.

get_des() ->
	[ 
	 {my_team_pos,uint8,0},
	 {is_fight,uint8,0},
	 {result,uint8,0},
	
	 {server_id1,int32,0},
	 {guild_id1,uint64,0},
	 {server_name1,string,""},
	 {guild_name1,string,""},
	 {fighting1,uint32,0},
	 {strategy1,uint8,0},
	 {inspire_lv1,uint8,0},
	 {stake11,uint8,0},
	 {stake12,uint8,0},
	 {stake1_type1_total,uint16,0},
	 {stake1_type2_total,uint16,0},
	 
	 {server_id2,int32,0},
	 {guild_id2,uint64,0},
	 {server_name2,string,""},
	 {guild_name2,string,""},
	 {fighting2,uint32,0},
	 {strategy2,uint8,0},
	 {inspire_lv2,uint8,0},
	 {stake21,uint8,0},
	 {stake22,uint8,0},
	 {stake2_type1_total,uint16,0},
	 {stake2_type2_total,uint16,0}
	].

get_note() ->"分组队伍的信息". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).