-module(ptc_guild_building_list).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D11A.

get_name() -> guild_building_list.

get_des() ->
	[{guild_building_list,{list,guild_building_list},[]} ].

get_note() ->"公会建筑列表：\r\n\t{building_exp=公会建筑经验,building_id=公会建筑ID,building_lev=公会建筑等级}". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).