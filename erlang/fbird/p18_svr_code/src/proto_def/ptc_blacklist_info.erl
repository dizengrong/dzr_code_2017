-module(ptc_blacklist_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D181.

get_name() -> blacklist_info.

get_des() ->
	[{blacklist_list,{list,blacklist_list},[]}].
get_note() ->"黑名单".
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).