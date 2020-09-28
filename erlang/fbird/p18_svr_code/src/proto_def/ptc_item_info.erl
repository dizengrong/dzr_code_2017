-module(ptc_item_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D007.

get_name() -> item_info.

get_des() ->
	[
	 {entourage_bag,uint32,0},
	 {artifact_bag,uint32,0},
	 {item_list,{list,item_des},[]}
	].

get_note() ->"背包物品：\r\n\t entourage_bag = 英雄背包，artifact_bag = 神器背包
				\r\n\t {id=实例化ID,bind=是否绑定(1,绑定),breakState=0,lev=物品等级,num=物品数量,pos=物品位置,star=物品星级,type=物品ID,get_time=获取时间}". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).
