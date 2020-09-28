-module(ptc_open_box_get_item).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D108.

get_name() -> open_box_get_item.

get_des() ->
	[
	  {item_list,{list,item_list},[]}
	  ].

get_note() ->"开宝箱获得物品提示给客户端\r\n\t{item_id=物品ID,item_num=物品数量}". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).