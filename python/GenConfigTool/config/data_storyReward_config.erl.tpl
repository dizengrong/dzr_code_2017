-module(data_storyReward_config).
-compile(export_all).

<?py def split_items(item_str):?>
<?py 	return "[{" + "}, {".join(item_str.split("|")) + "}]" ?>
<?py #enddef ?>

% get_data(Id) -> {需要通过的关卡数, 奖励}.
<?py for data in all_data: ?>
get_data(${data[0]}) -> {${data[2]}, ${split_items(data[1])}};
<?py #endfor ?>
get_data(_) -> {}.
