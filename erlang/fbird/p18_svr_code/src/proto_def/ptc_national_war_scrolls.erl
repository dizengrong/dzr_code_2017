-module(ptc_national_war_scrolls).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D23A.

get_name() -> national_war_scrolls.

get_des() ->
	[	 
	 {present_scrolls,{list,present_entourage_scrolls},[]}
	].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).


