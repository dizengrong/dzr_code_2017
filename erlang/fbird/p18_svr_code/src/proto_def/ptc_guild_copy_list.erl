-module(ptc_guild_copy_list).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D11C.

get_name() -> guild_copy_list.

get_des() ->
	[
	 {challenge_times,int32,0},
	 {buy_times,int32,0},
	 {guild_copy_list,{list,guild_copy_list},[]} 
	].

get_note() ->" 副本列表\r\n\t
				{challenge_time=已挑战次数,scene_id=场景id,copy_open_state=是（1）否（0）开启，,progress=当前进度,remaining_time=剩余时间（剩余多少秒，到时间可以重置）}". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).