-module(ptc_item_model).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D136.

get_name() -> item_model.

get_des() ->
	[
		{item_id,int32,0} 
	].

get_note() ->"%%使用物品道具获得一个新的模型会通过模型展示界面展示
			\r\n\titem_id=物品ID". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).