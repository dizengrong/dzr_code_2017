-module (ptc_all_system_activity).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f021.

get_name() ->all_system_activity.

get_des() ->
	[
	 {list,{list,system_activity_info},[]}
	].

get_note() ->"". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).