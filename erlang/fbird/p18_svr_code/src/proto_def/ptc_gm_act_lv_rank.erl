-module (ptc_gm_act_lv_rank).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f12c.

get_name() ->gm_act_lv_rank.

get_des() ->
	[
	 {startTime,uint32,0},
	 {endTime,uint32,0},
	 {desc,string,""},
	 {my_rank,uint32,0},
	 {rank_reward, {list, lv_rank_reward_des}, []},
	 {ranking_list, {list, gm_act_lv_rank_des}, []}
	].

get_note() ->"". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).

