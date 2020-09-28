-module(ptc_global_last_arena_ranklist).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f042.

get_name() -> global_last_arena_ranklist.

get_des() ->
	[
	 {worship_time,uint32,0},
	 {ranklist,{list,global_arena_last_ranklist_info},[]}
	].

get_note() -> 
	"worship_time=膜拜次数,
	 ranklist=[name=名字,rank_num=排名,vip_lev=vip等级,head_id=头像id,lev=玩家等级,rank=段位,honor=荣誉值,win_time=胜场数,be_worship_time=,server_id=服务器Id,server_name=服务器名字]".
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).