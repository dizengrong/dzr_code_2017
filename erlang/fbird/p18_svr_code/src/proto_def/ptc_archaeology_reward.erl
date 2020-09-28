-module(ptc_archaeology_reward).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D131.

get_name() -> archaeology_reward.

get_des() ->
	[ 
	  {draw_item_list,{list,draw_item_list},[]}
	].

get_note() ->"考古奖励物品的显示:\r\n\t{draw_item_id=物品实例化ID,draw_item_num=物品数量,draw_item_type=物品类型}". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).