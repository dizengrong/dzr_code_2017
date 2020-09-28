%% @doc 任务及计数器相关

-define (COUNT_TYPE_INCR,  1).  %% 增量更新类型的计数器
-define (COUNT_TYPE_TOTAL, 2).  %% 总量更新类型的计数器

%%任务类型
-define(SORT_MAINTASK, 1).%%主线

%%任务状态
-define(NO_ACCEPT_STATE  , 0). %%未接取
-define(ACCEPT_STATE     , 1). %%接取
-define(CAN_FINISH_STATE , 2). %%能完成
-define(FINISH_STATE     , 3). %%已提交完成

%% =============================================================================
%% =============================================================================
%% 下面为计数器类型定义，计数器类型分为增量和总量
%% 增加了新的计数器还要修改fun_count:count_type/1
%% 计数器默认第二个参数要大于等于才行，有必须要等于才算的在这里区分:
%% 		fun_condition:is_condition_val2_matched 
%% 最好其他地方都调用这个方法来判断：fun_condition:is_condition_finished

-define(TASK_HERO_DECOMPOSE      , 1). %%英雄分解
-define(TASK_ARTIFACT_DECOMPOSE  , 2). %%神器分解
-define(TASK_RUNE_DECOMPOSE      , 3). %%符文分解
-define(TASK_HERO_STAR_UP        , 4). %%英雄升星
-define(TASK_EQUIPMENT_SYNTHESIS , 5). %%装备合成
-define(TASK_RUNE_STRENGTHEN     , 6). %%符文强化
-define(TASK_PASS_STAGE          , 7). %%到达关卡
-define(TASK_SUMMON_DOOR         , 8). %%召唤之门次数
-define(TASK_LOW_DRAW            , 9). %%低级召唤法阵次数
-define(TASK_HIGH_DRAW           , 10). %%高级召唤法阵次数
-define(TASK_TURNTABLE           , 11). %%低级大转盘次数
-define(TASK_PERSPNAL_ARENA      , 12). %%单人竞技场次数
-define(TASK_COPY_ONE            , 13). %%副本类型1次数
-define(TASK_COPY_TWE            , 14). %%副本类型2次数
-define(TASK_COPY_THREE          , 15). %%副本类型3次数
-define(TASK_EXPEDITION          , 16). %%远征次数