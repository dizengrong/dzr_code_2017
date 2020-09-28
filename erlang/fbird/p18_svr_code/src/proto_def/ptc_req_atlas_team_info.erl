-module(ptc_req_atlas_team_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D17D.

get_name() -> req_atlas_team_info.

get_des() ->
	[ ].
get_note() ->"请求大地图队友信息".
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).