-module(ptc_mystery_store_data).

-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D413.

get_name() -> mystery_store_data.

get_des() ->
	[ {mystery_store_finish_time,uint32,0},
	  {mystery_store_item_list,{list,mystery_store_item_list},[]}
	].

get_note() ->"神秘商店数据". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).