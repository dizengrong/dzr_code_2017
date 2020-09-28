-module (ptc_recent_chat).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f119.

get_name() ->recent_chat.

get_des() ->
	[
	 {msgs,{list,recent_chat_msg},[]}
	].

get_note() ->"". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).