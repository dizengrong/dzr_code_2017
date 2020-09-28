-module(ptc_give_pwd_red).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D258.

get_name() -> give_pwd_red.

get_des() -> 
	[
	 {pwd_context,string,""},
	 {diamond,uint32,0},
	 {red_num,uint32,0}
	].

get_note() ->"give password red".

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).


