-module (ptc_medicine).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f012.

get_name() ->medicine.

get_des() ->
	[
	 {buff,{list,buff_list},[]}
	].

get_note() ->"". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).