-module(ptc_join_hero_challenge).

-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D416.

get_name() -> join_hero_challenge.

get_des() ->
	[ 
	  {hero_challenge_id_list,{list,uint32},[]}
	].

get_note() ->"". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).