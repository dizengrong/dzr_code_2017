%% @doc 排行榜相关的头文件

-define (RANK_DEFAULT_SIZE, 100).

%%排行榜
-define(RANKLIST_ARENA, 1). %%竞技场排行榜

%% 排行榜类型key(直接映射为数据库表)
-define (T_RANK_ARENA, ranklist_arena). %% 竞技场排行榜

%% 上面的所有排行榜类型，除了竞技场
-define (ALL_RANK, [
	?T_RANK_ARENA
]).