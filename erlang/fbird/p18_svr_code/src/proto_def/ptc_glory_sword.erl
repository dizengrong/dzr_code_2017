-module(ptc_glory_sword).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D40D.

get_name() -> glory_sword.

get_des() ->
	[ 
	 {glory_sword_lev,uint32,0}
	].

get_note() ->"荣耀之剑的等级". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).