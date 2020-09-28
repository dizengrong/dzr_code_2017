-module (ptc_entourage_debt_exchange_succ).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f030.

get_name() ->entourage_debt_exchange_succ.

get_des() ->
	[
	 {name,string,""},
	 {num,uint32,0}
	].

get_note() ->"
英雄碎片兑换成功
". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).