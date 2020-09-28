-module(ptc_bslx).
-export([get_id/0,get_name/0,get_des/0,write/1]).

get_id()-> 16#D311.

get_name() -> bslx.

get_des() ->
	[
	 ].

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).



