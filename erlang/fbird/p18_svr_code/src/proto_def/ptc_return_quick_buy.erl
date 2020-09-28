-module(ptc_return_quick_buy).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D160.

get_name() -> return_quick_buy.

get_des() ->
	[
		{quick_buy_id,uint32,0},
		{quick_buy_item,uint32,0},
		{quick_buy_num,uint32,0} 
	].

get_note() ->"快捷购买返回信息：{quick_buy_id=快捷购买功能ID,quick_buy_item=快捷购买需要够买的物品,quick_buy_num=快捷购买需要够买的物品数量}". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).