%% 职业
-define(WARRIOR,	1). %% 战士
-define(MAGE,		2). %% 法师
-define(PRIEST,		3). %% 牧师
-define(ASSASSIN,	4). %% 刺客

-define(ALL_HERO_PROF,	[
	?WARRIOR,
	?MAGE,
	?PRIEST,
	?ASSASSIN
]). 


-define(USED_LIST,	[
	?MAIN_SCENE,
	?PERSONAL_ARENA_GUARD,
	?PERSONAL_ARENA_ATTACK,
	?ON_BATTLE_ACT_COPY,
	?ON_BATTLE_EXPEDITION
]).

%% 阵容类型
-define(MAIN_SCENE            , 1). %% 主关卡
-define(PERSONAL_ARENA_GUARD  , 2). %% 个人竞技场防守
-define(PERSONAL_ARENA_ATTACK , 3). %% 个人竞技场进攻
-define(ON_BATTLE_ACT_COPY 	  , 4). %% 活动副本
-define(ON_BATTLE_EXPEDITION  , 5). %% 英雄远征


%% 英雄场景数据改变类型
-define (HERO_STAR_CHANGE, 1).
