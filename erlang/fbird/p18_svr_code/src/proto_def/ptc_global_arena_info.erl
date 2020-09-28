-module(ptc_global_arena_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f040.

get_name() -> global_arena_info.

get_des() ->
	[
	 {rank,uint32,0},
	 {honor,uint32,0},
	 {challenge_num,uint32,0},
	 {buy_times,uint32,0},
	 {daily_honor,uint32,0},
	 {daily_task,{list,global_arena_daily_task},[]},
	 {season_win_time,uint32,0},
	 {daily_log,{list,global_arena_daily_log},[]},
	 {season_state,uint32,0},
	 {season_endtime,uint32,0},
	 {worship_time,uint32,0}
	].

get_note() -> 
	"rank=段位，honor=荣誉，challenge_num=挑战次数，buy_times=购买次数，daily_honor=每日获得荣誉值，
	 daily_task=[id=任务id，state=任务状态]，season_win_time=赛季胜场，
	 daily_log=[name=敌人名字，result=结果，rank=战斗时的段位，honor_change=荣誉变化值，time=战斗时间]，
	 season_state=赛季状态{0=赛季中，1=结算中}，season_endtime=当前阶段结束时间，worship_time=膜拜次数".
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).