-module(ptc_scene_branching_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D145.

get_name() -> scene_branching_info.

get_des() ->
	[
		{scene_branching_info,{list,scene_branching_info},[]} 
	].

get_note() ->"分线详细数据：\r\n\t
				{branching_id= 分线数据,people_number = 该线的人数}
		". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).