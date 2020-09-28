-module(ptc_login_robot).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#A10C.

get_name() -> login_robot.

get_des() ->
	[
	 {account,string,""},
	 {password,string,""},
	 {mini_lev,uint32,0},
	 {max_lev,uint32,0}
	 ].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).
