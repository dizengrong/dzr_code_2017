-module (ptc_ele_pearl_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#E212.

get_name() -> ele_pearl_info.

get_des() ->
	[ 
	 {ele1,uint32,0},
	 {ele2,uint32,0},
	 {ele3,uint32,0},
	 {ele4,uint32,0},
	 {ele5,uint32,0}
	].

get_note() ->"". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).