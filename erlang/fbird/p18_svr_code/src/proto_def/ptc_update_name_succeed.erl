-module(ptc_update_name_succeed).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D175.

get_name() -> update_name_succeed.

get_des() ->
	[{name,string,""}].
get_note() ->"改名卡成功".
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).