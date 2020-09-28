-module(ptc_open_package).

-export([get_des/0,get_note/0,get_id/0,get_name/0,write/1]).

get_id()-> 16#D009.

get_name() -> open_package.

get_des() ->
	[
	 {item_list,{list,item_des},[]}
	].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).
