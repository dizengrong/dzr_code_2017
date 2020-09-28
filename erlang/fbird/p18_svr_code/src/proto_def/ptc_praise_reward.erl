-module (ptc_praise_reward).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f04a.

get_name() ->praise_reward.

get_des() ->
	[
	 {has_reward,uint32,0},
	 {is_pop_ip,uint32,0}
	].

get_note() ->"".

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).