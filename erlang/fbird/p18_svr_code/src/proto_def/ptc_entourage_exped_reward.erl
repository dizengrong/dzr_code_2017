-module(ptc_entourage_exped_reward).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D256.

get_name() -> entourage_expedition_reward.

get_des() ->
	[	 
	 {en_list,{list,id_list},[]},
	 {en_exp,int32,0},
	 {items,{list,item_list},[]},
	 {item_ex,int32,0}	 
	].

get_note() ->"远征奖励".

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).



