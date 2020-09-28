-module(ptc_move_sand_buff_id).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D162.

get_name() -> move_sand_buff_id.

get_des() ->
	[
	 {move_sand_id,uint32,0},
	 {scene_item_id,uint32,0},
	 {buff_id,uint32,0}].

get_note() ->"搬沙获取buff时传给客户端：
		\r\n\t{buff_id=BuffId,scene_item_id=搬沙场景物品实例化ID,move_sand_id=搬沙活动ID}". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).