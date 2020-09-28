%% -*- coding: latin-1 -*-

-module (gm_code_list).
-compile([export_all]).

all() ->
	[
		{"additem", [{item_type, "物品id"}], "增加指定的物品"},
		{"additem", [{item_type, "物品id"}, "数量"], "增加指定数量的物品"},
		{"additem", [{item_type, "物品id"}, "数量", "等级"], "增加指定数量的物品"},
		{"cleanbag", [], "清空背包"},
		{"addexp", ["数量"], "增加角色经验"},
		{"mail", ["标题", "内容"], "给自己发送一封邮件"},
		{"setproperty", [{property_type, "战斗属性id"}, "数值"], "设置战斗属性(id见战斗属性表)"},
		{"setbarrier", ["第几关"], "设置当前通关关卡"},
		{"sethp", ["数值"], "设置自己的血量(最小为1)"},
		{"addmonster", [{monster_type, "怪物id"}], "生成指定怪物"},
		{"addmonster", [{monster_type, "怪物id"}, "数量"], "生成指定怪物的数量"},
		{"recharge", ["充值档次id"], "充值"},
		{"resetcopy", [], "重置地下城次数"},
		{"sign", ["第几天"], "设置签到"},
		{"resetpk", [], "重置竞技场次数"},
		{"minuscreatetime", ["几天"], "把账号的创建时间往前推几天（比如七天挑战需要）"},
		{"addvipexp", ["数量"], "增加VIP经验"},
		{"relifetime", ["次数"], "设置转生次数（用于测试）"},
		{"resetquick", [], "重置快速挑战次数"},
		{"resetbuycoin", [], "重置点金次数"},
		{"openbox", ["宝箱id", "职业(0, 3, 6, 9)"], "开宝箱看产出什么"},
		{"openbox", ["宝箱id", "职业(0, 3, 6, 9)", "次数"], "开宝箱看产出什么"},
		{"settask", ["任务id"], "设置任务"},
		{"usecard", ["充值卡类型"], "消耗充值卡一次"},
		{"addtitleexp", ["增加称号经验"], "加多少经验"},
		{"mail", ["发送邮件"], "邮件表ID + 对应参数"},
		{"addherobuff", ["buff_id"], "给所有上阵英雄加buff"},
		{"addmonsterbuff", ["buff_id"], "给玩家所在场景里的所有怪物加buff"},
		{"setguildlv", ["等级"], "设置玩家所在公会的等级"}
	].



attr_list() ->
	[
		{"攻击", 10001},
		{"生命上限", 10002},
		{"法力上限", 10003},
		{"真实伤害", 10004},
		{"免伤", 10005},
		{"穿透，忽略护甲百分比", 10006},
		{"护甲", 10007},
		{"暴击率", 10008},
		{"抗暴率", 10009},
		{"命中", 10010},
		{"闪避", 10011},
		{"暴击伤害", 10012},
		{"韧性，降低被暴击率", 10013},
		{"格挡", 10014},
		{"破防", 10015},
		{"破防率", 10016},
		{"格挡率", 10017},
		{"重伤", 10018},
		{"免伤", 10019},
		{"控制，降低目标免控效果", 10020},
		{"免控，免疫控制类效果的能力强弱", 10021},
		{"移动速度", 10022},
		{"限伤", 10023},
		{"攻击力百分比", 20001},
		{"最大生命值百分比", 20002},
		{"最大魔法值百分比", 20003},
		{"最大真实伤害百分比", 20004},
		{"最大免伤百分比", 20005},
		{"最大穿透百分比", 20006},
		{"最大护甲百分比", 20007},
		{"最大暴击率百分比", 20008},
		{"最大抗暴率百分比", 20009},
		{"最大命中百分比", 20010},
		{"最大闪避百分比", 20011},
		{"最大暴击伤害百分比", 20012},
		{"最大韧性百分比", 20013},
		{"最大格挡百分比", 20014},
		{"最大破防百分比", 20015},
		{"最大破防率百分比", 20016},
		{"最大格挡率百分比", 20017},
		{"最大重伤百分比", 20018},
		{"最大免伤百分比", 20019},
		{"最大控制百分比", 20020},
		{"最大免控百分比", 20021},
		{"最大移动速度百分比", 20022},
		{"最大限伤百分比", 20023},
		{"战力，策划用于伤害计算", 20024}
	].

