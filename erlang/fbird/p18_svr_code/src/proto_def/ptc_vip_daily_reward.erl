-module (ptc_vip_daily_reward).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f048.

get_name() ->vip_daily_reward.

get_des() ->
	[
	 {state,uint32,0}
	].

get_note() ->"". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).