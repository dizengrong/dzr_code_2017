-module(ptc_national_war_data).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D237.

get_name() -> national_war_data.

get_des() ->
	[	 
	 {stat,int32,0},
	 {time,int32,0}, 
	 {camp2_honor,int32,0},
	 {camp3_honor,int32,0},	
	 {def_camp,int32,0},
	 {win_camp,int32,0},
	 {curr_hp,int32,0},
	 {max_hp,int32,0}		 
	].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).



