-module (ptc_worldboss_list).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f126.

get_name() ->worldboss_list.

get_des() ->
	[
	 {list,{list, worldboss_info},[]}
	].

get_note() ->"". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).