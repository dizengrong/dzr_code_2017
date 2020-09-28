-module(ptc_strength_oven_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D186.

get_name() -> strength_oven_info.

get_des() ->
	[ 
	  {strength_oven_list,{list,strength_oven_list},[]}
	].

get_note() ->" ". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).