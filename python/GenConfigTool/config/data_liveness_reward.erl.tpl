-module(data_liveness_reward).
-compile(export_all).


%% get_data(Id) -> {需要分数, 奖励道具}
<?py for data in all_data: ?>
get_data(${data[0]}) -> {${data[1]}, [{${data[2]}, ${data[3]}}]};
<?py #endfor ?>
get_data(_) -> [].
