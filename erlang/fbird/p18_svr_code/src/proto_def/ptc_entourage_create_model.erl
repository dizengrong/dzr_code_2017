-module(ptc_entourage_create_model).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f03a.

get_name() -> entourage_create_model.

get_des() ->
	[
	 {oid,uint32,0},
	 {item_id,uint32,0},
	 {played_state,uint32,0}
	].

get_note() ->"创建佣兵模型:\r\n\t{item_id=英雄物品唯一id，oid=佣兵实例化ID}". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).