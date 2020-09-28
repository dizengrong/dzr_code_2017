-module (ptc_update_resource).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f08a.

get_name() -> update_resource.

get_des() ->
	[
	 {resource_list,{list,resource_list},[]}
	].

get_note() ->"".

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).