-module (ptc_cast_shenqi_skill).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f11a.

get_name() ->cast_shenqi_skill.

get_des() ->
	[
	 {skill, uint32, 0},
	 {target_id,uint64,0},
	 {target_x,float,0},
	 {target_y,float,0},
	 {target_z,float,0}
	].

get_note() ->"". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).