-module(ptc_req_quick_buy).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D15D.

get_name() -> req_quick_buy.

get_des() ->
	[
	 	{quick_buy_id,uint32,0},
		{quick_buy_item,uint32,0},
		{quick_buy_num,uint32,0} 
	].

get_note() ->"请求快捷购买:\r\n\t
				quick_buy_id=功能ID,
				quick_buy_item = 快捷购买的物品,
				quick_buy_num = 快捷购买的物品的数量
				". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).