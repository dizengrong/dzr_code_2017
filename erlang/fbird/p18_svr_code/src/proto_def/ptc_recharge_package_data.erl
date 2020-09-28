-module(ptc_recharge_package_data).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D261.

get_name() -> recharge_package_data.

get_des() ->
	[
		{num,uint32,0}
	].

get_note() ->"today recharge package data".

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).



