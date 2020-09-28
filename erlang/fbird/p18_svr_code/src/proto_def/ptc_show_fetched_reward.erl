-module (ptc_show_fetched_reward).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f10e.

get_name() ->show_fetched_reward.

get_des() ->
	[
	 {show_type,{list,friend_name_list},[]},
	 {type,uint32,0},
	 {rewards,{list,item_list},[]}
	].

get_note() ->"获得奖励的通用展示协议". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).