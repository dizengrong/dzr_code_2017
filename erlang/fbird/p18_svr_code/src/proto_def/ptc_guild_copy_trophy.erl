-module(ptc_guild_copy_trophy).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D11D.

get_name() -> guild_copy_trophy.

get_des() ->
		 [{guild_copy_trophy_list,{list,guild_copy_trophy_list},[]} ].
%% 战利品列表{从属场景id，物品id，位置（0为可申请），已拥有的物品数量，当前排队人数}
get_note() ->"公会副本战利品列表\r\n\t{scene_id=从属场景id,apply_position=位置（0为可申请）,item_id=物品id,item_num=已拥有的物品数量,queued_num=当前排队人数}". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).