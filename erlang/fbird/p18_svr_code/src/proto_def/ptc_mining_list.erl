-module (ptc_mining_list).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#E214.

get_name() -> mining_list.

get_des() ->
	[ 
	 {datas,{list, mining_list_des},[]}
	].

get_note() ->"". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).