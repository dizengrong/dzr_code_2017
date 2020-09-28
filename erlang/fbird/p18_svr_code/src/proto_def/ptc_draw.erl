-module(ptc_draw).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D127.

get_name() -> draw.

get_des() ->
	[{draw_item_list,{list,draw_item_list},[]}].

get_note() ->"抽奖获得奖励信息:\r\n\t{draw_item_id=奖励物品ID,draw_item_num=奖励物品数量,draw_item_type=奖励物品类型}". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).