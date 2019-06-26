%% -*- coding: latin-1 -*-
-module(data_arena_reward).
-include("common.hrl").
-compile(export_all).

<?py def split_items(item_str):?>
<?py 	if item_str.strip() == "":?>
<?py 		return "[]" ?>
<?py 	else: ?>
<?py 		return "[{" + "}, {".join(item_str.split("|")) + "}]" ?>
<?py 	#endif ?>
<?py #enddef ?>

<?py for data in daily_data: ?>
get_daily_reward(${data['sort']}, Rank) when Rank >= ${data['rankLevel']} -> ${split_items(data['rewardList'])};
<?py #endfor ?>
get_daily_reward(_, _) -> [].

<?py for data in season_data: ?>
get_season_reward(${data['sort']}, Rank) when Rank >= ${data['rankLevel']} -> ${split_items(data['rewardList'])};
<?py #endfor ?>
get_season_reward(_, _) -> [].