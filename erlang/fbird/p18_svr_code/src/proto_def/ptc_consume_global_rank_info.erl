-module(ptc_consume_global_rank_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D41A.

get_name() -> consume_global_rank_info.

get_des() ->
	[
	 {type,uint32,0}, %%0为全发，1为不发start_time,end_time,close_time,desc,global_rewards_info
	 {rank,uint32,0},
	 {start_time,uint32,0},
	 {end_time,uint32,0},
	 {close_time,uint32,0},
	 {consume_num,uint32,0},
	 {desc,string,""},
	 {global_rewards_info,{list,global_rewards_info},[]},
	 {consume_global_rank_list,{list,consume_global_rank_list},[]}
	].

get_note() ->" ". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).


