-module(ptc_team_ask).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D024.

get_name() -> team_ask.

get_des() ->
	[
	 {ask_uid,uint64,0},
	 {ask_usr_name,string,""}
	].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).