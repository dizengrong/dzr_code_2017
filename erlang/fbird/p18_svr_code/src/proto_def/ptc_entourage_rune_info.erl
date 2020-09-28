-module(ptc_entourage_rune_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f027.

get_name() -> entourage_rune_info.

get_des() ->
	[
	 {etype,int32,0},
	 {can_have,int32,0},
	 {lev,int32,0},
	 {step,int32,0},
	 {property_list,{list,property_list},[]}
	].

get_note() ->"entourage_rune_info".

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).
