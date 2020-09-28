
-module(ptc_guild_stone_donation).

-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#F007.

get_name() -> guild_stone_donation.

get_des() ->
	[
	  {target_id,uint32,0},
	  {type,uint32,0}
	].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).