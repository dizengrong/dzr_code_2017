%% @author Administrator
%% @doc @todo Add description to ptc_time_reward_info.


-module(ptc_time_reward_info).

-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#F001.

get_name() -> time_reward_info.

get_des() ->
	[
	 {step,uint32,0},
	 {extra_reward_state,uint32,0},
	 {fetched_list,{list, uint32},[]},
	 {next_time,uint32,0}
	].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).