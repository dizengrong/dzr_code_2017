-module(ptc_hero_challenge_info).

-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D415.

get_name() -> hero_challenge_info.

get_des() ->
	[ {hero_challenge_difficulty,uint32,0},
	  {hero_challenge_wave,uint32,0}
	].

get_note() ->"". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).