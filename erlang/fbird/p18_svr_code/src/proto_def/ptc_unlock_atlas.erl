-module(ptc_unlock_atlas).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D148.

get_name() -> unlock_atlas.

get_des() ->
	[ {unlock_atlas_list,{list,unlock_atlas_list},[]} ].

get_note() ->"大地图数据详细信息：\r\n\t
			{unlock_atlas=已经开启的地图ID}". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).