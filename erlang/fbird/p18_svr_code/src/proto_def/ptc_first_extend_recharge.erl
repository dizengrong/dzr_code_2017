-module(ptc_first_extend_recharge).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D151.

get_name() -> first_extend_recharge.

get_des() ->
	[
		{recharge_succeed_id,uint32,0},
		{rewards, {list, item_list}, []}
	].

get_note() ->"首充续充活动奖励领取成功:\r\n\trecharge_succeed_id=ID[{1,首充},{2,续充}]". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).