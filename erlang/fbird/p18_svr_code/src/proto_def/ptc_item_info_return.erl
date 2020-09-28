-module(ptc_item_info_return).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D129.

get_name() -> item_info_return.

get_des() ->
	[ {item_list,{list,item_des},[]} ].

get_note() ->"所有物品详细信息返回给客户端\r\n\t
		{id=实例化ID,bind=是否绑定(1,绑定),breakState=0,equFour=第4条属性,equOne=第1条属性,equThree=第3条属性,
					\r\n\tequTwo=第2条属性,lev=物品等级,num=物品数量,pos=物品位置,star=物品星级,type=物品ID,get_time=获取时间}". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).