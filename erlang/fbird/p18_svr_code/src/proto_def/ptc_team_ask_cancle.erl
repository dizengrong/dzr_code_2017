-module(ptc_team_ask_cancle).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D031.

get_name() -> team_ask_cancle.

get_des() ->
	[
	 {ask_uid,uint64,0}
	].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).