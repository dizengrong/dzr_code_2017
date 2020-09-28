-module(ptc_honor_kill).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D231.

get_name() -> honor_kill.

get_des() ->
	[
	 	{killed_mlev,int32,0},
		{is_kill,int32,0},
		{kill_num,int32,0}
	].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).








