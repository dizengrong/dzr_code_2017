-module(ptc_get_success).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D110.

get_name() -> get_success.

get_des() ->
	[{get_success_list,{list,get_success_list},[]}].

get_note() ->"奖励领取成功的详情：\r\n\t
			{success_action=行为ID{1,签到奖励领取成功|2,累计签到领取成功},success_data=奖励ID}". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).