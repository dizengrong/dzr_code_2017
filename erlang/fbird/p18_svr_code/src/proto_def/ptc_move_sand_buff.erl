-module(ptc_move_sand_buff).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D161.

get_name() -> move_sand_buff.

get_des() ->
	[
	 {move_sand_list,{list,move_sand_list},[]}
	 
	].

get_note() ->"搬沙活动信息：
		\r\n\t{move_sand_id=搬沙活动ID,sand_buff_id=搬沙获取的BUFFID,move_sand_time=搬沙活动的次数}
	". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).