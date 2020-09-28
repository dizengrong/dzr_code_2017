-module(ptc_national_war_start_time).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D23F.

get_name() -> national_war_start_time.

get_des() -> 
	[
	 {stat,int32,0},	
	 {time,int32,0}
	].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).


