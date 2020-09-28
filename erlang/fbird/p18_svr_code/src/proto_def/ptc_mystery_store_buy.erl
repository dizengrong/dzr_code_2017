-module(ptc_mystery_store_buy).

-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D414.

get_name() -> mystery_store_buy.

get_des() ->
	[ 
		{buy_item_info,{list,mystery_store_item_list},[]}
	].

get_note() ->"神秘商店购买物品". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).