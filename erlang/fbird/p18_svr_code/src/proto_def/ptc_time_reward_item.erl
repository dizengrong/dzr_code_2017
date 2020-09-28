%% @author Administrator
%% @doc @todo Add description to ptc_time_reward_item.


-module(ptc_time_reward_item).

-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#F002.

get_name() -> time_reward_item.

get_des() ->
	[
	 {reward_id,uint32,0},
	 {item_list,{list,time_reward},[]}
	].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).