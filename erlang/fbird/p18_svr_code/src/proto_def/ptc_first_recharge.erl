-module(ptc_first_recharge).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D14B.

get_name() -> first_recharge.

get_des() ->
	[
		 {recharge_time,int32,0},
	 	 {recharge_draw_id,int32,0},
	 	 {recharge_draw_money,int32,0},
		 {recharge_draw_state,int32,0}
	].

get_note() ->"首充续充活动详细信息:\r\n\trecharge_time=充值次数,recharge_draw_id=奖励ID,recharge_draw_state=奖励领取状态(0,不能领|1,可以领取|2,已经领取)". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).