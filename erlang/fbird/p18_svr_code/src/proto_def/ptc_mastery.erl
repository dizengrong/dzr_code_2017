-module(ptc_mastery).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D020.

get_name() -> mastery.

get_des() ->
	 [		 
	 {masterys,{list,mastery_list},[]}
	 ].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).

