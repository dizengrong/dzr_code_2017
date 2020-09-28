-module(ptc_action_list).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f014.

get_name() -> action_list.

get_des() ->
	[
	 {action,int32,0},
	 {id_list,{list,id_list},[]}
	 ].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).
