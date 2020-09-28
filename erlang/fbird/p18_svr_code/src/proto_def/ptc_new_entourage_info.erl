-module (ptc_new_entourage_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f066.

get_name() ->new_entourage_info.

get_des() ->
	[
	 {etype,uint32,0},
	 {num1,uint32,0},
	 {num2,uint32,0},
	 {num3,uint32,0},
	 {num4,uint32,0},
	 {num5,uint32,0},
	 {num6,uint32,0},
	 {num7,uint32,0},
	 {num8,uint32,0},
	 {num9,uint32,0},
	 {num10,uint32,0},
	 {num11,uint32,0}
	].

get_note() ->"
	num1 = 英雄觉醒等级
	剩余待续
". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).