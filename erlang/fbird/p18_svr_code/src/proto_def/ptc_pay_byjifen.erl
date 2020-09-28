-module(ptc_pay_byjifen).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D41D.

get_name() -> pay_byjifen.

get_des() ->
	[
	 {type,uint32,0},%%1,充值积分，2消费积分
	 {itemid,uint32,0},
	 {num,uint32,0},
	 {payjifen,uint32,0}
	].

get_note() ->" ". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).