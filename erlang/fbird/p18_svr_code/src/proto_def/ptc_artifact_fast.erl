-module (ptc_artifact_fast).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#F016.

get_name() -> artifact_fast.

get_des() ->
	[
	 {time,uint32,0},
	 {status,uint32,0},
	 {buy_times,uint32,0}
	].

get_note() ->"". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).