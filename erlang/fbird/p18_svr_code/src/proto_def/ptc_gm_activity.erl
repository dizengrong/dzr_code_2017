-module (ptc_gm_activity).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f078.

get_name() ->gm_activity.

get_des() ->
	[
	 {activity_list,{list,activity_list},[]}
	].

get_note() ->"".

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).