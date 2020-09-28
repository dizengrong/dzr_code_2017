-module (ptc_ggb_nofity).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#E206.

get_name() -> ggb_nofity.

get_des() ->
	[ 
	 {status,uint8,0}
	].

get_note() ->"跨服战开始预告". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).