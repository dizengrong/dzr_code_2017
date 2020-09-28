-module(ptc_vip_succeed).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D150.

get_name() -> vip_succeed.

get_des() ->
	[ {vip_succeed_id,uint32,0} ].

get_note() ->"VIP奖励领取成功：\r\n\tVIP奖励领取成功ID". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).