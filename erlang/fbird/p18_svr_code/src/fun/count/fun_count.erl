-module(fun_count).
-include("common.hrl").
-export([process_count_event/4,count_type/1]).
-export ([on_count_event/5, can_trigger_diamond_event/1]).


%% 2018-11-10：以后编写事件代码都使用这个新接口
on_count_event(Uid, Sid, Event, Val2, Val3) ->
	mod_role_event:trigger_event(Uid, Sid, Event, Val2, Val3).

process_count_event(Event,{Sort,Data,Num},Uid,Sid)->
	Sort == 0 andalso ?ERROR("Event maybe is unused", [Event]),
	mod_role_event:trigger_event(Uid, Sid, Sort, Data, Num).

%% 获取计数器更新类型
count_type(?TASK_HERO_DECOMPOSE) -> ?COUNT_TYPE_INCR;
count_type(?TASK_ARTIFACT_DECOMPOSE) -> ?COUNT_TYPE_INCR;
count_type(?TASK_RUNE_DECOMPOSE) -> ?COUNT_TYPE_INCR;
count_type(?TASK_HERO_STAR_UP) -> ?COUNT_TYPE_INCR;
count_type(?TASK_EQUIPMENT_SYNTHESIS) -> ?COUNT_TYPE_INCR;
count_type(?TASK_RUNE_STRENGTHEN) -> ?COUNT_TYPE_INCR;
count_type(?TASK_SUMMON_DOOR) -> ?COUNT_TYPE_INCR;
count_type(?TASK_LOW_DRAW) -> ?COUNT_TYPE_INCR;
count_type(?TASK_HIGH_DRAW) -> ?COUNT_TYPE_INCR;
count_type(?TASK_TURNTABLE) -> ?COUNT_TYPE_INCR;
count_type(?TASK_PERSPNAL_ARENA) -> ?COUNT_TYPE_INCR;
count_type(?TASK_COPY_ONE) -> ?COUNT_TYPE_INCR;
count_type(?TASK_COPY_TWE) -> ?COUNT_TYPE_INCR;
count_type(?TASK_COPY_THREE) -> ?COUNT_TYPE_INCR;
count_type(?TASK_EXPEDITION) -> ?COUNT_TYPE_INCR;
count_type(_) -> ?COUNT_TYPE_TOTAL.


%% 哪些物品日志不会触发钻石改变的事件
can_trigger_diamond_event(_) -> true.