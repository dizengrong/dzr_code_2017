-module(ptc_update_quick_fight_info).

-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#C101.

get_name() -> update_quick_fight_info.

get_des() ->
	[
	 {surplus_times,int32,0},
	 {max_times,int32,0},
	 {forever_times,int32,0},
	 {reward_exp,uint32,0},
	 {reward_copper,uint32,0},
	 {reward_res,uint32,0},
	 {reward_item,{list,item_list},[]}
	].

get_note() ->"快速战斗信息 surplus_times:已战斗次数 max_times:最大次数". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).



