-module(ptc_off_line_exp).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D158.

get_name() -> off_line_exp.

get_des() ->
	[
	 {off_line_time,int32,0}, 
	 {off_line_exp,int32,0},
	 {off_line_coin,int32,0},
	 {off_line_res,int32,0},
	 {off_line_item_num,int32,0}
	].

get_note() ->"离线经验信息：
	\r\n\t{off_line_time = 离线时间,off_line_exp = 离线获得的经验,vip = 当前VIP等级}". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).