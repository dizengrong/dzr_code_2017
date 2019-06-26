%% -*- coding: latin-1 -*-
-module(data_arena).
-include("common.hrl").
-compile(export_all).

<?py def split_items(item_str):?>
<?py 	if item_str.strip() == "":?>
<?py 		return "[]" ?>
<?py 	else: ?>
<?py 		return "[{" + "}, {".join(item_str.split("|")) + "}]" ?>
<?py 	#endif ?>
<?py #enddef ?>

%% 竞技场免费次数
<?py for data in all_data: ?>
get_free_times(${data['ID']}) -> ${data['challengeFree']};
<?py #endfor ?>
get_free_times(_) -> 0.

%% 竞技场消耗
<?py for data in all_data: ?>
get_cost(${data['ID']}) -> ${split_items(data['consumption'])};
<?py #endfor ?>
get_cost(_) -> [].

%% 竞技场胜利宝箱
<?py for data in all_data: ?>
get_win_reward(${data['ID']}) -> ${data['victoryReward']};
<?py #endfor ?>
get_win_reward(_) -> 0.

%% 竞技场失败宝箱
<?py for data in all_data: ?>
get_fail_reward(${data['ID']}) -> ${data['failureReward']};
<?py #endfor ?>
get_fail_reward(_) -> 0.

%% 竞技场匹配规则{比玩家低X名次,比玩家高X名次}
<?py for data in all_data: ?>
get_challenge_limit(${data['ID']}) -> [{${data['lowlevel']}},{${data['middlelevel']}},{${data['highlevel']}}];
<?py #endfor ?>
get_challenge_limit(_) -> [].

%% 竞技场失败积分规则
<?py for data in point_data: ?>
get_fail_change(${data['sort']}, Point) when Point >= ${data['integral']} -> ${data['integralProportion']};
<?py #endfor ?>
get_fail_change(_, _) -> 0.

%% 竞技场胜利积分规则
<?py for data in point_data: ?>
get_win_change(${data['sort']}, Point) when Point >= ${data['integral']} -> ${data['differenceProportion']};
<?py #endfor ?>
get_win_change(_, _) -> 0.