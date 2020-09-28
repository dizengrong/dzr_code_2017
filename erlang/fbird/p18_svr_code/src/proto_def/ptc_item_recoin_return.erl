-module(ptc_item_recoin_return).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D117.

get_name() -> item_recoin_return.

get_des() ->
	[
		 {item_prop_list,{list,uint32},[]}
	].

get_note() ->"重置属性更新：\r\n\titem_prop_list=属性列表". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).