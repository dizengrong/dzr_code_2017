-module(ptc_guild_copy_damage_ranking).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D11F.

get_name() -> guild_copy_damage_ranking.

get_des() ->
	[
      {my_damage,int32,0},
      {guild_copy_damage_ranking,{list,guild_copy_damage_ranking},[]} 
    ].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).