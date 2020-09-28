-module(ptc_buy_coin).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D163.

get_name() -> buy_coin.

get_des() ->
	[
		{buy_coin_time,uint32,0},
		{total_times,uint32,0},
		{coin,uint32,0},
		{status,uint32,0},
		{free_times,uint32,0},
		{re_time,uint32,0}
	].

get_note() ->"购买金币:{total_times:历史总次数,buy_coin_time=购买金币次数,coin:本次可以获得多少金币,status:获取还是购买金币}". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).