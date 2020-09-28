-module(ptc_all_skill).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D100.

get_name() -> all_skill.

get_des() ->
	[
	 {new_unlock,uint32,0},
	 {normal_skill_list,{list,normal_skill_list},[]} 
	].

get_note() ->"发送技能列表给客户端:\r\n\t{rune_five=技能符文5,rune_four=技能符文4,rune_one=技能符文1,rune_six=技能符文6,rune_three=技能符文3,rune_two=技能符文2,rune_use=当前使用的技能符文ID,skill_id=技能ID,skill_lev=技能等级}". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).