-module(ptc_req_gem_update).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D102.

get_name() -> req_gem_update.

get_des() ->
	[
	{gem_id,int32,0},
	{item_id,int32,0},
	{state,int32,0}
	].

get_note() ->"请求升级宝石：\r\n\t
				gem_id=宝石实例化ID，item_id=升级宝石需要的物品ID，state={0,升级,1,一键升级}". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).