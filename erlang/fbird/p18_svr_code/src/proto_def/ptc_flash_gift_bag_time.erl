-module(ptc_flash_gift_bag_time).

-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D419.

get_name() ->flash_gift_bag_time.

get_des() ->
	[ {start_time,uint32,0},
	  {end_time,uint32,0}
	].

get_note() ->"限时购买活动时间". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).