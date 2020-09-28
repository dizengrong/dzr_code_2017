-module(ptc_updata_name_card).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D174.

get_name() -> updata_name_card.

get_des() ->
	[
	 {item_id,uint32,0},
	 {updata_name,string,""}
	].
get_note() ->"改名卡\r\n\t".
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).