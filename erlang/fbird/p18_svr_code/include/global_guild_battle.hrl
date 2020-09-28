%% @doc 跨服公会战头文件

-define (GGB_BATTLE_SCENE, 500054).


%% 策略
-define (GGB_STRATEGY_1, 1).  
-define (GGB_STRATEGY_2, 2).
-define (GGB_STRATEGY_3, 3).


%% 战队数据
-record (ggb_team, {
	team_id     = {0, 0}, 		%% {游戏服id, 公会id}
	server_name = "",			%% 所在游戏服名称
	guild_name  = "",			%% 战队名称
	fighting    = 0, 			%% 战力值
	strategy    = ?GGB_STRATEGY_1,  %% 策略
	inspire     = 0,  			%% 鼓舞等级
	rank        = 0 			%% 排名
}).


%% 第一阶段分组数据
-record (ggb_fpg, {
	group_id       = 0, 	%% 分组
	takein_members = [], 	%% 参赛队伍[TeamId]记录一开始参与的队伍
	members        = [], 	%% 当前剩余参赛队伍[TeamId]会变化的
	round          = 1, 	%% 小组赛第几轮
	promotions     = [], 	%% 本轮晋级队伍[TeamId]
	current_battle = undefined,  %% 当前战斗的队伍信息:{M1, M2, BeginTime}
	battle_members = undefined
}).


%% 战斗日志
-record (ggb_battle_log, {
	status      = 0,	%% 这条记录产生时的状态  
	group_id    = 0,
	round       = 1, 	%% 小组赛第几轮
	win_team_id ,
	lose_team_id,
	result      = 0,
	win_score   = 0,
	lose_score  = 0
}).


-define (GGB_STATUS_NOT_START          , 0).  	 %% 未开始
-define (GGB_STATUS_FIRST_PERIOD_PRE   , 1).    %% 海选赛报名中
-define (GGB_STATUS_FIRST_PERIOD       , 2).    %% 海选赛进行中
-define (GGB_STATUS_FIRST_PERIOD_FINISH, 3).    %% 海选赛结束
-define (GGB_STATUS_TOP_16_PRE         , 4).    %% 16强准备阶段
-define (GGB_STATUS_TOP_16             , 5).    %% 16强赛阶段
-define (GGB_STATUS_TOP_8_PRE          , 6).    %% 8强准备阶段
-define (GGB_STATUS_TOP_8              , 7).    %% 8强赛阶段
-define (GGB_STATUS_TOP_4_PRE          , 8).    %% 4强准备阶段
-define (GGB_STATUS_TOP_4              , 9).    %% 4强赛阶段
-define (GGB_STATUS_TOP_2_PRE          , 10).    %% 2强准备阶段
-define (GGB_STATUS_TOP_2              , 11).    %% 2强赛阶段
-define (GGB_STATUS_TOP_1              , 12).    %% 冠军展示阶段
-define (GGB_STATUS_NOT_OPEN           , 13).    %% 参赛队伍不足，不开启


-define (GGB_RESULT_NON           , 0).		%% 未开始
-define (GGB_RESULT_LOSE          , 1).		%% 输
-define (GGB_RESULT_WIN           , 2).		%% 战斗赢了
-define (GGB_RESULT_NO_OPPOENT_WIN, 3).		%% 轮空赢了
-define (GGB_RESULT_TOP8_WIN      , 4).		%% 前8自动晋级
-define (GGB_RESULT_OVERTIME_WIN  , 5).		%% 超时按伤害算赢了


-define (GGB_PROMOTIONS, 1).		%% 晋级
-define (GGB_DIE_OUT   , 2).		%% 淘汰
-define (GGB_GO_ON     , 3).		%% 继续中


-define (STAKE_TYPE_NON, 0). 	%% 没有押注
-define (STAKE_TYPE_1  , 1). 	%% 加油押注
-define (STAKE_TYPE_2  , 2). 	%% 慰问押注

