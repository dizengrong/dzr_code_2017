-module(ptc_hide_boss_data).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D246.

get_name() -> hide_boss_data.

get_des() ->
	[
	 {hides,{list,id_list},[]}
	].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).



