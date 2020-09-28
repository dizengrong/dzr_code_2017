-module (ptc_gm_act_treasure).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f123.

get_name() ->gm_act_treasure.

get_des() ->
	[
	 {startTime,uint32,0},
	 {endTime,uint32,0},
	 {desc,string,""},
	 {my_rank,uint32,0},
	 {my_times,uint32,0},
	 {all_times,uint32,0},
	 {one_times_cost,uint32,0},
	 {ten_times_cost,uint32,0},
	 {one_times_items,{list,item_list},[]},
	 {ten_times_items,{list,item_list},[]},
	 {rand_items,{list,item_list},[]},
	 {exchange, {list, treasure_exchange_des}, []},
	 {rank_reward, {list, treasure_rank_reward_des}, []},
	 {ranking_list, {list, treasure_ranking_des}, []}
	].

get_note() ->"
all_times:全服次数
one_times_cost:抽一次消耗非绑元宝数
ten_times_cost:抽十次消耗非绑元宝数
one_times_items:单次必给道具
ten_times_items:10连抽必给道具
rand_items:抽奖随机道具
exchange:兑换商城
rank_reward:抽奖次数排名奖励
ranking_list:抽奖次数排名数据
". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).