-module(ptc_ret_gs_rewards).

-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#E123.

get_name() -> ret_gs_rewards.

get_des() ->
[
 {status,uint8,0},
 {gs_rewards,{list,equip_rewards_list},[]} 
].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).
