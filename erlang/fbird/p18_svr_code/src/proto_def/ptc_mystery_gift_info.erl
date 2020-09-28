-module (ptc_mystery_gift_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f06b.

get_name() ->mystery_gift_info.

get_des() ->
	[
	 {startTime,uint32,0},
	 {endTime,uint32,0},
	 {desc,string,""},
	 {datas,{list,mystery_gift_info_des},[]}
	].

get_note() ->"
gm活动神秘礼包
". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).