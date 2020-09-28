-module(ptc_use_item_groupId).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D154.

get_name() -> use_item_groupId.

get_des() ->
	[{use_item_groupId,{list,use_item_groupId},[]}].

get_note() ->"物品组的使用次数：\r\n\t
				{group_id=物品组id,group_id_time=物品组使用次数}". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).