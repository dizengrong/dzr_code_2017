-define(EQUIP_LIST,[?HELMET,?ARMOR,?LEGARMOR,?BOOTS,?GLOVES,?ARMS,?NECKLACE,?ACCESSORIES]). %%装备列表


-define(BIND_YES,	1). %% 绑定
-define(BIND_NO,	0). %% 不绑定

%%装备类型
-define(HELMET, 	 1). %%头盔
-define(ARMOR, 		 2). %%衣服
-define(LEGARMOR, 	 3). %%裤腿
-define(BOOTS, 		 4). %%鞋子
-define(GLOVES, 	 5). %%手套
-define(ARMS, 		 6). %%武器
-define(NECKLACE, 	 7). %%项链
-define(ACCESSORIES, 8). %%饰品

%%符文装备部位
-define(FUWEN_POS_1,	21). %% 圆形
-define(FUWEN_POS_2,	22). %% 方形
-define(FUWEN_POS_3,	23). %% 三角形
-define(FUWEN_POS_4,	24). %% 菱形
-define(FUWEN_POS_5,	25). %% 五角形
-define(FUWEN_POS_6,	26). %% 六角形

-define(FUWEN_ALL_POS,	[
	?FUWEN_POS_1, 
	?FUWEN_POS_2, 
	?FUWEN_POS_3, 
	?FUWEN_POS_4, 
	?FUWEN_POS_5, 
	?FUWEN_POS_6
]).



%%神装孔位区间
-define(GOD_COSTUME_START,		 20001). %% 开始
-define(GOD_COSTUME_END,		 20012). %% 结束

%%神装背包区间
-define(BAG_GOD_COSTUME_START, 	30001).
-define(BAG_GOD_COSTUME_END, 	40000).

%%背包隐藏区间
-define(BAG_CANT_SEE_START,5000).
-define(BAG_CANT_SEE_END,8000).

%%不可见装备ID
-define(CANT_SEE_ITEMS,[60031,60032,60033,60034,60035,60036,60025,60026,60027,60028,60029,60015,60016,60017,60018,60019]).

%% 奖励展示类型
-define(SHOW_REWARD_COMMON, 0). 		%% 公共的展示
-define(SHOW_ENERGY_DRAW,   1). 		%% 能量抽奖展示

-define(NONE_SHOE,		     	 0). 	%% 一般协助
-define(FAMILY_SHOE,	     	 1). 	%% 家园协助特殊类型

-define (ITEM_NO_BATTLE, 5918).  %% 免戰令
-define (ITEM_SECRET_SILVER, 5919).  %% 秘銀

-define (ITEM_TYPE_RESOURCE,           100).  %% 资源
-define (ITEM_TYPE_ENTOURAGE,          200).  %% 英雄
-define (ITEM_TYPE_ENTOURAGE_FRAGMENT, 201).  %% 英雄碎片
-define (ITEM_TYPE_FIXED_FRAGMENT,     202).  %% 固定碎片
-define (ITEM_TYPE_RAND_FRAGMENT,      203).  %% 随机碎片
-define (ITEM_TYPE_ARTIFACT,	       206).  %% 神器

-define (NONE_WEARING, 0).  %% 无
-define (WEARING,      1).  %% 穿戴中