-module (ptc_shenqi_skill_effect).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f11b.

get_name() ->shenqi_skill_effect.

get_des() ->
	[
	 {src_id,uint64,0},
	 {src_sort,uint32,0},
	 {skill, uint32, 0},
	 % {target_type,uint32,0},
	 {target_id,uint64,0},
	 {target_x,float,0},
	 {target_y,float,0},
	 {target_z,float,0},
	 {effect_list,{list,skill_effect},[]}
	].

get_note() ->"". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).