-module(ptc_rent_entourage_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D250.

get_name() -> rent_entourage_info.

get_des() ->
	[
	 {datas,{list,rent_entourage_list},[]}
	].

get_note() ->"租赁英雄数据".

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).



