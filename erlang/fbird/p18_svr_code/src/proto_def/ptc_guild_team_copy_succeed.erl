-module(ptc_guild_team_copy_succeed).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D195.

get_name() -> guild_team_copy_succeed.

get_des() ->
	[{get_success_list,{list,get_success_list},[]}].

get_note() ->" ". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).