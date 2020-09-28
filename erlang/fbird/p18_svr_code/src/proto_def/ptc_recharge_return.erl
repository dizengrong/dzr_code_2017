-module (ptc_recharge_return).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f129.

get_name() -> recharge_return.

get_des() ->
	[
	 {recharge_money, uint32, 0},
	 {return_coin, uint32, 0}
	].

get_note() ->"recharge_money:充值人名币 return_coin:返还元宝". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).