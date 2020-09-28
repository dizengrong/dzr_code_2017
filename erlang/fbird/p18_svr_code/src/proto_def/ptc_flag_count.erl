-module(ptc_flag_count).
-export([get_id/0,get_name/0,get_des/0,write/1]).

get_id()-> 16#D305.

get_name() -> flag_count.

get_des() ->
	[
	 {flag_count1,int32,0},
	 {flag_count3,int32,0},
	 {flag_count2,int32,0}
	 ].

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).
