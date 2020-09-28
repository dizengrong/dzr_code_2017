-module(ptc_usr_info_lost_item).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D126.

get_name() -> usr_info_lost_item.

get_des() ->
	[ 
		 {lost_item_info,{list,lost_item_info},[]}
	].

get_note() ->"其他玩家遗物信息\r\n\t{lost_item_type=遗物ID,lost_item_state=遗物状态,lost_item_lev=遗物等级}". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).