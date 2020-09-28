-module (ptc_entourage_challenge).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f069.

get_name() -> entourage_challenge.

get_des() ->
	[
	 {times,uint32,0},
	 {buy_times,uint32,0},
	 {refresh_time,uint32,0},
	 {challenge_list,{list,entourage_challenge_info},[]}
	].

get_note() ->"".

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).