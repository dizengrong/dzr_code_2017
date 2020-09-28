-module (ptc_sign_day).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f034.

get_name() ->sign_day.

get_des() ->
	[
	 {day_num,uint32,0}
	].

get_note() ->"
签到天数
". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).