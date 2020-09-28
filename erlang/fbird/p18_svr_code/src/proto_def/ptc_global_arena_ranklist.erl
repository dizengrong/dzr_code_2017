-module(ptc_global_arena_ranklist).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f041.

get_name() -> global_arena_ranklist.

get_des() ->
	[
	 {is_rank,uint32,0},
	 {ranklist,{list,global_arena_ranklist_info},[]}
	].

get_note() -> 
	"is_rank=是否上榜,
	 ranklist=[name=名字,rank_num=排名,vip_lev=vip等级,head_id=头像id,lev=玩家等级,rank=段位,honor=荣誉值,win_time=胜场数,server_name=服务器名字]". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).