-module(ptc_ret_trials_info).

-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#E115.

get_name() -> ret_trials_info.

get_des() ->
	[
	 {trials,{list,trial_nums},[]},
	 {copys, {list,int32x4},[]}
	 ].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).




