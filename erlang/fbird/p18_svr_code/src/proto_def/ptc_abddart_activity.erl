-module(ptc_abddart_activity).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D155.

get_name() -> abddart_activity.

get_des() ->
	[
		 {abddart_activity_list,{list,abddart_activity_list},[]}
	].

get_note() ->"押镖活动数据:\r\n\tactivity_id=押镖活动的ID,activity_state=押镖活动开启状态,activity_time=押镖活动已经用过的次数". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).