-module (ptc_barrier_rewards_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f12d.

get_name() ->barrier_rewards_info.

get_des() ->
	[
	 {type, int32, 0},
	 {datas, {list, barrier_rewards_des}, []}
	].

get_note() ->"". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).

