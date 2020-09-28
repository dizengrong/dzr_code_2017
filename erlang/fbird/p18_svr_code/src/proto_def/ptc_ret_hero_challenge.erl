-module(ptc_ret_hero_challenge).


-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#E117.

get_name() -> ret_hero_challenge.

get_des() ->
	[
	 {mission,uint32,0},
	 {maxhp,uint32,0},
	 {hp,uint32,0},
	 {mp,uint32,0},
	 {times,uint8,0},
	 {entourages,{list,entourage},[]}
	].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).