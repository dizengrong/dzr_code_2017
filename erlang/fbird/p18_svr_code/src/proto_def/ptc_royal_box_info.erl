-module(ptc_royal_box_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D168.

get_name() -> royal_box_info.

get_des() ->
	[
		{royal_box_time,uint32,0},
		{royal_box_astrict,int32,0},
		{royal_box_list,{list,royal_box_list},[]}].

get_note() ->"皇家宝箱详细信息：\r\n\t
					{royal_box_id=皇家宝箱唯一ID,royal_box_type=皇家宝箱ID,royal_box_state=皇家宝箱开启状态(0,未开启，1,,开启中，2,以开启),royal_box_final_time=皇家宝箱开启最终时间}". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).