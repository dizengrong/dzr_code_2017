-module(ptc_worldlevel_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f03c.

get_name() -> worldlevel_info.

get_des() ->
	[
	 {world_level,uint32,0},
	 {is_reward,uint32,0}
	].

get_note() ->"world_level = 当前世界等级, is_reward = 今天是否领取过世界等级奖励{0 = 可以领取, 1 = 已经领过} ". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).