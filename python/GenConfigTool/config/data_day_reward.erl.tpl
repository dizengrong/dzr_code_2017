-module(data_day_reward).
-include("common.hrl").
-compile(export_all).

<?py def split_items(item_str):?>
<?py 	return "[{" + "}, {".join(item_str.split("|")) + "}]" ?>
<?py #enddef ?>

<?py for data in all_data: ?>
get_data(${data[1]}) -> #st_day_reward{id=${data[1]},rewardId=${split_items(data[2])}};
<?py #endfor ?>
get_data(_) -> {}.

<?py all_ids = [d[1] for d in all_data] ?>
get_all() -> ${all_ids}.
