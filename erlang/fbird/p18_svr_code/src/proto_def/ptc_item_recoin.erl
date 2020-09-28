-module(ptc_item_recoin).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D116.

get_name() -> item_recoin.

get_des() ->
	[ 
		 {item_id,int32,0}, 
		 {item_prop_list,{list,uint32},[]}
	].

get_note() ->"请求重铸属性：\r\n\t
			item_id=实例化ID,item_prop_list=锁定的属性". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).