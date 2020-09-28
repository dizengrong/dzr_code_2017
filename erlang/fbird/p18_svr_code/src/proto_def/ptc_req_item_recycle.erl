-module(ptc_req_item_recycle).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D104.

get_name() -> req_item_recycle.

get_des() ->
	[
	{recycle_list,{list,recycle_list},[]} 
	].

get_note() ->"请求回收物品\r\n\t
				{item_id=物品实例化ID,item_num=物品实例化数量}". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).