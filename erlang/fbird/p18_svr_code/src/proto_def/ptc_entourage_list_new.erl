-module(ptc_entourage_list_new).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f035.

get_name() -> entourage_list_new.

get_des() ->
	[
	 {entourage_list,{list,entourage_list},[]}
	].

get_note() ->"".

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).