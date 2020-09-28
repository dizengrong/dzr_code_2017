-module(ptc_equip_and_entourage_succeed).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D16C.

get_name() -> equip_and_entourage_succeed.

get_des() ->
	[{sort,uint32,0},
	 {id,uint32,0}].

get_note() ->"英雄觉醒福利和装备提升福利领取奖励成功:
		\r\n\t{sort=[{1,英雄觉醒福利},{2,装备提升福利}],id=奖励ID}". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).