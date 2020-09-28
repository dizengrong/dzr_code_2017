-module(ptc_camp_activity_data).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D221.

get_name() -> camp_activity.

get_des() ->
	 [	 
	 	{union_score,uint32,0},
		{tribe_score,uint32,0},
		{time_len,uint32,0},
		{need_exp,uint32,0},
		{curr_exp,uint32,0},
		{can_get_prize,uint32,0},
		{win_camp,uint32,0},
		{skill_id,uint32,0},
		{honor,uint32,0},
		{max_honor,uint32,0}
	 ].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).


