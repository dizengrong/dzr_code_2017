-module(ptc_royal_box_succeed).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D169.

get_name() -> royal_box_succeed.

get_des() ->
	[{royal_box_id,int32,0},
	 {item_list,{list,recycle_list},[]}].

get_note() ->"皇家宝箱开启成功\r\n\t
			royal_box_id=皇家宝箱唯一ID". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).