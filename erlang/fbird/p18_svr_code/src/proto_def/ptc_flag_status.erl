-module(ptc_flag_status).
-export([get_id/0,get_name/0,get_des/0,write/1]).

get_id()-> 16#D306.

get_name() -> flag_status.

get_des() ->
	[
	 {flag_camp,int32,0},
	 {flag_status,int32,0}
	 ].

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).
