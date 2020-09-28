-module(ptc_atlas_team_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D179.

get_name() -> atlas_team_info.

get_des() ->
	[{atlas_team_list,{list,atlas_team_list},[]}].
get_note() ->"大地图查看队友信息".
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).