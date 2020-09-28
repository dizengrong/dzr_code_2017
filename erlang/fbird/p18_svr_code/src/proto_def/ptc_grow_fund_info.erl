-module(ptc_grow_fund_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f122.

get_name() ->grow_fund_info.

get_des() ->
	[
	 {have,uint32,0},
	 {step,uint32,0},
	 {fetched_id,uint32,0},
	 {can_fetch_id,uint32,0}
	].

get_note() ->"have:1为购买拥有了 0为没有；fetched_id:can_fetch_id:能领取的奖励到哪个id了". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).
