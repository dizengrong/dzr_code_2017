-module(ptc_ret_war_report).

-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).
get_id()-> 16#E120.

get_name() -> ret_war_report.

get_des() ->
	[
	 {id,uint32,0},
	 {camp2score,uint32,0},
	 {camp3score,uint32,0},
	 {usrscore,uint32,0},
	 {usrkill,uint16,0},
	 {killsort,uint16,0},
	 {continuekill,uint16,0},
	 {curcontinuekill,uint16,0},
	 {speed,uint16,0}
	].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).


