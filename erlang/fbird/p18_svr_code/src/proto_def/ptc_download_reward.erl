-module(ptc_download_reward).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#F013.

get_name() -> download_reward.

get_des() ->
	[
	 {id,uint64,0},
	 {state,uint32,0}
	].

get_note() ->"".
 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).