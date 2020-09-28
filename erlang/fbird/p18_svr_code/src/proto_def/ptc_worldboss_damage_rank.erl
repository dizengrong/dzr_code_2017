-module (ptc_worldboss_damage_rank).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f128.

get_name() ->worldboss_damage_rank.

get_des() ->
	[
	 {type,uint32,0},
	 {list,{list, worldboss_damage_info},[]}
	].

get_note() ->"". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).



