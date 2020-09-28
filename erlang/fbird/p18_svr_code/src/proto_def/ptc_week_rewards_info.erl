-module(ptc_week_rewards_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D16D.

get_name() -> week_rewards_info.

get_des() ->
	[
	 	{week_rewards_time,uint32,0},
		{week_rewards_list,{list,week_rewards_list},[]}
	].

get_note() ->"悬赏周长奖励领取信息：\r\n\t
			week_rewards_time = 悬赏周长次数
			week_rewards_list = 已领取的悬赏周长奖励". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).