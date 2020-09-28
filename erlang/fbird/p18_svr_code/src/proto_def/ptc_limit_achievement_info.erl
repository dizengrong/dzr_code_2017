-module (ptc_limit_achievement_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f029.

get_name() ->limit_achievement_info.

get_des() ->
	[
	 {startTime,uint32,0},
	 {endTime,uint32,0},
	 {desc,string,""},
	 {datas,{list,limit_achievement_des},[]}
	].

get_note() ->"
gm活动连续充值
". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).