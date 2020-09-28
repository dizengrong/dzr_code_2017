%% @doc 属性相关

%% 属性
-define(PROPERTY_SORT_BATTLE,1).
-define(PROPERTY_SORT_NORMAL,2).

-define(BASE_PROPERTY_LIST, [
	?PROPERTY_ATK,
	?PROPERTY_HPLIMIT,
	?PROPERTY_MPLIMIT,
	?PROPERTY_REALDMG,
	?PROPERTY_DMGDOWN,
	?PROPERTY_DEFIGNORE,
	?PROPERTY_DEF,
	?PROPERTY_CRI,
	?PROPERTY_CRIDOWN,
	?PROPERTY_HIT,
	?PROPERTY_DOD,
	?PROPERTY_CRIDMG,
	?PROPERTY_TOUGHNESS,
	?PROPERTY_BLOCKRATE,
	?PROPERTY_BREAKDEF,
	?PROPERTY_BREAKDEFRATE,
	?PROPERTY_BLOCKDMGRATE,
	?PROPERTY_DMGRATE,
	?PROPERTY_DMGDOWNRATE,
	?PROPERTY_CONTORLRATE,
	?PROPERTY_CONTORLDEFRATE,
	?PROPERTY_MOVESPD,
	?PROPERTY_LIMITDMG
]).

%% 属性定义不要超过uint16
-define(PROPERTY_ATK,           10001).		%% 攻击
-define(PROPERTY_HPLIMIT,       10002).		%% 生命上限
-define(PROPERTY_MPLIMIT,       10003).		%% 法力上限
-define(PROPERTY_REALDMG,       10004).		%% 真实伤害
-define(PROPERTY_DMGDOWN,       10005).		%% 免伤
-define(PROPERTY_DEFIGNORE,     10006).		%% 穿透，忽略护甲百分比
-define(PROPERTY_DEF,           10007).		%% 护甲
-define(PROPERTY_CRI,           10008).		%% 暴击率
-define(PROPERTY_CRIDOWN,       10009).		%% 抗暴率
-define(PROPERTY_HIT,           10010).		%% 命中
-define(PROPERTY_DOD,           10011).		%% 闪避
-define(PROPERTY_CRIDMG,        10012).		%% 暴击伤害
-define(PROPERTY_TOUGHNESS,     10013).		%% 韧性，降低被暴击率
-define(PROPERTY_BLOCKRATE,     10014).		%% 格挡
-define(PROPERTY_BREAKDEF,      10015).		%% 破防
-define(PROPERTY_BREAKDEFRATE,  10016).		%% 破防率
-define(PROPERTY_BLOCKDMGRATE,  10017).		%% 格挡率
-define(PROPERTY_DMGRATE,       10018).		%% 重伤
-define(PROPERTY_DMGDOWNRATE,   10019).		%% 免伤
-define(PROPERTY_CONTORLRATE,   10020).		%% 控制，降低目标免控效果
-define(PROPERTY_CONTORLDEFRATE,10021).		%% 免控，免疫控制类效果的能力强弱
-define(PROPERTY_MOVESPD,       10022).		%% 移动速度
-define(PROPERTY_LIMITDMG,      10023).		%% 限伤

-define(PROPERTY_ATK_PERCENT            ,  20001).		%% 攻击力百分比
-define(PROPERTY_HP_PERCENT             ,  20002).		%% 最大生命值百分比
-define(PROPERTY_MP_PERCENT             ,  20003).		%% 最大魔法值百分比
-define(PROPERTY_REALDMG_PERCENT        ,  20004).		%% 最大真实伤害百分比
-define(PROPERTY_DMGDOWN_PERCENT        ,  20005).		%% 最大免伤百分比
-define(PROPERTY_DEFIGNORE_PERCENT      ,  20006).		%% 最大穿透百分比
-define(PROPERTY_DEF_PERCENT            ,  20007).		%% 最大护甲百分比
-define(PROPERTY_CRI_PERCENT            ,  20008).		%% 最大暴击率百分比
-define(PROPERTY_CRIDOWN_PERCENT        ,  20009).		%% 最大抗暴率百分比
-define(PROPERTY_HIT_PERCENT            ,  20010).		%% 最大命中百分比
-define(PROPERTY_DOD_PERCENT            ,  20011).		%% 最大闪避百分比
-define(PROPERTY_CRIDMG_PERCENT         ,  20012).		%% 最大暴击伤害百分比
-define(PROPERTY_TOUGHNESS_PERCENT      ,  20013).		%% 最大韧性百分比
-define(PROPERTY_BLOCKRATE_PERCENT      ,  20014).		%% 最大格挡百分比
-define(PROPERTY_BREAKDEF_PERCENT       ,  20015).		%% 最大破防百分比
-define(PROPERTY_BREAKDEFRATE_PERCENT   ,  20016).		%% 最大破防率百分比
-define(PROPERTY_BLOCKDMGRATE_PERCENT   ,  20017).		%% 最大格挡率百分比
-define(PROPERTY_DMGRATE_PERCENT        ,  20018).		%% 最大重伤百分比
-define(PROPERTY_DMGDOWNRATE_PERCENT    ,  20019).		%% 最大免伤百分比
-define(PROPERTY_CONTORLRATE_PERCENT    ,  20020).		%% 最大控制百分比
-define(PROPERTY_CONTORLDEFRATE_PERCENT ,  20021).		%% 最大免控百分比
-define(PROPERTY_MOVESPD_PERCENT        ,  20022).		%% 最大移动速度百分比
-define(PROPERTY_LIMITDMG_PERCENT       ,  20023).		%% 最大限伤百分比
-define(PROPERTY_GS                     ,  20024).		%% 战力,策划用于伤害计算

-define(PROPERTY_DMG_TOHUMAN      ,  124).		%% 每点提升0.1%的对人族怪物的伤害
-define(PROPERTY_DMG_TOGOD        ,  125).		%% 每点提升0.1%的对神族怪物的伤害
-define(PROPERTY_DMG_TODEVIL      ,  126).		%% 每点提升0.1%的对魔族怪物的伤害
-define(PROPERTY_HP_STOLEN        ,  127).		%% 生命偷取加成:每次对敌人造成伤害时，自己恢复的生命值
-define(PROPERTY_HP_STOLEN_PERCENT,  128).		%% 每次攻击千分比几率触发PROPERTY_HP_STOLEN
-define(PROPERTY_ACCURATE         ,  129).		%% 精准等级:降低敌人格挡自己攻击的几率
-define(PROPERTY_DMG_PVE          ,  130).		%% 惩戒之力:提升对怪物造成伤害的能力，每点提升对怪物伤害0.1%
-define(PROPERTY_DMGDOWN_PVE      ,  131).		%% 不灭之躯:降低怪物造成伤害的能力，每点降低怪物伤害0.1%
-define(PROPERTY_DMG_PVP          ,  132).		%% 神圣之力:提升对人物造成伤害的能力，每点提升对怪物伤害0.1%
-define(PROPERTY_DMGDOWN_PVP      ,  133).		%% 圣光护体:降低人物造成伤害的能力，每点降低人物伤害0.1%
-define(PROPERTY_RECOVERY         ,  134).		%% 生命恢复:每5秒生命值恢复
-define(PROPERTY_STUN_DEFEAT      ,  135).		%% 眩晕抗性:降低被眩晕的几率，每点降低被眩晕几率0.1%
-define(PROPERTY_COPPER_UP        ,  136).		%% 征战金币:提高征战每5秒获得金币1%
-define(PROPERTY_EXP_UP           ,  137).		%% 征战经验:提高征战每5秒获得经验1%

-define(PROPERTY_LEV,30001).%% 等级
-define(PROPERTY_HP,30002).%% 生命
-define(PROPERTY_MP,30003).%% 法力
-define(PROPERTY_VIP_LEV,30004).%% VIP等级
-define(PROPERTY_SCENE_LEV,30005).%% 关卡等级