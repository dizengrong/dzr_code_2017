-module(ptc_draw_times).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D128.

get_name() -> draw_times.

get_des() ->
	[
	 {half,uint8,0},
	{draw_astrict,uint32,0},
	 {draw_times,{list,draw_times},[]}
	].

get_note() ->"抽奖信息:\r\n\t{half=是否半价,draw_times=抽奖信息{draw_type=抽奖ID,draw_time=抽奖次数,last_time=抽奖最后时间}}". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).