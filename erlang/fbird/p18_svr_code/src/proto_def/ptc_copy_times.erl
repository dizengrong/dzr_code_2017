-module(ptc_copy_times).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D206.

get_name() -> copy_times.

get_des() ->
	 [
	 {copys,{list,copy_times},[]},
     {passed,{list,uint32},[]}
	 ].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).



