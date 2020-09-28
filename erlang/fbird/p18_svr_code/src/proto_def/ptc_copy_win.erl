-module(ptc_copy_win).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D20E.

get_name() -> copy_win.

get_des() ->
	 [
	 {winorlose,int32,0}, 
	 {coin,int32,0},
	 {exp,int32,0},
	 {boss_max_hp,int32,0},
	 {total_damage,int32,0},
	 {damage,int32,0},
	 {totalexp,int32,0},
	 {totalcoin,int32,0},
	 {items,{list,item_list},[]},
	 {collect_drops,{list,item_list},[]},
	 {rank_list,{list,common_rank},[]}
	 ].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).