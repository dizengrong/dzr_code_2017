-module(ptc_ret_fast_trials).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#E119.

get_name() -> ret_fast_trials.



get_des() ->
	[	 
	 {copy,int32,0},
	 {times,int32,0},
	 {coin,int32,0},
	 {exp,int32,0},
	 {items,{list,item_list},[]}
	].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).
