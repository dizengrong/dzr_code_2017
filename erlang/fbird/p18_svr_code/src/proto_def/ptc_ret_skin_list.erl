-module(ptc_ret_skin_list).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#E113.

get_name() -> ret_skin_list.

get_des() ->
	[
	 {skins,{list,r_skin},[]}
	 ].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).
