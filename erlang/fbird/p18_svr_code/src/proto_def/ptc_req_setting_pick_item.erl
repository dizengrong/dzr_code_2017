-module(ptc_req_setting_pick_item).

-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#C102.

get_name() -> req_setting_pick_item.

get_des() -> 
	[
	 {setting_white,uint32,0},	
	 {setting_green,uint32,0},
	 {setting_blue,uint32,0}
	].

get_note() ->"req_setting_pick_item".

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).


