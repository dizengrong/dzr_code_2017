-module (ptc_gm_act_limit_summon).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f022.

get_name() ->gm_act_limit_summon.

get_des() ->
	[
	 {startTime,uint32,0},
	 {endTime,uint32,0},
	 {desc,string,""},
	 {my_rank,uint32,0},
	 {my_times,uint32,0},
	 {rank_reward, {list, limit_summon_rank_reward_des}, []},
	 {ranking_list, {list, limit_summon_ranking_des}, []}
	].

get_note() ->"
rank_reward:抽奖次数排名奖励
ranking_list:抽奖次数排名数据
". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).