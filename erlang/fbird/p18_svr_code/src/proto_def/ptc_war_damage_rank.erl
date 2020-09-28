-module(ptc_war_damage_rank).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D241.

get_name() -> war_damage_rank.

get_des() ->
	[
	 {my_damage,int32,0},
	 {damages,{list,war_damage},[]}	
	].

get_note() -> "战场或国战伤害". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).



