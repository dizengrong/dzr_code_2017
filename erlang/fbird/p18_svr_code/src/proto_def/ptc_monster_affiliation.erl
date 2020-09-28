-module(ptc_monster_affiliation).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#C01B.

get_name() -> monster_affiliation.

get_des() ->
	[ 
		 {monster_affiliation,{list,monster_affiliation},[]}
	].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).