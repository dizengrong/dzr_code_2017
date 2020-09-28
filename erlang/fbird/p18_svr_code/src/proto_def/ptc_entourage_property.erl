-module(ptc_entourage_property).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f033.

get_name() -> entourage_property.

get_des() ->
	[
	 {property_list,{list,property_list},[]}
	].

get_note() ->"英雄属性".

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).