%% @doc 与技能相关的宏定义


%%技能距离类型
-define(SKILL_DIS_NEAR,"near").
-define(SKILL_DIS_NORMAL,"normal").
-define(SKILL_DIS_FAR,"far").
-define(SKILL_DIS_BUFF,"buff").

%% 攻击效果类型
-define(ATT_SORT_NARMAL,0).
-define(ATT_SORT_DODGE,1).
-define(ATT_SORT_CRIT,2).
-define(ATT_SORT_HIGHDEF,3).

%% 防御效果类型
-define(DEF_SORT_NO,0).
-define(DEF_SORT_TREAT,1). %%治疗
-define(DEF_SORT_DIE,2). %%死亡
-define(DEF_SORT_STIFLE,3). %%后仰击退
-define(DEF_SORT_KICKDOWN,4). %%击�
-define(DEF_SORT_KICK,5). %%浮空击退
-define(DEF_SORT_UNTREAT,6).%%免疫治疗
-define(DEF_SORT_NOKICKDOWN,7). %%免疫击�
-define(DEF_SORT_NOSTIFLE,8). %%免疫后仰击退
-define(DEF_SORT_NOKICK,9). %%免疫浮空击退
-define(DEF_SORT_TREAT_MP,10). %%治疗
-define(DEF_SORT_NO_MP,11). %%治疗


-define(BUFF_SORT_NO,"CONTROL").
-define(BUFF_SORT_PROPERTY_NUM,"ATTRIBUTE").
-define(BUFF_SORT_PROPERTY_PER,"ATTRIBUTEPER").
-define(BUFF_SORT_DOT_NUM,"RECOVER").
-define(BUFF_SORT_DOT_PER,"RECOVERPER").
-define(BUFF_SORT_DEMAGE_NUM,"DMGREDUCE").
-define(BUFF_SORT_DEMAGE_PER,"DMGREDUCEPER").
-define(BUFF_SORT_EXP_INCRE_PER,"EXPINCREPER").
-define(BUFF_SORT_WUDI,"INVIN").
-define(BUFF_SORT_CHAOFENG,"TAUNT").
-define(BUFF_SORT_BATI,"UNBREAK").
-define(BUFF_SORT_SKILL,"AOEDMG").
-define(BUFF_SORT_PATH,"PATH").
-define(BUFF_SORT_CONTINUITY,"CONTINUITY").  %% 持续性buff技能，可以被打断
-define(BUFF_SORT_BEAR_DAMAGE,"BEARDAMAGE").  %% 承担玩家收到的伤害

-define(BUFF_CONTROLL_SORT_NO,"NO").
-define(BUFF_CONTROLL_SORT_DINGSHEN,"FREEZE").
-define(BUFF_CONTROLL_SORT_KONGJU,"FEAR").
-define(BUFF_CONTROLL_SORT_CUIMIAN,"SLEEP").
-define(BUFF_CONTROLL_SORT_FANGZHU,"BANISH").
-define(BUFF_CONTROLL_SORT_CHENMO,"SILENT").
-define(BUFF_CONTROLL_SORT_YINGDAO,"PERSISTENT").
-define(BUFF_CONTROLL_SORT_CHIXU,"DURATIVE").
-define(BUFF_CONTROLL_SORT_XUANYUN,"STUN").
-define(BUFF_CONTROLL_SORT_TAUNT,"TAUNT").
-define(BUFF_CONTROLL_SORT_CHANGE_XUANYUN,"CHANGE_XUANYUN").  %% 改变眩晕效果
-define(BUFF_CONTROLL_SORT_CHANGE_TREAT,"CHANGE_TREAT").  %% 改变治疗效果

%% 技能施放点
-define(SKILL_CAST_SELF,"SELFROLE").				%%对自身角色施�
-define(SKILL_CAST_TARGET,"TARGETROLE").			%%对目标角色施�
-define(SKILL_CAST_SELF_AREA,"SELFCOORDINATE").		%%角色当前所在坐标为施放�
-define(SKILL_CAST_TARGET_AREA,"TARGETCOORDINATE").	%%所选中的目标所在坐标为施放�

%% 技能目标类�
-define(SKILL_TARGET_TYPE_NO,"NO").				%%无目�
-define(SKILL_TARGET_TYPE_ENEMY,"ENEMY").		%%敌人
-define(SKILL_TARGET_TYPE_SELF,"SELF").			%%自己
-define(SKILL_TARGET_TYPE_TEAM,"TEAMMATE").		%%队友
-define(SKILL_TARGET_TYPE_FRIEND,"FRIENDLY").	%%友善

%% 区域形状
-define(AREA_SECTOR,"SECTOR").		%%扇形
-define(AREA_CYCLE,"CYCLE").		%%圆形
-define(AREA_RECT,"RECT").			%%矩形
-define(AREA_RING,"RING").			%%环形
-define(AREA_POINT,"POINT").		%%�

%% 技能收集目标数量类�
-define(COLL_TARGET_NUM_NO,"NOEFFECT").			%%没有额外影响
-define(COLL_TARGET_NUM_AOEALL,"AOEALL").		%%影响范围内的所有单�
-define(COLL_TARGET_NUM_SINGLE,"TARGETSINGLE").	%%只影响所选目标一个单�
-define(COLL_TARGET_NUM_AOERANDOM,"AOERANDOM").	%%影响范围内一定数量的单位

%% 技能击飞类�
-define(SKILL_KICK_BACK,"KICKBACK").	%%压制
-define(SKILL_KICK_DOWN,"KICKDOWN").	%%击倒
-define(SKILL_KICK_FLY,"KICKFLY").		%%击飞
-define(SKILL_KICK_NO,"NO").

%% =========== 新的怪物ai逻辑处理 ================
%% 血量低于多少可以释放召唤怪物技能
-define(NEW_AI_TYPE_CALL_MONSTER_BY_HP, 1).
%% 血量低于多少可以释放该技能
-define(NEW_AI_TYPE_CAST_SKILL_BY_HP, 2).

%% AI类型
-define(ATK_NORMAL,		0). %% 普通
-define(ATK_RACE,		1). %% 种族（阵营）
-define(ATK_PROFESSION,	2). %% 优先法师
-define(ATK_SEX,		3). %% 优先牧师
