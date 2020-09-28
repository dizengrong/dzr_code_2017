-module(ptc_update_boss_born_and_die).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D248.

get_name() -> boss_born_and_die.

get_des() ->
	[ 
	 	 {boss_id,int32,0},
	 	 {stat,int32,0}
	].

get_note() ->"boss create or die
". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).

