-module(ptc_camp_task).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D135.

get_name() -> camp_task.

get_des() ->
	[ 
	 {camp_task_star,uint32,0},
	 {camp_task_loop,uint32,0},
	 {camp_rewards_state,uint32,0}
	].

get_note() ->"阵营悬赏的的星级和环数:\r\n\t{camp_rewards_state=奖励领取状态（{0,已领取},{1,未领取}）,camp_task_loop=接取阵营悬赏的次数,camp_task_star=接取阵营悬赏的星级}". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).