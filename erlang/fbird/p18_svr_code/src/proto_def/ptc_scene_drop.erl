-module(ptc_scene_drop).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#C011.

get_name() -> scene_drop.

get_des() ->
	[
	 {oid,uint32,0},
	 {drop_list,{list,drop_des},[]}
	 ].

get_note() ->"掉落物品详细信息\r\n\toid=主人ID
				{id = 掉落物品唯一ID,
				 num = 掉落物品数量,
				type = 掉落物品ID,
				x = X,
				y = Y,
				z = Z,
				owner = 拥有者ID
													   }". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).
