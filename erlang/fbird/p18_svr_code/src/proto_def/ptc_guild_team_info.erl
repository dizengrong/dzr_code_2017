-module(ptc_guild_team_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D192.

get_name() -> guild_team_info.

get_des() ->
	[ 
	  {guild_team_list,{list,guild_team_list},[]}
	].

get_note() ->" ". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).