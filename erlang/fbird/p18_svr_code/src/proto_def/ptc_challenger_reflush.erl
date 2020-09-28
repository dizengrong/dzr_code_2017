-module(ptc_challenger_reflush).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D22B.

get_name() -> challenger_reflush.

get_des() ->
	[
		{challengers,{list,challenge_list},[]}
	].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).


