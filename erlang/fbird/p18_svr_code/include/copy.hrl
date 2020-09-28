%% @doc 副本相关定义

%% 副本类型细分 
-define(DUNGEONS_TYPE_NORMAL, "NORMAL").		%% 一般关卡地图
-define(DUNGEONS_TYPE_BREAK,  "BREAK").			%% 突破地下城
-define(DUNGEONS_TYPE_GUILD,  "GUILD").			%% 公会副本
-define(DUNGEONS_TYPE_STAR,   "STAR").			%% 加星材料地下城
-define(DUNGEONS_TYPE_HERO,   "HERO").			%% 英雄材料地下城
-define(DUNGEONS_TYPE_GEM,    "GEM").			%% 宝石材料地下城
-define(DUNGEONS_TYPE_COIN,    "HERORUNE").			%% 金币地下城(改为符文副本了)
-define(DUNGEONS_TYPE_SKILL,   "SKILL").		%% 技能地下城
-define(DUNGEONS_TYPE_ARTIFACE,   "ARTIFACE").		%% 神器地下城
-define(DUNGEONS_TYPE_HERO_CHALLENGE,   "HERO_CHALLENGE").		%% 英雄挑战副本
-define(DUNGEONS_TYPE_WORLDBOSS,   "WORLDBOSS").		%% 世界boss
-define(DUNGEONS_TYPE_LIMITBOSS,   "LIMITBOSS").		%% 限时boss
-define(DUNGEONS_TYPE_MELLEBOSS,   "MELLEBOSS").		%% 乱斗boss



%% 所有的材料副本类型(即地下城)
-define(ALL_MATERIAL_DUNGEONS_TYPE, [
	?DUNGEONS_TYPE_BREAK,
	?DUNGEONS_TYPE_STAR,
	?DUNGEONS_TYPE_HERO,
	?DUNGEONS_TYPE_GEM,
	?DUNGEONS_TYPE_COIN,
	?DUNGEONS_TYPE_SKILL,
	?DUNGEONS_TYPE_ARTIFACE,
	?DUNGEONS_TYPE_HERO_CHALLENGE
]).

-define(DUNGEONS_TYPE_MILITARY_BOSS,   "MILITARY").		%% 军衔副本

%% 关卡boss是否已经挑战过了
-define(BARRIER_BOSS_ATTACKED_NO,  0).
-define(BARRIER_BOSS_ATTACKED_YES, 1).

%% 胜负定义
-define(COPY_WIN,  1).
-define(COPY_LOSE, 0).


%% 副本数据类型
-define(COPY_DATA_KILL_BOSS		    , 22).		%% 击杀的boss数量
-define(COPY_DATA_KILL_MONSTER		, 23).		%% 击杀的小怪数量
-define(COPY_DATA_TOTAL_DAMAGE		, 24).		%% 造成的总伤害
-define(COPY_DATA_MONSTER_WAVE		, 25).		%% 打过的怪物波数
-define(COPY_DATA_WORLDBOSS   		, 26).		%% 世界boss的伤害数据
-define(COPY_DATA_COIN        		, 27).		%% 金币副本获得金币
-define(COPY_DATA_LIMIT_WORLDBOSS 	, 28).		%% 限时boss伤害数据
-define(COPY_DATA_GUILD_COPY	 	, 34).		%% 公会boss伤害数据
-define(COPY_DATA_MELLEBOSS	 		, 36).		%% 乱斗boss伤害数据


-define(GLOBAL_ARNEA_RANK	, 0).		%% 跨服竞技场天梯
-define(GLOBAL_ARNEA_MAZE	, 1).		%% 跨服竞技场迷宫
-define(GLOBAL_ARNEA_WATER	, 2).		%% 跨服竞技场航海
-define(ARNEA_MINING_GRAB	, 3).		%% 采矿竞技场
%% =============================================================================


%% 活动副本类型
-define (ACT_COPY_COIN, 1). 	%% 金币挑战
-define (ACT_COPY_WARRIOR, 2). 	%% 勇者挑战
-define (ACT_COPY_HERO, 3). 	%% 英雄挑战

-define (ALL_ACT_COPYS, [
	?ACT_COPY_COIN,
	?ACT_COPY_WARRIOR,
	?ACT_COPY_HERO
]).
