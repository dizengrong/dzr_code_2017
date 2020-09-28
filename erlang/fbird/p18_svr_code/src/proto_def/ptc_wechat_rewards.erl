-module(ptc_wechat_rewards).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D170.

get_name() -> wechat_rewards.

get_des() ->
	[{wechat_rewards_state,uint32,0},
	 {wechat_rewards_time,uint32,0}].
get_note() ->"请求领取微信转发奖励的次数".
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).