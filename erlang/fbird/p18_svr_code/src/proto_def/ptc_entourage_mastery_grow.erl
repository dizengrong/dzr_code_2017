-module(ptc_entourage_mastery_grow).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D199.

get_name() -> entourage_mastery_grow.

get_des() ->
	[ 
	  {entourage_mastery_info,{list,entourage_mastery_info},[]}
	].

get_note() ->" ". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).