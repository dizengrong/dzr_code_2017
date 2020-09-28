-module(ptc_req_entourage_create_model).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f03b.

get_name() -> req_entourage_create_model.

get_des() ->
	[
	 {id,uint32,0},
	 {create_type,uint32,0}
	].

get_note() ->"请求创建英雄模型:\r\n\t{id=英雄唯一ID},
	create_type = {0=出战类型,1=复活类型}". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).