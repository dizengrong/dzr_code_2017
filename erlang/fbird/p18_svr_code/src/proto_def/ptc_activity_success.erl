-module(ptc_activity_success).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D14A.

get_name() -> activity_success.

get_des() ->
	[{reward_list,{list,item_list},[]}].

get_note() ->"". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).