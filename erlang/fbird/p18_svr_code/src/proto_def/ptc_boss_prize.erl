-module(ptc_boss_prize).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D228.

get_name() -> boss_win.

get_des() ->
	[
	 {boss_id,int32,0},
	 {demage,int32,0},
	 {rank,int32,0},
	 {items,{list,item_list},[]}
	].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).



