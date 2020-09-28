-module(ptc_flash_gift_bag_info).

-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D418.

get_name() -> flash_gift_bag_info.

get_des() ->
	[ {flash_gift_bag_list,{list,flash_gift_bag_list},[]}
	].

get_note() ->"". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).