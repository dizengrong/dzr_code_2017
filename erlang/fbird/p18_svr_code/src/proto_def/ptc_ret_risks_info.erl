-module(ptc_ret_risks_info).



-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#E116.

get_name() -> ret_risks_info.

get_des() ->
	[
	 {risks,{list,trial_nums},[]}
	 ].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).


