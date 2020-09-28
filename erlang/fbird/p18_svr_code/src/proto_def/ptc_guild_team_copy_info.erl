-module(ptc_guild_team_copy_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D191.

get_name() -> guild_team_copy_info.

get_des() ->
	[ {call_upon_id,uint32,0},
	  {call_upon_uid,uint64,0},
	  {join_scene_id,uint32,0},
	  {guild_team_copy_list,{list,guild_team_copy_list},[]}
	].

get_note() ->"工会组队副本详细信息". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).