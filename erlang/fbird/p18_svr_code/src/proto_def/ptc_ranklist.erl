-module(ptc_ranklist).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D120.

get_name() -> ranklist.

get_des() ->
	[ 
	 {ranklistId,uint32,0},
	 {position,uint32,0},
	 {ranklist,{list,ranklist},[]}
	].

get_note() ->"排行榜信息详情：\r\n\t
			{camp=阵营,fighting=战力,guild_name=公会名字,lev=等级,name=名字,prof=职业,rank=当前排名,uid=玩家ID}". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).