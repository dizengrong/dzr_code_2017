
-module(ptc_req_guild_stone_info).

-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#F006.

get_name() -> req_guild_stone_info.

get_des() ->
	[
	  {type,uint32,0},
	  {stone_list,{list,guild_stone_list},[]},
	  {can_get,uint32,0}
	].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).