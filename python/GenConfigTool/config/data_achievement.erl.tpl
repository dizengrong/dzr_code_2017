-module(data_achievement).
-include("common.hrl").
-compile(export_all).

<?py def split_items(item_str):?>
<?py 	return "[{" + "}, {".join(item_str.split("|")) + "}]" ?>
<?py #enddef ?>

<?py for data in all_data: ?>
get_data(${data[0]})->#st_achievement{id=${data[0]},type=${data[2]},targetType=${data[4]},preAchieve=${data[5]},targetNum=${data[6]},rewardItem=${split_items(data[7])},nextAchieve=${data[8]}};
<?py #endfor ?>
get_data(_) -> {}.

<?py def select_type(all_data):?>
<?py	ret_list = {} ?>
<?py	for data in all_data: ?>
<?py		if ret_list.has_key(data[2]): ?>
<?py			ret_list[data[2]].append(data[0]) ?>
<?py		else: ?>
<?py			ret_list[data[2]] = [data[0]] ?>
<?py #endif ?>
<?py #endfor ?>
<?py	return ret_list ?>
<?py #enddef ?>

<?py data_list = select_type(all_data) ?>

<?py for x in data_list: ?>
<?py 	data = to_str(data_list[x]) ?>
select_type(${x}) -> ${data};
<?py #endfor ?>
select_type(_) -> [].

